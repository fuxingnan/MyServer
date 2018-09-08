%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc  日志数据表操作
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(db_log).
-author("huang.kebo@gmail.com").

-include("wg.hrl").
-include("game.hrl").
-include("db.hrl").

-compile([export_all]).

%% @doc 金币相关日志
-define(FIELDS_GOLD, 
    ["player_id", "name", "time", "accname", "lvl", "gold", "gold_bind",
        "event", "detail", "goods_uniq_id", "goods_type_id", "goods_num"]).
gold(Args) ->
    ?ASSERT(length(?FIELDS_GOLD) =:= length(Args)),
    case ?DB_GAME:insert("t_log_gold", ?FIELDS_GOLD, Args) of
        {updated, 1} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("新增金币日志,失败:~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 银币相关日志
-define(FIELDS_SILVER, 
    ["player_id", "name", "time", "silver", "silver_bind",
        "event", "detail", "goods_id", "goods_type", "goods_num"]).
silver(Args) ->
    ?ASSERT(length(?FIELDS_SILVER) =:= length(Args)),
    case ?DB_GAME:insert("t_log_silver", ?FIELDS_SILVER, Args) of
        {updated, 1} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("新增银币日志,失败:~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 物品相关日志
-define(FIELDS_GOODS, 
    ["player_id", "lvl", "event", 
    "event", "detail", "goods_id", "goods_type", "goods_num",
    "quality", "start_time", "expire_time"]).
goods(Args) ->
    ?ASSERT(length(?FIELDS_GOODS) =:= length(Args)),
    case ?DB_GAME:insert("t_log_goods", ?FIELDS_GOODS, Args) of
        {updated, 1} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("新增物品日志,失败:~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 在线人数日志
-define(FIELDS_ONLINE, 
    ["node", "online", "timestamp", "dow", "year", "month", "day", "hour", "min"]).
online(Now, Online) when is_integer(Now), is_integer(Online) ->
    {{Year, Mon, Day} = Date, {Hour, Min, _}} = calendar:universal_time(),
    Dow = calendar:day_of_the_week(Date),
    Args = [?A2S(node()), Online, Now, Dow, Year, Mon, Day, Hour, Min],
    case ?DB_GAME:insert("t_log_online", ?FIELDS_ONLINE, Args) of 
        {updated, 1} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("新增在线人数日志,失败:~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%%--------------
%% Internal API
%%--------------
