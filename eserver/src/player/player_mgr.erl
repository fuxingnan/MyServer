%%%----------------------------------------------------------------------
%%%
%%% @author fuxing
%%% @date  2014.04.18
%%% @doc 玩家进程管理器，位于每个节点。其用来负责玩家进程的创建和
%%%     玩家切换地图时玩家数据的中转。
%%%
%%%      使用ets用来保存本节点上的在线玩家,替代全局的world_online的功能,
%%%      由player_server调用 
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(player_mgr).
-author("276300120@qq.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").
-include("gate.hrl").
-include("player_internal.hrl").
-behaviour(gen_server).

-export([i/0, player_list/0]).
-export([start_link/0]).
-export([new/3, new_robot/3,migrate/2]).

-export([list/0, add/1, update/1, delete/1]).
%% *注意* 不要直接调用下面函数!请使用player_server相关函数
-export([get_by_id/1, get_name_by_id/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

%% 在线玩家列表
-define(TABLE_PLAYER, 'player').

%% @doc 所有玩家信息
i() ->
    L = player_list(),
    [
    {player_count, length(L)},
    {player_pid_list, L}
    ].

%% @doc 玩家进程列表
player_list() ->
    [Child || {_Id, Child, worker, _} <- supervisor:which_children(?PLAYER_SUP)].

%% @doc 启动player manager
start_link()->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% @doc 在Node上启动一个新的player
new(Node, Id, Args) when is_integer(Id) ->
    case catch call(Node, {new, Id, Args}) of
        {ok, Pid} ->
            {ok, Pid};
        {'EXIT', {timeout, _}} ->
            {error, ?E_UNKNOWN};
        _Other ->
            _Other
    end.

%% @doc 在Node上启动一个新的player
new_robot(Node, Id, Args) when is_integer(Id) ->
    case catch call(Node, {new_robot, Id, Args}) of
        {ok, Pid} ->
            {ok, Pid};
        {'EXIT', {timeout, _}} ->
            {error, ?E_UNKNOWN};
        _Other ->
            _Other
    end.


%% @doc 将玩家数据迁移到Node
%% Node为player mgr所在节点，Data为对应的数据
migrate(Node, Data) ->
    call(Node, {migrate, Data}).

%% @doc 获取玩家列表
list() ->
    ets:tab2list(?TABLE_PLAYER).

%% @doc 玩家登录,添加数据
add(#player{} = Player) ->
    do_add(Player).

%% @doc 玩家数据更新
update(#player{} = Player) ->
    do_update(Player).

%% @doc 玩家退出,删除数据
delete(Id) when is_integer(Id) ->
    do_delete(Id).

%% @doc 查询玩家
get_by_id(Id) when is_integer(Id) ->
    case catch ets:lookup(?TABLE_PLAYER, Id) of
        [#player{} = Player] ->
            Player;
        _ ->
            ?NONE
    end.

%% @doc 获取玩家的name
get_name_by_id(Id) when is_integer(Id) ->
    todo.

%%--------------------
%% gen_server回调函数
%%--------------------

init(_Args) ->
    %?DEBUG("init the player_mgr", []),
    erlang:process_flag(trap_exit, true),
    erlang:process_flag(priority, high),
    do_crate_table(),
    {ok, []}.

handle_call({new, Id, Args}, _From, State) ->
    % 启动一个新的进程
    Reply = do_new(Id, Args),
    {reply, Reply, State};
handle_call({new_robot, Id, Args}, _From, State) ->
    % 启动一个新的进程
    Reply = do_new_robot(Id, Args),
    {reply, Reply, State};

handle_call({migrate, Data}, _From, State) -> 
    % 启动一个新的进程 
    Reply = do_migrate(Data), 
    {reply, Reply, State};
handle_call(_Msg, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ?WARN(?_U("player mgr结束:~p"), [_Reason]),
    ok.

code_change(_Old, State, _Extra) ->
    {ok, State}.

%%---------------------------
%% internal API
%%---------------------------

%% 请求
%call(Req) ->
%    gen_server:call(?SERVER, Req, ?GEN_TIMEOUT).

call(Node, Req) ->
    gen_server:call({?SERVER, Node}, Req, 30000).

%% 启动一个player进程
do_new(Id, Args) ->
    %?INFO(?_U("启动新的玩家逻辑进程:~p"), [Id]),
    case supervisor:start_child(?PLAYER_SUP, [{?NEW, Id, Args}]) of
       {error, {already_started, _Pid}} ->
           {logined, _Pid};
       {ok, Pid} ->
           {ok, Pid};
       {error, _Reason} ->
           ?ERROR(?_U("启动玩家:~p进程,系统错误:~p"), [Id, _Reason]),
           {error, ?E_UNKNOWN}
    end.

%% 启动一个robot    进程
do_new_robot(Id, Args) ->
    ?INFO(?_U("启动电脑玩家逻辑进程:~p"), [Id]),
    case supervisor:start_child(?ROBOT_SUP, [{?NEW, Id, Args}]) of
        {error, {already_started, _Pid}} ->
            {logined, _Pid};
        {ok, Pid} ->
            {ok, Pid};
        {error, _Reason} ->
            ?ERROR(?_U("启动电脑玩家:~p进程,系统错误:~p"), [Id, _Reason]),
            {error, ?E_UNKNOWN}
    end.

%% 进行玩家的数据迁移
do_migrate(Data) ->
    ?INFO(?_U("玩家迁移数据:~p"), [Data]),
    supervisor:start_child(?PLAYER_SUP, [{?MIGRATE, Data}]).

%% 添加玩家
do_add(Player) ->
    %?DEBUG(?_U("添加玩家:~p"), [Player#player.id]),
    ets:insert(?TABLE_PLAYER, Player),
    ok.

%% 更新玩家
do_update(Player) ->
    %?DEBUG(?_U("更新玩家:~p"), [Player#player.id]),
    ets:insert(?TABLE_PLAYER, Player),
    ok.

%% 删除玩家
do_delete(Id) ->
    %?DEBUG(?_U("删除玩家:~p"), [Id]),
    ets:delete(?TABLE_PLAYER, Id),
    ok.

%% 创建table
do_crate_table() ->
    ?TABLE_PLAYER = ets:new(?TABLE_PLAYER, [set, named_table, public, 
            {keypos, #player.id},
            {read_concurrency, true}
        ]),
    ok.

%%-------------
%% EUNIT test
%%-------------

-ifdef(EUNIT).
p1() ->
    #player{id = 1,
        name = <<"p1">>
    }.
p2() ->
    #player{id = 2,
        name = <<"p2">>
    }.

full_test_() ->
    {spawn, {setup,
    fun() -> start_link() end,
    fun({ok, Pid}) -> erlang:exit(Pid, kill) end,
    [
        ?_assertEqual([], list()),

        % 添加
        ?_assertEqual(ok, add(p1())),
        ?_assertEqual([p1()], list()),
        ?_assertEqual(ok, add(p2())),
        ?_assertEqual([p1(), p2()], lists:sort(list())),
        
        % 查询
        ?_assertEqual(p1(), get_by_id(1)),
        ?_assertEqual(<<"p2">>, get_name_by_id(2)),
        ?_assertEqual(?NONE, get_by_id(100)),
        ?_assertEqual(?NONE, get_name_by_id(100)),

        % 更新
        ?_assertEqual(ok, update((p1())#player{name = <<"p1-new">>})),
        ?_assertEqual((p1())#player{name = <<"p1-new">>}, get_by_id(1)),

        % 删除
        ?_assertEqual(ok, delete(1)),
        ?_assertEqual(?NONE, get_by_id(1)),
        ?_assertEqual(ok, add(p1())),
        ?_assertEqual(ok, delete(2)),
        ?_assertEqual(p1(), get_by_id(1))
    ]}}.

-endif.
