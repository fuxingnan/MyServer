%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 关于计数数据库相关操作
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(db_counter).
-author("huang.kebo@gmail.com").
-vsn('0.1').
-include("wg.hrl").
-include("common.hrl").
-include("errno.hrl").
-include("db.hrl").

-export([add/1, load/0, load/1, save/2, delete/1, inc_counter_x/2]).

-define(TABLE, "counter").

%% counter所有持久化字段
-define(FULL_FIELDS, 
    ["player_id", "data"]).

%% @doc 添加默认记录
add(PlayerId) ->
    case ?DB_GAME:insert(?TABLE, [PlayerId, do_encode([])]) of
        {updated, _} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("玩家:~p创建计数记录失败:~p"),
                [PlayerId, _Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 加载玩家计数
load() ->
    case ?DB_GAME:select(?TABLE, ["player_id","data"], []) of
        {selected, _, []} ->
            [];
        {selected, _, Rows} ->
            [{Id,do_decode(Data)} || [Id, Data] <- Rows];
        {error, _Reason} ->
            ?ERROR(?_U("COUNTER加载失败:~p"),
                [_Reason]),
            ?C2SERR(?E_DB)
    end.
    
load(PlayerId) ->
    case ?DB_GAME:select(?TABLE, ["data"], where(PlayerId)) of
        {selected, _, []} ->
            [];
        {selected, _, [[Data]]} ->
            do_decode(Data);
        {error, _Reason} ->
            ?ERROR(?_U("玩家:~p加载失败:~p"),
                [PlayerId, _Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 存储玩家计数
save(PlayerId, List) ->
    Data = do_encode(List),
    case ?DB_GAME:update(?TABLE, ["data"], [Data], where(PlayerId)) of
        {updated, _} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("存储玩家:~p计数数据失败:~p"), 
                    [PlayerId, _Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 删除玩家计数
delete(PlayerId) ->
    case ?DB_GAME:delete(?TABLE, where(PlayerId)) of
        {updated, _N} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("删除玩家:~p计数数据失败:~p"), 
                    [PlayerId, _Reason]),
            ?C2SERR(?E_DB)
    end.

% 增加某个counter值
inc_counter_x(Id, Counter) ->
    CounterList = load(Id),
    NewList = 
    case lists:keytake(Counter,1,CounterList) of
        false ->
            [{Counter,1}|CounterList];
        {value, {Counter, N}, CounterList2} ->
            [{Counter, N + 1} |CounterList2]
    end,

    Data = do_encode(NewList),
    case ?DB_GAME:update(?TABLE, ["data"], [Data], where(Id)) of
        {updated, _} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("存储玩家:~p计数数据失败:~p"), 
                    [Id, _Reason]),
            ?C2SERR(?E_DB)
    end.

%%--------------------
%% Internal API
%%--------------------

%% 条件
where(PlayerId) ->
    ["player_id=", db_util:encode(PlayerId)].

%% 数据编码(json)
do_encode([]) ->
    <<>>;
do_encode(List) ->
    List2 =
    [[K, V] || {K, V} <- List],
    ejson:encode(List2).

%% 数据解码(json)
do_decode(<<>>) ->
    [];
do_decode(Data) ->
    List = ejson:decode(Data),
    [{Key, Value} || [Key, Value] <- List].
