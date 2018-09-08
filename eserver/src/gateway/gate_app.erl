%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc gateway app and supervisor callback
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(gate_app).
-author("276300120@qq.com").
-vsn('1.0').
-include("wg.hrl").
-include("game.hrl").
-include("gate_internal.hrl").

-behaviour(application).
-behaviour(supervisor).

-export([start/0]).
-export([start/2, stop/1]).
-export([init/1]).

%% @doc start the application from the erl shell
start() ->
    wg_loglevel:set(?LOG_LEVEL),
    ?DEBUG("start the ~p application~n", [?MODULE]),
    try
        ensure_apps(),
        ok = application:start(gate_app)
    catch
        Type:Error ->
            ?ERROR(?_U("启动gate_app出错:~p:~p"), [Type, Error]),
            init:stop(?APP_GATEWAY)
    end.

%% @doc the application start callback
-spec start(Type :: any(), Args :: any()) -> any().
start(_Type, _Args) ->
    ok = game_misc:connect_world_node(),
    % case map_server:is_normal_map_started() of
    %     true ->
    %         ok;
    %     false ->
    %         ?ERROR(?_U("野外地图未全部启动,请确保area节点已正确启动")),
    %         ?EXIT(?APP_GATEWAY)
    % end,
    wg_mnesia:ensure_mnesia_is_running(),
    wg_mnesia:conn_nodes(erlang:nodes()),

    {ok, Sup} = supervisor:start_link({local, gate_sup}, ?MODULE, []),
    {ok, IpPort} = get_listen_ip_port(),

    ok = game_misc:start_config_server(Sup),
    %ok = game_misc:start_reloader_server(Sup),
    ok = game_misc:start_time_cache(Sup),
    %ok = game_alarm:init(),

    ok = start_gate_client_mgr(Sup),
    ok = start_listener(Sup, IpPort),
    ok = start_gate_node(Sup, IpPort),
    ok = game_misc:init_sys_data(),
    world_nodes:add_copy(),
    world_nodes:add_gateway_node(node()),
    %game_log:gateway_app(start),
    {ok, Sup}.

%% @doc the application  stop callback
stop(_State) ->
    ok.

%% @doc supervisor callback
init(_Args) -> 
    Stragegy = {one_for_one, 10, 10},
    {ok, {Stragegy, []}}.

%%
%% internal API
%%

%% first ensure some apps must start
ensure_apps() ->
    ok = game_misc:handle_start_app(application:start(sasl)),
    ok = game_misc:handle_start_app(db_app:start()),
    ok = game_misc:handle_start_app(player_app:start()),
    ok.

%% 启动监听
%% 为了防止某些玩家的80,433端口被封锁,监听多个端口
start_listener(Sup, IpPort) ->
    Max = ?CONF(gate_max, 3000),
    Opts = [{max, Max}, {active, once},{send_timeout, 5000}, {send_timeout_close, true}],
    Callback = {gate_client, start_link, []},
    ?INFO(?_U("启动端口监听 ~p 最大连接数:~p"), [IpPort, Max]),
    [begin
        Child = {Name, {wg_tcp_server, start_link,
                [Name, Ip, Port, raw, Callback, Opts]},
            permanent, infinity, supervisor, [wg_tcp_server]},
        game_misc:start_child(Sup, Child)
    end || {Name, Ip, Port} <- IpPort],
    ok.

%% 启动gate node
start_gate_node(Sup, IpPort) ->
    ?INFO(?_U("启动gate node")),
    Child = {gate_node, {gate_node, start_link, [IpPort]},
                permanent, 2000, worker, [gate_node]},
    game_misc:start_child(Sup, Child).

%% 启动client manager
start_gate_client_mgr(Sup) ->
    ?INFO(?_U("启动gate client mgr, sup:~p"), [Sup]),
    Child = {gate_client_mgr, {gate_client_mgr, start_link, []},
                permanent, 2000, worker, [gate_client_mgr]},
    case supervisor:start_child(Sup, Child) of
        {ok, _} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("启动gate client mgr失败:~p"), [_Reason]),
            ?EXIT(1)
    end.

%% 获取要监听的ip和端口
get_listen_ip_port() ->
    Ip = ?CONF(gate_ip, "0.0.0.0"),
    PortList = ?CONF(gate_port, [80, 443]),
    IpPort = 
    [{?S2A(?GATEWAY_TCP_SERVER ++ "_" ++ ?N2S(Port)), Ip, Port} || Port <- PortList],
    {ok, IpPort}.
