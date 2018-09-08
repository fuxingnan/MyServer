%%%----------------------------------------------------------------------
%%%
%%% @author fuxing
%%% @date  2012.04.18
%%% @doc 游戏玩家监控树
%%%
%%%
%%%
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(player_sup).
-behaviour(supervisor).
-include("wg.hrl").
-include("player_internal.hrl").

-export([start_link/0, init/1]).

%% @doc 开启监控树
start_link() ->
    supervisor:start_link({local, ?PLAYER_SUP}, ?MODULE, []).

%% @doc 监控树回调函数
init(_Args) ->
    {ok, {{simple_one_for_one, 10, 1},
        [{player_server, {player_server, start_link, []},
        temporary, 3000, worker, [player_server]}]}}.
