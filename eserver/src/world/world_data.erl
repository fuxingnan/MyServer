%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 为玩家提供服务器运行期间的数据保存服务。
%%%     *要求*:
%%%         1,非重要数据
%%%         2,不用持久化
%%%         3,服务器重启数据丢失
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(world_data).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").
-include("world.hrl").
-include("common.hrl").

-ifdef(TEST).
-compile([export_all]).
-endif.

-export([i/0]).
-export([init/0, list/0, count/0, get/1, set/2, delete/1]).

%% 数据库名称
-define(TABLE, ?MODULE).

%% @doc 获取运行信息
i() ->
    [{size, count()}].

%% @doc 初始化数据库
init() ->
    ?DEBUG(?_U("初始化运行时数据表")),
    wg_mnesia:ensure_mnesia_is_running(),
    case wg_mnesia:is_table_exists(?TABLE) of
        true ->
            %?DEBUG("~p table exists", [?TABLE]),
            ok;
        false ->
            {atomic, ok} = mnesia:create_table(?TABLE,
                    [{type, set},
                    {ram_copies, [node()]},
                    {attributes, record_info(fields, world_data)}]),
            ok
    end.

%% @doc 获取列表
list() ->
    Pattern = wg_mnesia:wild_pattern(?TABLE),
    mnesia:dirty_match_object(Pattern).

%% @doc 总数
count() ->
    wg_mnesia:tab_size(?TABLE).

%% @doc 获取对应的数据
get(Key) ->
    case catch mnesia:dirty_read(?TABLE, Key) of
        [#world_data{val = Val}] ->
            Val;
        [] ->
            ?NONE;
        {'EXIT', {aborted, _Reason}} ->
            ?ERROR(?_U("获取运行数据表出错，原因:~p"), [_Reason]),
            ?NONE 
    end.

%% @doc 设置对应的值
set(Key, Val) ->
    %?DEBUG(?_U("运行数据表中设置key:~w 值为:~w"), [Key, Val]),
    case catch mnesia:dirty_write(#world_data{key = Key, val = Val}) of
        ok ->
            ok;
        {'EXIT', {aborted, _Reason}} ->
            ?ERROR(?_U("运行数据表写入出错，原因:~p"), [_Reason]),
            {error, _Reason}
    end.

%% @doc 删除对应的数据
delete(Key) ->
    ?DEBUG(?_U("运行数据表中删除key:~w"), [Key]),
    case catch mnesia:dirty_delete(?TABLE, Key) of
        ok ->
            ok;
        {'EXIT', {aborted, _Reason}} ->
            ?ERROR(?_U("运行数据表删除出错，原因:~p"), [_Reason]),
            {error, _Reason}
    end.

%%-------------
%% internal API
%%-------------

%%-------------
%% EUNIT test
%%-------------
-ifdef(EUNIT).

d_1() ->
    #world_data{key = 1, val = 10}.

d_2() ->
    #world_data{key = 2, val = 20}.

full_test_() ->
    {spawn, {setup,
    fun() -> init() end,
    fun(_) -> mnesia:stop() end,
    [
        ?_assertEqual([], list()),
        ?_assertEqual(0, count()),
        ?_assertEqual(?NONE, ?MODULE:get(1)),

        % 设置
        ?_assertEqual(ok, set(1, 10)),
        ?_assertEqual(ok, set(2, 20)),
        ?_assertEqual([d_1(), d_2()], lists:sort(list())),
        ?_assertEqual(2, count()),

        % 查询
        ?_assertEqual(10, ?MODULE:get(1)),
        ?_assertEqual(20, ?MODULE:get(2)),

        % 删除
        ?_assertEqual(ok, delete(1)),
        ?_assertEqual([d_2()], lists:sort(list())),
        ?_assertEqual(1, count()),
        ?_assertEqual(ok, delete(2)),
        ?_assertEqual([], list()),
        ?_assertEqual(0, count()),

        % 模式删除
        ?_assertEqual(ok, set({1, "tag"}, 100)),
        ?_assertEqual(ok, set({2, "tag"}, 200)),
        ?_assertEqual(100, ?MODULE:get({1, "tag"})),
        ?_assertEqual(200, ?MODULE:get({2, "tag"})),
        ?_assertEqual(ok, wg_mnesia:dirty_delete_by_pattern(#world_data{key = {'_', "tag"}, _ = '_'})),
        ?_assertEqual([], list()),
        ?_assertEqual(0, count())
    ]}}.

-endif.
