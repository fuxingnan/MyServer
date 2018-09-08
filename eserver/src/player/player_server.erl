%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 模拟游戏中的玩家，其处理gate_client的请求。玩家具有唯一的角色id
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(player_server).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").
-include("counter.hrl").
-include("gate.hrl").
-include("player_internal.hrl").
-include("world_api.hrl").
-include("room.hrl").
-behaviour(gen_server).

-export([start_link/1, start/1]).

%% 供gateway使用
-export([stopAllRobot/0,enter/3, process/4, kick_offline/1,set_old_rank/1]).
%% 获取视野或场景内玩家
-export([sight/3, sight_exclude/4, all_exclude/2]).

-export([i/1, p/1, get_state/1, 
        pid/1, is_online/1, is_in_map/2]).
-export([get/1, get_multi/1, get_not_dead/1,
        get_name/1, get_by_name/1, get_id_by_name/1]).

-export([s2s_cast/3, s2s_call/3, stop/1, stop/2, sync_stop/1
    ]).

%% 进程内使用(player_serever及其他mod_xxx)
-export([gather_data/1, trans_player_msg/1]).

%% 测试使用
-export([apply/2, equip/3, timer_list/1, client_msg/4, stop_move/1]).

%% 玩家交易
-export([trade_event_sync/2, trade_event_async/2]).

%% 后台定时任务函数
-export([clear_counter/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%%----------
%% 宏定义
%%----------

%% 名字
-define(START_NAME(Id), ({global, game_misc:player_name(Id)})).
-define(NAME(Id), ?START_NAME(Id)).

%% spawn opt
-define(SPAWN_OPT, [{min_heap_size, 102400}, {min_bin_vheap_size, 102400}]).

%% @doc 开启一个游戏玩家(由player_sup调用)
start_link({new, Id, _Data} = Args)->
    gen_server:start_link(?START_NAME(Id), ?MODULE, Args, [{spawn_opt, ?SPAWN_OPT}]);
start_link({migrate, _Data} = Args) ->
    gen_server:start_link(?MODULE, Args, [{spawn_opt, ?SPAWN_OPT}]).

%% @doc 启动玩家进程(测试使用!)
start(Id) when is_integer(Id) ->
    ?IF(player_server:is_online(Id), 
        ?ERROR(?_U("玩家:~p已经登录"), [Id]), ok),
    player_server:enter(Id, undefined, ?NONE).

%% @doc 玩家进入游戏
enter(Id, Client, Ip) ->
    % {ok, Node, Data} = (catch player_internal:select_target_map(Id)),
    do_enter(erlang:node(), Id, {Client, Ip}, 1).

%% @doc 处理client状态(PLAYING)下的所有请求
process(Mod, Req, MsgId, Player) when is_pid(Player) ->
    cast(Player, {c2s, Mod, Req, MsgId}).

%% @doc 将玩家提下线
kick_offline(Id) ->
    call(Id, kick_offline).

%% @doc 交易事件同步调用
trade_event_sync(Id, Event)->
    s2s_call(Id, mod_trade, Event).

%% @doc 交易事件异步调用
trade_event_async(Id, Event) ->
    s2s_cast(Id, mod_trade, Event).


%% 获取视野内玩家 #player
sight(MapKey, X, Y) ->
    Ids = map_server:sight_user(MapKey, X, Y),
    get_multi(Ids).

%% 获取视野内除却Exclude的玩家 #player
sight_exclude(MapKey, X, Y, Exclude) ->
    Ids = map_server:sight_user(MapKey, X, Y),
    get_multi(Ids -- [Exclude]).

%% 获取场景内除却Exclude的玩家 #player
all_exclude(MapKey, Exclude) ->
    case catch map_server:all_user(MapKey) of
        {'EXIT', _} ->
            [];
        Ids ->
            get_multi(Ids -- [Exclude])
    end.

%%------------
%% 查询相关
%%------------

%% @doc 获取玩家信息
i(Id) ->
    call(Id, i).

p(Id) ->
    L = i(Id),
    do_p(L).

%% @doc 获取某个玩家数据(gen_server call)
get_state(Id) when is_integer(Id) ->
    case catch call(Id, get_state) of
        {'EXIT', _Reason} ->
            %?DEBUG(?_U("获取玩家:~p state出错:~p"), [Id, _Reason]),
            ?NONE;
        Player ->
            Player
    end.

%% @doc 获取某个玩家数据
%% 首先查询player_mgr,如果不存在则直接请求对应的player_server
get(Id) when is_integer(Id) ->
    case player_mgr:get_by_id(Id) of
        ?NONE ->
            % 结果可能为NONE
            world_online:get_by_id(Id);
        Player ->
            Player
    end.

%% @doc 获取多个玩家,如果玩家不存在则跳过!
%%  获取的顺序为反序
get_multi(Ids) when is_list(Ids) ->
    lists:foldl(
    fun(Id, Acc) ->
        case catch ?MODULE:get(Id) of
            ?NONE ->
                Acc;
            P ->
                [P | Acc]
        end
    end, [], Ids).

%% @doc 获取某个玩家数据(非死亡状态)
get_not_dead(Id) ->
    case ?MODULE:get(Id) of
        ?NONE ->
            Player = player_server:get_state(Id),
            ?IF(Player =/= ?NONE andalso (not player_state:in_dead(Player)),
                Player,
                ?NONE);
        Player ->
            ?IF(player_state:in_dead(Player), ?NONE, Player)
    end.

%% @doc 查询玩家姓名
get_name(Id) when is_integer(Id) ->
    todo.

%% @doc 依据名字查询玩家
get_by_name(Name) when is_binary(Name) ->
    world_online:get_by_name(Name).

%% @doc 查询玩家的id
get_id_by_name(Name) when is_binary(Name) ->
    world_online:get_id_by_name(Name).

%% @doc 获取指定玩家的进程
pid(Id) when is_integer(Id) ->
    game_misc:whereis_name(game_misc:player_name(Id)).


%% @doc 判断玩家是否在线
is_online(Id) ->
    pid(Id) =/= undefined.


%% @doc 进行s2s_cast请求，由mod_xxx处理请求,返回{ok, State}
s2s_cast(Id, Mod, Req) ->
    cast(Id, {s2s_cast, Mod, Req}).

%% @doc 进行s2s_call请求，返回{Reply, State}
s2s_call(Id, Mod, Req) ->
    call(Id, {s2s_call, Mod, Req}).

%% @doc 终止玩家进程
stop(Id) ->
    stop(Id, normal).

stopAllRobot()->
    RobotIdList = room_friend_mgr:get_robot_list(),

    [begin
         stop(Id)
     end || Id <- RobotIdList].
stop(Id, Reason) ->
    cast(Id, {stop, Reason}).

%% @doc 同步方式终止玩家进程
sync_stop(Id) ->
    call(Id, {stop, normal}).

%% @doc 让玩家停止移动(调试使用)
stop_move(Id) ->
    player_server:s2s_cast(Id, mod_map, {stop_move}).


%% @doc 判断玩家是否在某场景中
is_in_map(PlayerId,MapKey) ->
    case player_server:get_pos(PlayerId) of
        {MapKey,_X,_Y} -> true;
        _  -> false
    end.

%%--------------------
%% 测试使用的相关函数
%%--------------------

%% @doc 在玩家进程中执行某个函数
apply(Id, Fun) when is_integer(Id), is_function(Fun) ->
    call(Id, {apply, Fun}).

%% @doc 获取玩家的某个装备p_equip信息(*调试使用*)
equip(Id, _Repos, GoodsUniqId) when is_binary(GoodsUniqId) ->
    Fun = 
    fun(_Player) ->
        % TODO 我删除了，需要自己实现
        ok
    end,
    call(Id, {apply, Fun}).

%% @doc 查询玩家的timer 列表
timer_list(Id) ->
    Fun =
    fun(_Player) ->
            gen_mod:timer_list()
    end,
    call(Id, {apply, Fun}).

%% @doc 模拟客户端向服务器发送消息
client_msg(Id, Mod, MsgId, Req) ->
	process(Mod, Req, MsgId, pid(Id)).

%%-------------------------
%% 后台及定时任务对应的函数
%%-------------------------

%% @doc 清理计数器
clear_counter(Id) ->
    ok = cast(Id, clear_counter),
    ok.

set_old_rank(Id) ->
    ok = cast(Id, save_old),
    ok.
%%-------------------
%% gen_server回调函数
%%-------------------
init({?NEW, Id, {Client, IpStr}}) ->
    %?DEBUG(?_U("初始化玩家:~p逻辑进程"), [Id]),
    erlang:process_flag(trap_exit, true),
    random:seed(erlang:monotonic_time()),


    % ok = ?COUNTER_DB:load(#player{id = Id}),
    % ok = ?COUNTER_DAILY:load(#player{id = Id}),
    % 加载玩家数据

    %?DEBUG(?_U("初始化玩家:~p"), [Player2]),

    Player3 = case Client of
        #robot{type = RobotType} = Robot ->
            ?DEBUG(?_U("机器人服务端开启:~p"), [Robot]),
            Player2 = init_robot_player(RobotType,#player{id = Id,robot = Robot}),
            Player2;
        _ ->
            Player = #player{} = db_player:load(Id),
            Player2 = Player#player{status = db_account:get_status(Id)},
            link_client(Client, Player2)
    end,


    Player4 = game_hooks:run_fold(?HOOK_INIT_PLAYER, Player3, [?NEW]),%%调用预先注册函数
    %Player5 = game_formula:calc_player(Player4),%%根据等级获取,属性
    % Player5 = calc_offline_change(Player4),
    ok = player_mgr:add(Player4),
    ok = world_online:add(Player4),
    %?DEBUG(?_U("初始化玩家:~p"), [Player]),
    set_player_old(Player4),
    {ok, Player4}.

handle_call(i, _From, State)->
    Reply = do_i(State),
    {reply, Reply, State};
handle_call(kick_offline, _From, State) ->
   % Msg = #gc_player_kickoff
    %{
      %  serverversion = 0
    %},
    %MsgId = ?PROTO_CONVERT({mod_attr, gc_player_kickoff}),
    %ok = ?S2C_SEND_PUSH:player(State#player.id, MsgId, Msg),

    {reply, ok, State};
handle_call({stop, Reason}, _From, State) ->
    ?IF(Reason =:= normal, ok,
        ?ERROR(?_U("玩家:~p的逻辑进程结束，原因:~p"), 
            [State#player.id, Reason])),
    {stop, Reason, ok, State};
handle_call({apply, Fun}, _From, State)->
    case catch do_apply(Fun, State) of
        ok ->
            {reply, ok, State};
        {ok, #player{} = State2} ->
            {reply, ok, State2};
        {error, Code} ->
            ?WARN(?_U("执行apply函数返回错误码:~p"), [Code]),
            {reply, {error, Code}, State};
        {'EXIT', _Reason} ->
            ?ERROR(?_U("执行apply函数出错:~p"), [_Reason]),
            {reply, {error, _Reason}, State};
        _Other ->
            ?DEBUG(?_U("执行apply函数返回:~p"), [_Other]),
            {reply, _Other, State}
    end;
handle_call({s2s_call, Mod, Req}, _From, State)->
    {Reply, State2} = do_s2s_call(Mod, Req, State),
    {reply, Reply, State2};
handle_call(get_state, _From, State) ->
    {reply, State, State};
handle_call(_Msg, _From, State) ->
    {noreply, State}.

%% 处理所有c2s请求
handle_cast({c2s, Mod, Req, MsgId}, State)->
    %?DEBUG(?_U("玩家处理消息 Mod:~p, Req:~p and MagId ~p ~n"), [Mod, Req, MsgId]),
    case catch do_handle_c2s(Mod, Req, MsgId, State) of
        {ok, State2} ->
            ok = do_sync_player(State2),
            {noreply, State2};
        Other ->
            exit(Other)
    end;

%% mod处理所有s2s请求
handle_cast({s2s_cast, Mod, Req}, State) ->
    %?DEBUG(?_U("处理服务器mod cast请求:~p"), [Req]),
    {ok, State2} = do_s2s_mod_cast(Mod, Req, State),
    ok = do_sync_player(State2),
    {noreply, State2};
handle_cast({stop, Reason}, State) ->
    %?WARN(?_U("玩家:~p的逻辑进程要求退出，原因:~p"), [State#player.id, Reason]),
    {stop, normal, State};
% 清空所有的counter
handle_cast(clear_counter, Player) ->
    ?DEBUG(?_U("玩家:~p清理counter"), [Player#player.id]),
    % 不能清空db counter!
    ok = ?COUNTER_DAILY:clear(),
    {noreply, Player};

handle_cast(save_old, Player) ->
    OldPlayer = get_player_old(),
    #player{moneyRank = MoneyRank,winRank = WinRank,loseRank = LoseRank} = Player,
    NewPlayerOld = OldPlayer#player{moneyRank = MoneyRank,winRank = WinRank,loseRank = LoseRank},
    %?INFO(?_U("老排行榜保存:~p"), [NewPlayerOld]),
    set_player_old(NewPlayerOld),
    {noreply, Player};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({'EXIT', Client, _Reason}, #player{} = State) ->
    %?WARN(?_U("玩家:~p的client进程结束,原因:~p"), [State#player.id, _Reason]),
    {stop, normal, State};

% 循环timer
handle_info({mod_timeout, Time, Loop}, State) when is_integer(Time), is_boolean(Loop)->
    do_mod_timeout(Time, Loop, State);
% 准时timer
handle_info({mod_timeout, Mod, Msg}, State) ->
    case catch Mod:handle_timeout(Msg, State) of
            {ok, State2} ->
                %?DEBUG(?_U("player_server收到延迟累消息:~p"), [State2]),
                {noreply, State2};
            _Reason ->
                ?ERROR(?_U("gen_mod:~p 处理消息:~p 错误:~p"), [Mod, Msg, _Reason]),
                throw({stop, _Reason, State})
    end;

handle_info(_Info, State) ->
    {noreply, State}.

terminate(Reason, #player{id = Id, room_id = RoomId} = Player0) ->
    %?DEBUG(?_U("玩家进程player_server结束原因 ~p"),[Reason]),
    TerminateReason = game_misc:get_terminate_reason(),
    case {Reason, TerminateReason} of
        {normal, switch_node} ->
            ok;
        {normal, undefined} ->
            ok;
        {_, _} ->
            ?WARN(?_U("玩家:~p逻辑进程结束,出错:~p(~p)"),
                [Id, Reason, TerminateReason]),
            wg_alarm:player_crash({Id, Reason, TerminateReason})
    end,
    %?DEBUG(?_U("玩家掉线 删除房间的玩家:~p,"), [Player0]),

    Player2 = case catch mod_room:do_quit_room(Player0,?QUIT_NET_ERROR) of
        #player{} = Player3 ->
            Player3;
        _->
            ?DEBUG(?_U("玩家没有加入任何房间:~p,"), [1]),

            Player0
    end,


    %?DEBUG(?_U("删除玩家-2-32-3:~p,"), [Player2]),
    ok = world_online:delete(Id),
    ok = player_mgr:delete(Id),
    case Reason =:= normal andalso TerminateReason =:= switch_node of
        true ->
            ?DEBUG(?_U("玩家:~p,切换到其它节点场景,逻辑进程关闭"), [Id]),
            ok;
        false ->
            Player = Player2#player{},
            case catch game_hooks:run(?HOOK_TERMINATE_PLAYER, [Player]) of
                {'EXIT', _Other} ->
                    ?ERROR(?_U("执行terminate player错误:~p"), [_Other]),
                    ok;
                _ ->
                    ok
            end,

            ?IF(is_player_changed(Player),do_save_player(Player),ok),
            save_rank(Player),
            %?IF(is_player_status_changed(Player),db_account:set_status_by_sid(Id,Status),ok),
            %ok = ?COUNTER_DB:save(Player),
            %ok = ?COUNTER_DAILY:save(Player),
            %game_log:logout(Player),
            ok
    end.

code_change(_Old, State, _Extra) ->
    {ok, State}.

%%---------------------------
%% internal API
%%---------------------------

do_save_player(Player)->
    %?DEBUG(?_U("保存玩家:~p,"), [Player]),
    db_player:save(Player).

%% 进入游戏
do_enter(Node, Id, _Args, 4) ->
    ?ERROR(?_U("玩家:~p在节点:~p尝试登录3次失败"), [Id, Node]),
    {error, ?E_UNKNOWN};
do_enter(Node, Id, Args, Retry) ->
    %?DEBUG(?_U("进入游戏节点~p, Id: ~p,  参数: ~p ~n"), [Node, Id, Args]),
    case player_mgr:new(Node, Id, Args) of
        {logined, Pid} ->
            %已登录玩家踢下线
            ?DEBUG(?_U("***玩家:~p被踢下线...."), [Id]),
            try 
                %player_server:kick_offline(Pid)
                stop(Id)
            catch
                exit:_ ->
                    ok
            end,
            timer:sleep(100),
            do_enter(Node, Id, Args, Retry + 1);
        Other ->
            Other
    end.
init_robot_player(RobotType,#player{id = PlayerId} = Player)->

    LoseRank = #lose_rank_data{
        id = PlayerId,
        cardone = -1,
        cardtwo = -1,
        mypos = -1,
        name_list = [],
        image_list = [],
        money_list = [],
        pos_list = [],
        table_money = 0,
        poker_num = 0,
        money = 0
    },
    WinRank = #win_rank_data{
        id = PlayerId,
        cardone = -1,
        cardtwo = -1,
        mypos = -1,
        name_list = [],
        image_list = [],
        money_list = [],
        pos_list = [],
        table_money = 0,
        poker_num = 0,
        money = 0
    },
    case RobotType of
        ?New_Room_Robot ->
            MoneyRank = #money_rank_data{id = PlayerId,name = gate_acc:random_name(),image = ?U2B("Robot/robot_"++integer_to_list(PlayerId)++".png"),money = 5000},
            Player#player{money = 5000,moneyRank = MoneyRank,loseRank = LoseRank,winRank = WinRank};
        ?Ordinary_Room_Robot ->
            MoneyRank = #money_rank_data{id = PlayerId,name = gate_acc:random_name(),image = ?U2B("Robot/robot_"++integer_to_list(PlayerId)++".png"),money = 45000},
            Player#player{money = 45000,moneyRank = MoneyRank,loseRank = LoseRank,winRank = WinRank};
        ?Mastr_Room_Robot ->
            MoneyRank = #money_rank_data{id = PlayerId,name = gate_acc:random_name(),image = ?U2B("Robot/robot_"++integer_to_list(PlayerId)++".png"),money = 400000},
            Player#player{money = 400000,moneyRank = MoneyRank,loseRank = LoseRank,winRank = WinRank};
        _->
            ?DEBUG(?_U("***初始化机器人数据失败,机器人类型为...."), [RobotType]),
            Player
    end.

%% link client进程
link_client(undefined, _Player) ->
    _Player;
link_client(Client, #player{} = Player) ->
    case catch erlang:link(Client) of
        true ->
            Player#player{client = Client};
        {'EXIT', {Error, _}} ->
            ?ERROR(?_U("连接玩家:~w的gate_client进程失败:~w"), [Player#player.id, Error]),
            % 玩家竟然退出了?
            throw({stop, normal})
    end.

%% 执行某个操作(测试使用)
do_apply(Fun, _Player) when is_function(Fun, 0) ->
    Fun();
do_apply(Fun, Player) when is_function(Fun, 1) ->
   Fun(Player). 

%% call调用
call(Id, Req) when is_integer(Id) ->
    Pid = game_misc:whereis_name(game_misc:player_name(Id)),
    gen_server:call(Pid, Req, ?GEN_TIMEOUT);
call(Id, Req) when is_pid(Id) ->
    gen_server:call(Id, Req, ?GEN_TIMEOUT);
call(#player{pid = Pid}, Req) ->
    gen_server:call(Pid, Req, ?GEN_TIMEOUT).

%% cast调用
cast(Id, Req) when is_integer(Id) ->
    Pid = game_misc:whereis_name(game_misc:player_name(Id)),
    gen_server:cast(Pid, Req);
cast(Id, Req) when is_pid(Id) ->
    gen_server:cast(Id, Req);
cast(#player{pid = Pid}, Req)  ->
    gen_server:cast(Pid, Req).

%% 处理c2s请求
do_handle_c2s(Mod, Req, MsgId, State) ->
    case catch Mod:handle_c2s(Req, MsgId, State) of
        {ok, State2} ->
            {ok, State2};
        _Other ->
            ?ERROR(
            ?_U("***玩家:~b处理消息:~w时发生错误:~w~n~n**player:~w~n~n**~p状态:~w"),
            [State#player.id, Req, _Other, State, Mod, Mod:i(State)]),
            _Other
    end.

%% 处理所有来自其它服务的cast请求,返回{ok, State}
do_s2s_mod_cast(Mod, Req, Player) ->
    Mod:handle_s2s_cast(Req, Player).

%% 处理来自其它服务的call请求,返回 {Reply, State}
do_s2s_call(Mod, Req, Player) ->
    Mod:handle_s2s_call(Req, Player).

%%-------------------
%% 同步玩家数据
%%-------------------

%% player同步cd
-define(PLAYER_SYNC_TEMP_CD, '!player_sync_temp_cd').
%% 旧的紧急同步数据
-define(PLAYER_SYNC_URGENT_OLD, '!player_sync_urgent_old').
%% 旧的玩家数据
-define(PLAYER_SYNC__OLD, '!player_sync__old').
%% 玩家紧急信息
-record(player_urgent, {
    mapkey,
    x,
    y,
    state,
    speed
}).
to_player_urgent(#player{} = Player) ->
    Player.

%% 设置旧的紧急信息
set_player_urgent_old(#player_urgent{} = Val) ->
    erlang:put(?PLAYER_SYNC_URGENT_OLD, Val),
    ok.

%% 获取旧的紧急信息
get_player_urgent_old() ->
    erlang:get(?PLAYER_SYNC_URGENT_OLD).


%% 获取旧的player信息
get_player_old() ->
    erlang:get(?PLAYER_SYNC__OLD).

%% 设置player开始信息
set_player_old(#player{} = Val) ->
    erlang:put(?PLAYER_SYNC__OLD, Val),
    ok.

%% 信息是否变化
is_player_changed(Player) ->
    #player{id = Id,room_id = RoomId,user_id = Use_Id,unit_id = Unit_Id,giveTimes = GiveTimes,lastGiveTime = LastTime,
        money = Money,firstmoney = WinMoney,cardone = CardOne,cardtwo = CardTwo,gamenum = GameNum,roomtype = RoomType,card_room = Card_Room} = get_player_old(),
    Old = #player_db{id = Id,room_id = RoomId,user_id = 0,unit_id = 0,giveTimes = GiveTimes,lastGiveTime = LastTime,
        money = Money,firstmoney = WinMoney,cardone = CardOne,cardtwo = CardTwo,gamenum = GameNum,roomtype = RoomType,card_room = Card_Room},

    #player{id = NewId,room_id = NewRoomId,user_id = NewUse_Id,unit_id = NewUnit_Id,giveTimes = NewGiveTimes,lastGiveTime = NewLastTime,
        money = NewMoney,firstmoney = NewWinMoney,cardone = NewCardOne,cardtwo = NewCardTwo,gamenum = NewGameNum,roomtype = NewRoomType,card_room = NewCard_Room} = Player,

    New = #player_db{id = NewId,room_id = NewRoomId,user_id = 0,unit_id = 0,giveTimes = NewGiveTimes,lastGiveTime = NewLastTime,
        money = NewMoney,firstmoney = NewWinMoney,cardone = NewCardOne,cardtwo = NewCardTwo,gamenum = NewGameNum,roomtype = NewRoomType,card_room = NewCard_Room},
    Old =/= New.

save_rank(Player) ->
    #player{moneyRank = MoneyRank,winRank = WinRank,loseRank = LoseRank} = get_player_old(),

    #player{moneyRank = NewMoneyRank,winRank = NewWinRank,loseRank = NewLoseRank} = Player,

    ?IF(MoneyRank  =/=  NewMoneyRank,db_rank_money:update(NewMoneyRank),ok),

    ?IF(WinRank  =/=  NewWinRank,db_rank_win_money:update(NewWinRank),ok),

    ?IF(LoseRank  =/=  NewLoseRank,db_rank_lose_money:update(NewLoseRank),ok).

is_player_status_changed(Player) ->
    #player{status = OldStatus} = get_player_old(),
    OldStatus =/= Player#player.status.
%% 紧急信息是否变化
is_player_urgent_changed(PlayerUrgent) ->
    get_player_urgent_old() =/= PlayerUrgent.

%% 如果mapkey,x,y,state,speed发生了变化,则立刻更新
%% 否则2秒钟更新一次
do_sync_player(Player) ->
    case temp_cd:check(?PLAYER_SYNC_TEMP_CD, 2000) of
        true ->
            player_mgr:update(Player),
            world_online:update(Player),
            temp_cd:set(?PLAYER_SYNC_TEMP_CD);
        false ->
            ok
    end.

%%-------------------------
%% 处理mod的timeout
%%-------------------------
do_mod_timeout(Time, Loop, State) ->
    catch do_mod_timeout1(Time, Loop, State).
do_mod_timeout1(Time, Loop, State) ->
    ModMsgs = gen_mod:on_mod_timeout(Time, Loop),
    State2 =
    lists:foldl(
    fun({Mod, Msg}, Acc) ->
        case catch Mod:handle_timeout(Msg, Acc) of
            {ok, Acc2} ->
                Acc2;
            _Reason ->
                ?ERROR(?_U("gen_mod:~p 处理消息:~p 错误:~p"), [Mod, Msg, _Reason]),
                throw({stop, _Reason, Acc})
        end
    end, State, ModMsgs),
    ok = do_sync_player(State2),
    {noreply, State2}.

%%------------------------
%% 数据迁移(切换场景使用)
%%------------------------

%% @doc 收集迁移数据(mod_map使用)
gather_data(Player) ->
    ?DEBUG(?_U("收集玩家:~p的迁移数据"), [Player#player.id]),
    try
        Data = gen_mod:gather_player(Player),
        [{player, Player} | Data]
    catch
        Class:Reason ->
            ?ERROR(?_U("收集玩家数据出错 ~p:~p"), [Class, Reason]),
            ?C2SERR(?E_UNKNOWN)
    end.

%% @doc 将旧的数据转移到新的玩家进程
trans_player_msg(PidNew) ->
    receive
        Msg ->
            PidNew ! Msg,
            trans_player_msg(PidNew)
    after 
        0 ->
            ok
    end.

%%---------------
%% 其他函数
%%---------------

%% 发送出错信息给client
%% -ifdef(NOTUSEIT).
%% send_debug_msg_to_client(_Player, normal) ->
%%     ok;
%% send_debug_msg_to_client(Player, Reason) ->
%%     case Player#player.client of
%%         undefined ->
%%             ok;
%%         Client ->
%%             MsgId = ?PROTO_CONVERT({mod_debug, player_crash}),
%%             Msg = #debug_player_crash_s2c{
%%                 reason = io_lib:format("~p", [Reason]),
%%                 id = Player#player.id,
%%                 pid = io_lib:format("~p", [self()]),
%%                 time = ?N2S(wg_util:now_sec())
%%             },
%%             ?S2C_SEND_MERGE:player(Client, MsgId, Msg)
%%     end.
%% -endif.

%%----------
%% 调试相关
%%----------
%% 获取玩家信息(调试使用)
do_i(Player) ->
    gen_mod:i(Player).

do_p(Info) ->
    Str = lists:flatten(gen_mod:p(Info)),
    io:format(
    ?_U("玩家信息~n~80..=s~n"
    "~ts"),
    ["=", Str]),
    ok.

%%----------------
%% EUNIT Test
%%----------------

-ifdef(EUNIT).

-endif.
