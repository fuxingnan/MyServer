%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2011.08.12
%%% @doc 玩家计数器相关的工具模块
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(player_counter_util).
-include("wg.hrl").
-include("game.hrl").
-include("counter.hrl").
-include("player_internal.hrl").

-export([clear_from_world_daily/2]).

%% @doc 从world_daily中删除某个key(玩家不在线时使用)
clear_from_world_daily(PlayerId, Key) ->
    ?DEBUG(?_U("从world_daily中删除玩家:~p的key:~p"), [PlayerId, Key]),
    case world_daily:get(PlayerId) of
        ?NONE ->
            ok;
        List ->
            List2 = lists:keydelete(Key, 1, List),
            world_daily:set(PlayerId, List2)
    end.

%% @doc 

%%----------------
%% internal API
%%----------------
