%% 玩家进程测试
-module(player_SUITE).
-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include("game.hrl").
-include("test.hrl").
-include("wg.hrl").
-include("player.hrl").

suite() -> [
    {timetrap,{minutes,2}}
    ].

init_per_suite(Config) ->
    crypto:start(),
    wg_loglevel:set(5),
    ?DEBUG("cwd is :~p", [file:get_cwd()]),
    util:setup_db(),
    {ok, _ConfPid} = wg_config:start(?CONF_SERVER, "hz.conf"),
    ?DEBUG("mysql process:~p", [util:mysql_pid()]),
    % 创建用户
    {ok, Pid} = player_server:start_link({new, 15000}),
    [{player, Pid} | Config].

end_per_suite(Config) ->
    Pid = ?config(player, Config),
    crypto:stop(),
    util:stop_db(),
    exit(Pid, kill),
    wg_config:stop(?CONF_SERVER),
    ok.

init_per_testcase(Name, Config) ->
    io:format("..init ~p~n~p~n", [Name, Config]),
    Config.

end_per_testcase(Name, Config) ->
    io:format("...end ~p~n~p~n", [Name, Config]),
    ok.

all() ->
    [
        test_player
    ].

%%-------------------------------------------------------------------------
%% Test cases starts here.
%%-------------------------------------------------------------------------

test_player(Config)->
    Pid = ?config(player, Config),
    ?DEBUG(?_U("**********玩家进程:~p"), [Pid]),
    ok.
