%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 游戏中的节点列表
%%% 分为:网管节点(gateway),地图节点(area),世界节点(world)
%%% 主要供查询使用,app在启动时将自身节点告诉给world_nodes
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(world_nodes).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").

-ifdef(TEST).
-compile([export_all]).
-endif.

-export([i/0, init/0, add_copy/0]).
-export([nodes/0, gateway_nodes/0, area_nodes/0, world_node/0]).
-export([add_gateway_node/1, add_area_node/1, set_world_node/1]).
-export([delete_gateway_node/1, delete_area_node/1]).

-define(WORLD_NODE, 'world_node').
-define(AREA_NODE, 'area_node').
-define(GATEWAY_NODE, 'gateway_node').

-define(TABLE, ?MODULE).

%% @doc 获取运行信息
i() ->
    [{nodes, ?MODULE:nodes()}].

%% @doc 初始化数据库
init() ->
    ?DEBUG(?_U("初始化节点数据表")),
    wg_mnesia:ensure_mnesia_is_running(),
    case wg_mnesia:is_table_exists(?TABLE) of
        true ->
            %?DEBUG("~p table exists", [?TABLE]),
            ok;
        false ->
            {atomic, ok} = mnesia:create_table(?TABLE,
                    [{type, set},
                    {ram_copies, [node() | erlang:nodes()]}
                    ]),
            ok
    end.

%% @doc 添加此表的copy到本节点
add_copy() ->
    case catch mnesia:add_table_copy(?TABLE, node(), ram_copies) of
        {atomic, ok} ->
            ok;
        _Other ->
            ?WARN(?_U("添加~p表的copy出错:~p"), [?TABLE, _Other]),
            ok
    end.
            
%% @doc 查询节点列表
nodes() ->
    WorldNode = world_node(),
    ?IF(WorldNode =:= ?NONE, [], [WorldNode]) ++
    area_nodes() ++
    gateway_nodes().

%% @doc 网管节点列表
gateway_nodes() ->
    case do_get(?GATEWAY_NODE) of
        ?NONE ->
            [];
        List ->
            List
    end.

%% @doc 地图节点列表
area_nodes() ->
    case do_get(?AREA_NODE) of
        ?NONE ->
            [];
        List ->
            List
    end.

%% @doc 世界节点(只有1个)
world_node() ->
    do_get(?WORLD_NODE).

%% @doc 添加网管节点
add_gateway_node(Node) when is_atom(Node) ->
    L = gateway_nodes(),
    Nodes = ?IF(lists:member(Node, L), L, [Node | L]),
    do_set(?GATEWAY_NODE, Nodes).

%% @doc 添加地图节点
add_area_node(Node) when is_atom(Node) ->
    L = area_nodes(),
    Nodes = ?IF(lists:member(Node, L), L, [Node | L]),
    do_set(?AREA_NODE, Nodes).

%% @doc 设置地图节点
set_world_node(Node) when is_atom(Node) ->
    ?ASSERT(world_node() =:= ?NONE),
    do_set(?WORLD_NODE, Node).

%% @doc 删除网关节点
delete_gateway_node(Node) when is_atom(Node) ->
    Nodes = lists:delete(Node, gateway_nodes()),
    do_set(?GATEWAY_NODE, Nodes).

%% @doc 删除地图节点
delete_area_node(Node) when is_atom(Node) ->
    Nodes = lists:delete(Node, area_nodes()),
    do_set(?AREA_NODE, Nodes).

%%-------------
%% internal API
%%-------------

%% 获取对应的数据
do_get(Key) ->
    case catch mnesia:dirty_read(?TABLE, Key) of
        [{?MODULE, _, Val}] ->
            Val;
        [] ->
            ?NONE;
        {'EXIT', {aborted, _Reason}} ->
            ?ERROR(?_U("获取节点数据出错，原因:~p"), [_Reason]),
            ?NONE 
    end.

%% 设置对应的值
do_set(Key, Val) ->
    case catch mnesia:dirty_write({?MODULE, Key, Val}) of
        ok ->
            ok;
        {'EXIT', {aborted, _Reason}} ->
            ?ERROR(?_U("写入节点数据出错，原因:~p"), [_Reason]),
            {error, _Reason}
    end.
