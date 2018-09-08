%%%----------------------------------------------------------------------
%%%
%%% @author 付星
%%% @date  2016.07.12
%%% @doc world app
%%% *注意* 现在world中的mnesia table均是只在world节点中存储了一份
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(world_app).
-author("276300120@qq.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").

-behaviour(application).
-behaviour(supervisor).

-export([start/0]).
-export([start/2, stop/1,msgEncrypt/2,msgDecrypt/2,load_niff/0]).
-export([init/1]).


msgEncrypt(_Str,_D) ->
    io:format("this function is not defined!~n").
msgDecrypt(_Str,_D) ->
    io:format("this function is not defined!~n").
load_niff()->
    NifRes = erlang:load_nif("etc/niftest", 0),
    ?DEBUG(?_U("加载nif库~p"), [NifRes]).
%% @doc start the application from the erl shell
start() ->
    wg_loglevel:set(?LOG_LEVEL),
    ?INFO(?_U("come 1"), []),
    try
        ensure_apps(),
        ok = application:start(world_app)
    catch
        Type:Error ->
            ?ERROR(?_U("启动world_app出错:~p:~p"), [Type, Error]),
            init:stop(?APP_WORLD)
    end.

%% @doc the application start callback
start(_Type, _Args) ->
    ?INFO(?_U("come 2"), []),
    catch do_start(_Type, _Args).
do_start(_Type, _Args) ->
    NifRes = erlang:load_nif("etc/niftest", 0),
    ?DEBUG(?_U("加载nif库~p"), [NifRes]),

    wg_mnesia:ensure_mnesia_is_running(),
    ?INFO(?_U("初始化系统数据"), []),
    ok = game_misc:init_sys_data(),

    ?INFO(?_U("world node数据初始化")),
    ok = world_nodes:init(),

    ?INFO(?_U("启动运行时数据"), []),
    ok = world_data:init(),
    
    ?INFO(?_U("启动键值对数据"), []),
    %ok = world_data_disk:init(),

    ?INFO(?_U("启动全局id管理器"), []),
    ok = world_id:init(),

    ?INFO(?_U("启动在线玩家管理器"), []),
    ok = world_online:init(),


    ?INFO(?_U("启动gm_ctrl"), []),
    ok = gm_ctrl:init(),

    ?INFO(?_U("启动world sup"), []),
    {ok, Sup} = supervisor:start_link({local, world_sup}, ?MODULE, []),

    game_misc:start_config_server(Sup),
    CronFile = game_path:conf_file("world.crontab"),
    %ok = game_misc:start_cron_server(Sup, CronFile),
    ok = game_misc:start_reloader_server(Sup),
    ok = game_misc:start_time_cache(Sup),
    %ok = game_alarm:init(),

    ?INFO(?_U("启动房间管理器"), []),
    start_new_room_mgr(Sup),
    start_ordinary_room_mgr(Sup),
    start_master_room_mgr(Sup),
    start_friend_room_mgr(Sup),
    start_rank_mgr(Sup),
    start_ken_friend_room_mgr(Sup),
    world_nodes:set_world_node(node()),
    %game_log:world_app(start),
    wg_mnesia:info(),
    {ok, Sup}.

%% @doc the application  stop callback
stop(_State) ->
    ?WARN(?_U("**world服务停止")),
    world_data_disk:sync(),
    ok.

%% @doc supervisor callback
init(_Args) ->
    Stragegy = {one_for_one, 10, 10},
    % 启动空sup
    {ok, {Stragegy, []}}.

%%--------------
%% internal API
%%--------------

%% first ensure some apps must start
ensure_apps() ->
    ok = game_misc:handle_start_app(db_app:start()),
    %ok = game_misc:handle_start_app(log_app:start()),
    ok.

%% 启动notice进程
start_notice(Sup) ->
    Child = {world_notice, {world_notice, start_link, []},
         permanent, brutal_kill, worker, [world_notice]},
    game_misc:start_child(Sup, Child).

%% 启动team_mgr进程
start_new_room_mgr(Sup) ->
    Child = {room_newplayer_mgr, {room_newplayer_mgr, start_link, []},
        permanent, brutal_kill, worker, [room_newplayer_mgr]},
    game_misc:start_child(Sup, Child).

start_ordinary_room_mgr(Sup) ->
    Child = {room_ordinary_mgr, {room_ordinary_mgr, start_link, []},
        permanent, brutal_kill, worker, [room_ordinary_mgr]},
    game_misc:start_child(Sup, Child).

start_friend_room_mgr(Sup) ->
    Child = {room_friend_mgr, {room_friend_mgr, start_link, []},
        permanent, brutal_kill, worker, [room_friend_mgr]},
    game_misc:start_child(Sup, Child).

start_ken_friend_room_mgr(Sup) ->
    Child = {ken_room_mgr, {ken_room_mgr, start_link, []},
        permanent, brutal_kill, worker, [ken_room_mgr]},
    game_misc:start_child(Sup, Child).

start_master_room_mgr(Sup) ->
    Child = {room_master_mgr, {room_master_mgr, start_link, []},
        permanent, brutal_kill, worker, [room_master_mgr]},
    game_misc:start_child(Sup, Child).

%% 启动rank进程
start_rank_mgr(Sup) ->
    Child = {rank, {rank, start_link, []},
        permanent, brutal_kill, worker, [rank]},
    game_misc:start_child(Sup, Child).
%% 启动运维平台对应的httpd服务
%% start_admin_httpd(Sup) ->
%%     Ip = ?CONF(world_api_ip, "127.0.0.1"),
%%     Port = ?CONF(world_api_port, 8888),
%%     Opts = [{name, game_api_httpd}, {ip, Ip}, {port, Port}],
%%     WWW = "",
%%     Child = {wg_httpd, {wg_httpd, start_link, [Opts, [], WWW]},
%%                 permanent, brutal_kill, worker, [wg_httpd]},
%%     game_misc:start_child(Sup, Child).

%% 启动master 进程
start_master_mgr(Sup) ->
    Child = {master_mgr, {master_mgr, start_link, []},
        permanent, 5000, worker, [master_mgr]},
    game_misc:start_child(Sup, Child).

%% 启动guild 进程
start_guild_mgr(Sup) ->
    Child = {guild_mgr, {guild_mgr, start_link, []},
        permanent, 5000, worker, [guild_mgr]},
    game_misc:start_child(Sup, Child).

%% 启动player_attribs 进程
start_player_attribs_mgr(Sup) ->
    Child = {player_attribs_mgr, {player_attribs_mgr, start_link, []},
        permanent, 5000, worker, [player_attribs_mgr]},
    game_misc:start_child(Sup, Child).


