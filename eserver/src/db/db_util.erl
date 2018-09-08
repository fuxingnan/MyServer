%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2015.06.25
%%% @doc 数据库工具模块
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(db_util).
-author("huang.kebo@gmail.com").
-vsn('0.1').
-include("wg.hrl").
-include("db.hrl").

-export([encode/1]).
-export([where_player_id/1]).
-export([where_id/1]).

%% @doc 编码
encode(V) ->
    mysql:encode(V).

%% @doc 关于玩家的where条件
where_player_id(PlayerId) ->
    ["player_id=", db_util:encode(PlayerId)].

%% @doc sql需要的条件
where_id(Id) ->
    ["id=", db_util:encode(Id)].

