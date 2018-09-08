%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc player app，处理玩家逻辑app
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(player_app).
-include("wg.hrl").
-include("game.hrl").

-behaviour(application).
-behaviour(supervisor).

-export([start/0]).
-export([start/2, stop/1]).
-export([init/1]).

%% @doc start the application from the erl shell
start() ->
    ensure_apps(),
    wg_loglevel:set(?LOG_LEVEL),
    application:start(player_app).

%% @doc the application start callback
-spec start(Type :: any(), Args :: any()) -> any().
start(_Type, _Args) ->
    {ok, Sup} = supervisor:start_link({local, player_main_sup}, ?MODULE, []),

    % 启动player_sup
    ?DEBUG(?_U("启动玩家监督树"), []),
    PlayerSup = {player_sup, {player_sup, start_link, []},
        permanent, infinity, supervisor, [player_sup]},
    {ok, _Child} = supervisor:start_child(Sup, PlayerSup),


    ?INFO(?_U("启动玩家管理器")),
    PlayerMgr = {player_mgr, {player_mgr, start_link, []},
        permanent, 3000, worker, [player_mgr]},
    {ok, _} = supervisor:start_child(Sup, PlayerMgr),


    % % 启动robot_sup
    % ?DEBUG(?_U("启动机器人监督树"), []),
    % RobotSup = {newbie_robot_sup, {newbie_robot_sup, start_link, []},
    %     permanent, infinity, supervisor, [newbie_robot_sup]},
    % {ok, _} = supervisor:start_child(Sup, RobotSup),

    % ?DEBUG(?_U("启动机器人管理器，主要负责人数的控制")),
    % RobotMgr = {newbie_robot_mgr, {newbie_robot_mgr, start_link, []},
    %     permanent, 3000, worker, [newbie_robot_mgr]},
    % {ok, _} = supervisor:start_child(Sup, RobotMgr),

    ok = game_misc:start_game_hooks(Sup),

    ?INFO(?_U("初始化系统数据"), []),
    ok = game_misc:init_sys_data(),
    ok = game_misc:start_time_cache(Sup),
    
    ok = start_mods(),
    for(1,4,fun(I)-> start_server_newroom_robot(I) end),
    for(1,1,fun(I)-> start_server_ordinaryroom_robot(I) end),
    for(1,1,fun(I)-> start_server_masterroom_robot(I) end),
    %game_log:player_app(start),
    {ok, Sup}.

%% @doc the application  stop callback
stop(_State) ->
    ok = gen_mod:stop(),
    ok.

%% @doc supervisor callback
init(_Args) ->
    ?DEBUG("init supervisor~n", []),
    Stragegy = {one_for_one, 10, 10},
    % 启动空sup
    {ok, {Stragegy, []}}.

%%
%% internal API
%%

%% first ensure some apps must start
ensure_apps() ->
    ok = game_misc:handle_start_app(application:start(sasl)),
    ok = game_misc:handle_start_app(inets:start()),
    ok.

%% 启动所有的mods
start_mods() ->
    ok = gen_mod:start(),
    Mods = filelib:wildcard("ebin/mod_*.beam"),
    [begin
        Mod = list_to_atom(filename:basename(M, ".beam")),
        %?DEBUG("player mod:~p start", [Mod]),
        Mod:start()
    end || M <- Mods],
    ok.
start_server_newroom_robot(I)->
    Id = world_id:player(),
    room_friend_mgr:add_robot_id(Id),
    Robot = #robot{is_robot = true,id = Id,type = ?New_Room_Robot,state = ?Robot_Wait},

    case player_server:enter(Id, Robot, "") of
        {ok, _} ->
            ?DEBUG(?_U("机器人新手服务器开启成功~p"),[Id]),
            ok;
        {error, Code1} ->
            ?ERROR(?_U("机器人新手服务器开启失败:~p"), [Id, Code1]),
            ok
    end.

start_server_ordinaryroom_robot(I)->
    Id = world_id:player(),
    room_friend_mgr:add_robot_id(Id),
    Robot = #robot{is_robot = true,id = Id,type = ?Ordinary_Room_Robot,state = ?Robot_Wait},

    case player_server:enter(Id, Robot,"") of
        {ok, _} ->

            ?DEBUG(?_U("机器人客户端开启成功")),
            ok;
        {error, Code} ->
            ?ERROR(?_U("机器人客户端开启失败:~p"), [Id, Code]),
            % 向client发送错误消息
            ok
    end.

start_server_masterroom_robot(I)->
    NewId = world_id:player(),
    room_friend_mgr:add_robot_id(NewId),
    Robot = #robot{is_robot = true,id = NewId,type = ?Mastr_Room_Robot,state = ?Robot_Wait},

    case player_server:enter(NewId, Robot, "") of
        {ok, _} ->
            ?DEBUG(?_U("机器人富豪服务器开启成功")),
            ok;
        {error, Code1} ->
            ?ERROR(?_U("机器人富豪服务器开启失败:~p"), [NewId, Code1]),
            ok
    end.

for(Max,Max,F)->
    [F(Max)];
for(I,Max,F)->
    [F(I)|for(I+1,Max,F)].