%%%----------------------------------------------------------------------
%%%
%%% @author 付星
%%% @date  2016.07.12
%%% @doc 单节点模式启动游戏
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(game).
-author("276300120qq.com").
-vsn('1.0').

-include("wg.hrl").

-export([start/0]).

%% @doc 启动游戏
start() ->
    game_ctl:init(),
    lists:foreach(
    fun(App) ->
        case catch App:start() of
            ok ->
                ?INFO(?_U("应用:~p 启动"), [App]),
                ok;
            {error, Reason} ->
                ?ERROR(?_U("应用:~p 启动失败:~p"), [App, Reason])
        end
    end, [world_app,gate_app]),
    ok.
