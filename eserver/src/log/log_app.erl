%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 日志app,在本地记录游戏日志
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(log_app).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").

-behaviour(application).
-behaviour(supervisor).

-export([start/0]).
-export([start/2, stop/1]).
-export([init/1]).

%% @doc start the application from the erl shell
start() ->
    wg_loglevel:set(?LOG_LEVEL),
    io:format("log_app:~p~n", [log_app]),
    ensure_apps(),
    application:start(log_app).

%% @doc the application start callback
start(_Type, _Args) ->
    ?INFO(?_U("启动log sup"), []),
    catch do_start(_Type, _Args).

%% @doc the application  stop callback
stop(_State) ->
    ?INFO(?_U("log app结束")),
    ok.

%% @doc supervisor callback
init(_Args) ->
    Stragegy = {one_for_one, 10, 10},
    % 启动空sup
    {ok, {Stragegy, []}}.

%%--------------
%% internal API
%%--------------

%% 启动application
do_start(_Type, _Args) ->
    {ok, Sup} = supervisor:start_link({local, log_sup}, ?MODULE, []),
    ?INFO(?_U("启动config server")),
    ok = game_misc:start_config_server(Sup),
    ok = game_misc:start_time_cache(Sup),
    ?INFO(?_U("启动逻辑log server"), []),
    start_logic_log_server(Sup),
    ?INFO(?_U("启动聊天log server"), []),
    start_chat_log_server(Sup),
    ?INFO(?_U("启动peer log")),
    start_peer_log_server(Sup),
    {ok, Sup}.

%% first ensure some apps must start
ensure_apps() ->
    ok = game_misc:handle_start_app(application:start(sasl)),
    ok.

%% 启动logic log server
start_logic_log_server(Sup) ->
    LogDir = ?CONF(log_dir, "/var/yulong/log"),
    [begin
        FileName = game_misc:logic_log_filename(LogName),
        LogFile = filename:join([LogDir, FileName]),
        Child = {LogName, {log_server, start_link, [LogName, LogFile]},
                    permanent, 2000, worker, [log_server]},
        game_misc:start_child(Sup, Child)
    end || LogName <- ?LOGIC_LOG_SERVER_LIST],
    ok.

%% 启动chat log server
start_chat_log_server(Sup) ->
    FileName = game_misc:chat_log_filename(),
    LogDir = ?CONF(chat_log_dir, "/var/yulong/chat_log"),
    LogFile = filename:join([LogDir, FileName]),
    Child = {?CHAT_LOG_SERVER, {log_server, start_link, [?CHAT_LOG_SERVER, LogFile]},
                permanent, 2000, worker, [log_server]},
    game_misc:start_child(Sup, Child).



%% 启动peer log server
start_peer_log_server(Sup) ->
    FileName = game_misc:peer_log_filename(),
    LogDir = ?CONF(peer_log_dir, "/var/yulong/peer_log"),
    LogFile = filename:join([LogDir, FileName]),
    Child = {?PEER_LOG_SERVER, {log_server, start_link, [?PEER_LOG_SERVER, LogFile]},
                permanent, 2000, worker, [log_server]},
    game_misc:start_child(Sup, Child).
