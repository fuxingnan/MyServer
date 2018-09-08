%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 世界中所有在线玩家信息
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(world_online).
-author("276300120@qq.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").
-include("player.hrl").

-ifdef(TEST).
-compile([export_all]).
-endif.

-export([i/0]).
-export([init/0, list/0, id_list/0, count/0, count2/0]).
-export([add/1, update/1, delete/1]).
-export([get_by_id/1, get_by_name/1, get_id_by_name/1]).

-export([save_id_list/0]).
%% 数据库名称
-define(TABLE, world_online).

%% 当前玩家保存路径
-define(LAST_PLAYER_IDS, ?CONF(last_players, ".")).
%% @doc 获取运行信息
i() ->
    [{player_count, count()},
    {player_list, id_list()}].
    
%% @doc 初始化数据库
init() ->
    %?DEBUG(?_U("初始化在线玩家数据库")),
    wg_mnesia:ensure_mnesia_is_running(),
    [begin
        case wg_mnesia:is_table_exists(Tab) of
            true ->
                ok;
            false ->
                %?DEBUG(?_U("初始化在线玩家数据库~p"),TabDef)
                {atomic, ok} = mnesia:create_table(Tab, TabDef)
        end
    end || {Tab, TabDef} <- table_definitions()],
    ok.

%% @doc 获取在线列表
list() ->
     wg_mnesia:dirty_tab2list(?TABLE).

%% @doc 获取在线玩家id列表
id_list() ->
    [Id || #player{id = Id} <- wg_mnesia:dirty_tab2list(?TABLE)].

%% @doc 总数
count() ->
    case world_misc:is_start_newbie_robot() of
        true ->
            wg_mnesia:tab_size(?TABLE) - world_misc:calc_newbie_count();
        false ->
            wg_mnesia:tab_size(?TABLE)
    end.

%% @doc 总数
count2() ->
    wg_mnesia:tab_size(?TABLE).

%% @doc 玩家上线,添加到数据库
add(#player{} = Player) ->
    case catch mnesia:dirty_write(?TABLE, Player) of
        ok ->
            ok;
        _Reason ->
            ?ERROR(?_U("在线表中更新玩家~p失败:~p"), [Player#player.id, _Reason]),
            ?C2SERR(?E_UNKNOWN)
    end.

%% @doc 更新玩家数据
update(Player) ->
    add(Player).

%% @doc 玩家离线则删除
delete(PlayerId) when is_integer(PlayerId) ->
    %?INFO(?_U("delete玩家hook"), []),
    Fun =
    fun
        () ->
            ok = mnesia:delete({?TABLE, PlayerId})
    end,
    case mnesia:transaction(Fun) of
        {atomic, ok} ->
            ok;
        {aborted, _Reason} ->
            ?ERROR(?_U("在线表中删除玩家~w失败:~p"), [PlayerId, _Reason]),
            ?C2SERR(?E_UNKNOWN)
    end.

%% @doc 根据id获取
get_by_id(Id) when is_integer(Id) ->
    case catch mnesia:dirty_read(?TABLE, Id) of
        [Player] ->
            Player;
        [] ->
            ?NONE
    end.

%% @doc 根据名字获取
get_by_name(Name) when is_binary(Name) ->
    {ok,todo}.


%% @doc 根据名字获取id
get_id_by_name(Name) when is_binary(Name) ->
    {ok,todo}.

save_id_list() ->
    %?DEBUG("current ids:~p~n", [id_list()]),
    IdList = id_list(),
    StrIds = [io_lib:format("~p",[Id]) || Id <- IdList],
    file:write_file(?LAST_PLAYER_IDS, string:join(StrIds, ",")).

%%-------------
%% internal API
%%-------------

%% 数据库定义
table_definitions() ->
    [{?TABLE,
        [{attributes, record_info(fields, player)},
        {record_name, player},
        {index, [#player.id]},
        {ram_copies, [node()]},
        {type, set}]}
    ].

%%-------------
%% EUNIT test
%%-------------
-ifdef(EUNIT).

p_1() ->
    #player{id = 1}.

p_2() ->
    #player{id = 2}.

full_test_() ->
    {spawn, {setup,
    fun() -> init() end,
    fun(_) -> mnesia:stop() end,
    [
        ?_assertEqual([], list()),
        ?_assertEqual(0, count()),

        % 添加
        ?_assertEqual(ok, add(p_1())),
        ?_assertEqual(ok, add(p_2())),
        ?_assertEqual([p_1(), p_2()], lists:sort(list())),
        ?_assertEqual(2, count()),

        % 删除
        ?_assertEqual(ok, delete(1)),
        ?_assertEqual([p_2()], lists:sort(list())),
        ?_assertEqual(1, count()),
        ?_assertEqual(ok, delete(2)),
        ?_assertEqual([], list()),
        ?_assertEqual(0, count())
    ]}}.

-endif.
