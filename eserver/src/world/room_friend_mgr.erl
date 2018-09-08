
-module(room_friend_mgr).
-author("fuxing").
-vsn('0.1').
-include("wg.hrl").
-include("game.hrl").
%-include("../src/player/player_internal.hrl").
%-include("game_hooks.hrl").
-include("../src/proto/proto.hrl").
-include("room.hrl").
%-include("player.hrl").
-include("pbmessage_pb.hrl").
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1]).


%% 查询相关

-export([add_robot_id/1,get_robot_list/0,get/1,member_count/1,is_full/1,player_room_id/1,get_free_id/0,is_all_ready/1,get_new_poker_list/0,set/1,check_reconnect/3,reconnect_add_member/2]).


%% 创建添加更新

-export([create/6,create_table/0,add_member/2,set_room_status/3,set_member_status/4,set_table_Money/2,add_keep_pos/1,delete_keep_pos/1,reset_keep_pos/1]).


%% 删除

-export([delete/1,delete_member/2]).

%查询
-export([i/0]).
%% gen_server相关函数

-export([call/1, handle_call/3, handle_cast/2, handle_info/2,
  terminate/2, code_change/3]).


%% 状态,用于队伍id，从1开始

-record(state, {
        id_new = 1
    }).


%% 服务名字

-define(START_NAME, {global, ?MODULE}).
-define(NAME, ?MODULE).


%% 组队列表

-define(ROOM_POS_LIST_FULL, [1, 2, 3, 4,5,6,7]).
%-define(ROOM_PLAY_TIME, 60*20).
%-define(ROOM_PLAY_TIME, 60*10).
%% 表名称

-define(ROOM, 'room_friend').
-define(ROOM_PLAYER, 'room_friend_player').
-define(FREE_ROOM_LIST, 'friend_room_list').
-define(RobotList, 'robot_list').
%% @doc 启动

i() ->
  L = case ets:lookup(?FREE_ROOM_LIST, 1) of
        [] ->

          [];

        [#room_free{roomlist = FreeList} = _RoomFree] ->
          [begin
             case ets:lookup(?ROOM, RoomId) of
               [#room{} = Room] ->
                 ?INFO(?_U("房间信息:~p,"), [Room]);
               [] ->
                 ok
             end
           end || RoomId <- FreeList],

          FreeList
      end,
  [
    {friend_room_count, length(L)}

  ].

start_link()->
    ?DEBUG(?_U("启动room__friend_mgr服务"),[]),
    gen_server:start_link(?START_NAME, ?MODULE, [], []).



start_update()->
  erlang:send_after(1000,self(),loop_update).

%%初始化





init(_Type) ->
    erlang:process_flag(trap_exit, true),
    erlang:process_flag(priority, high),
    create_table(),
    register(?NAME, self()),
    start_update(),
    {ok, #state{}}.

create_table() ->
    ?ROOM = ets:new(?ROOM, [set, public, named_table,
            {keypos, #room.id},
            ?ETS_CONCURRENCY
            ]),

  ?FREE_ROOM_LIST = ets:new(?FREE_ROOM_LIST, [set, public, named_table,
    {keypos, #room_free.id},
    ?ETS_CONCURRENCY
  ]),

    ?ROOM_PLAYER = ets:new(?ROOM_PLAYER, [set, public, named_table,
            {keypos, 1}, 
            ?ETS_CONCURRENCY
            ]),

  ?RobotList = ets:new(?RobotList, [set, public, named_table,
    {keypos, #robot_free.id},
    ?ETS_CONCURRENCY
  ]),
    ok.

%%获得新的扑克列表
get_new_poker_list()->
  shuffle(do_for(0,107)).
%%创建房间

create(Room_Member,MinMoney,MaxMoney,IsDouble,CardNum,GameTime) ->
  call({create, Room_Member,MinMoney,MaxMoney,IsDouble,CardNum,GameTime}).

add_keep_pos(RoomId) ->
  call({add_keep_pos,RoomId}).

delete_keep_pos(RoomId) ->
  call({delete_keep_pos,RoomId}).

reset_keep_pos(RoomId) ->
  call({reset_keep_pos,RoomId}).

check_reconnect(RoomId,MemberId,GameNum)->
  call({check_reconnect,RoomId,MemberId,GameNum}).
get(RoomId) ->
  call({get, RoomId}).

set(Room) ->
  call({set, Room}).
get_free_id() ->
  case ets:lookup(?FREE_ROOM_LIST, 1) of
    [] ->

      noFreeRoom;

    [#room_free{roomlist = FreeList} = _RoomFree] ->

      % 更新table数据
      case length(FreeList) =:= 0 of
        true ->
          noFreeRoom;
        false ->
          %[Id|Rest] = FreeList,
          N = wg_util:rand(1,length(FreeList)),
          lists:nth(N,FreeList)
      end
  end.

get_robot_list() ->
  case ets:lookup(?RobotList, 1) of
    [] ->

      [];
    [#robot_free{robot_list  = FreeList} = _RobotFree] ->
      FreeList
  end.


player_room_id(PlayerId) ->
  %?DEBUG(?_U("获取玩家~w所在队伍id"), [PlayerId]),
  call({player_room_id, PlayerId}).


%%添加成员
add_member(RoomId, Room_Member) ->
  %?DEBUG(?_U("队伍id~w添加队员id~"), [TeamId, MemberId,MemberName,MemberMoney]),
  call({add_member, RoomId, Room_Member}).

reconnect_add_member(RoomId, Room_Member) ->
  %?DEBUG(?_U("队伍id~w添加队员id~"), [TeamId, MemberId,MemberName,MemberMoney]),
  call({reconnect_add_member, RoomId, Room_Member}).

%%删除成员
delete_member(RoomId, MemberId) ->
  call({delete_member, RoomId, MemberId}).


%%删除整个队伍
delete(RoomId) when is_integer(RoomId) ->
  call({delete, RoomId}).

set_room_status(RoomId,RoomState,Turn) ->
  call({room_state, RoomId,RoomState,Turn}).

set_table_Money(RoomId,Money) ->
  call({room_table_money, RoomId,Money}).
set_member_status(PlayerId,RoomId,ChangeIndex,ChangeValue) ->
  call({member_state,PlayerId,RoomId,ChangeIndex,ChangeValue}).

%%队伍的成员个数
member_count(RoomId) ->
  #room{member = MemberList} = ?MODULE:get(RoomId),
  length(MemberList).

is_all_ready(RoomId) ->
  #room{member = MemberList} = ?MODULE:get(RoomId),
  lists:all
  (
    fun(#room_member{state = State }=_MyMember) ->
      ?IF(State =:= ?PLAYER_Ready orelse State =:= ?PLAYER_OFFlINE, true, false)
    end,
    MemberList
  ).

%%判断队伍是否满

is_full(RoomId) ->
  #room{member = MemberList} = ?MODULE:get(RoomId),
  length(MemberList)  >= ?ROOM_MEMBER_MAX.

handle_call({create,Room_Member,MinMoney,MaxMoney,IsDouble,CardNum,GameTime}, _From, State) ->
  Poker = shuffle(do_for(0,107)),
  %?DEBUG(?_U("初始化房间扑克列表:~p"), [Poker]),
  Room_Member2 = Room_Member#room_member{pos = 1},
  #room_member{id = PlayerId} = Room_Member2,
  CreateRoomId = do_get_room_random_id(),
    Room = #room
    {
        id = CreateRoomId,
        leader = PlayerId,
        turn = 0,
        min_money = MinMoney,
        max_bet = MaxMoney,
        isDouble = IsDouble,
        roomstate = ?ROOM_WAIT_READY,
        pork_list = Poker,
        member = [Room_Member2],
        need_card = CardNum,
        game_time = GameTime
    },
  %更新table信息
    do_add_free_list(CreateRoomId),
    true = ets:insert(?ROOM, Room),
    true = ets:insert(?ROOM_PLAYER, {PlayerId, CreateRoomId}),
    {reply, Room, State};


handle_call({get, RoomId}, _From, State) ->
  %根据teamid 在table中查询，如果找到返回#team信息，
  % 未找到返回#team内容都为空
  Reply =
    case ets:lookup(?ROOM, RoomId) of
      [#room{} = Room] ->
        Room;
      [] ->
        Room = #room{id = ?NULL_ROOMID} ,
        Room
    end,
  {reply, Reply, State};

handle_call({check_reconnect,RoomId,MemberId,_GameNum}, _From, State) ->
  %根据teamid 在table中查询，如果找到返回#team信息，
  % 未找到返回#team内容都为空
  Reply =
    case ets:lookup(?ROOM, RoomId) of
      [#room{} = _Room] ->
        case ets:lookup(?ROOM_PLAYER, MemberId) =:= [] of
          true->
            ?Need_Reconnect;
          _->
            ?No_Need_Reconnect
        end;
      [] ->
        ?No_Need_Reconnect
    end,
  {reply, Reply, State};

handle_call({add_keep_pos,RoomId}, _From, State) ->
  %根据teamid 在table中查询，如果找到返回#team信息，
  % 未找到返回#team内容都为空
  Reply =
    case ets:lookup(?ROOM, RoomId) of
      [#room{keepnum = KeepNum} = Room] ->
        NewKeepNum = KeepNum + 1,
        ?IF(NewKeepNum > 7,NewKeepNum1 = 7,NewKeepNum1 = NewKeepNum),
        Room2 = Room#room{keepnum = NewKeepNum1},
        ets:insert(?ROOM, Room2),
        Room2;
      [] ->
        Room = #room{id = ?NULL_ROOMID} ,
        Room
    end,
  {reply, Reply, State};

handle_call({delete_keep_pos,RoomId}, _From, State) ->
  %根据teamid 在table中查询，如果找到返回#team信息，
  % 未找到返回#team内容都为空
  Reply =
    case ets:lookup(?ROOM, RoomId) of
      [#room{keepnum = KeepNum} = Room] ->
        NewKeepNum = KeepNum - 1,
        ?IF(NewKeepNum < 0,NewKeepNum1 = 0,NewKeepNum1 = NewKeepNum),
        Room2 = Room#room{keepnum = NewKeepNum1},
        ets:insert(?ROOM, Room2),
        Room2;
      [] ->
        Room = #room{id = ?NULL_ROOMID} ,
        Room
    end,
  {reply, Reply, State};

handle_call({reset_keep_pos,RoomId}, _From, State) ->
  %根据teamid 在table中查询，如果找到返回#team信息，
  % 未找到返回#team内容都为空
  Reply =
    case ets:lookup(?ROOM, RoomId) of
      [#room{} = Room] ->
        Room2 = Room#room{keepnum = 0},
        ets:insert(?ROOM, Room2),
        Room2;
      [] ->
        Room = #room{id = ?NULL_ROOMID} ,
        Room
    end,
  {reply, Reply, State};


handle_call({set, Room}, _From, State) ->
  %根据teamid 在table中查询，如果找到返回#team信息，
  % 未找到返回#team内容都为空
  ets:insert(?ROOM, Room),
  Reply =Room,
  {reply, Reply, State};

%%添加成员

handle_call({add_member, RoomId, Room_Member}, _From, State) ->

  Reply = (catch do_add_member(RoomId, Room_Member)),
  {reply, Reply, State};

handle_call({reconnect_add_member, RoomId, Room_Member}, _From, State) ->

  Reply = (catch do_reconnect_add_member(RoomId, Room_Member)),
  {reply, Reply, State};

%%删除成员

handle_call({delete_member, RoomId, MemberId}, _From, State) ->
  Reply = (catch do_delete_member(RoomId, MemberId)),
  {reply, Reply, State};
%% 改变房间的状态
handle_call({room_state, RoomId,RoomState,Turn}, _From, State) ->
  Reply = (catch do_set_room_state(RoomId, RoomState,Turn)),
  {reply, Reply, State};

handle_call({room_table_money, RoomId,Money}, _From, State) ->
  Reply = (catch do_set_room_state(RoomId, Money)),
  {reply, Reply, State};

%% 改变玩家的状态
handle_call({member_state,PlayerId,RoomId,ChangeIndex,ChangeValue}, _From, State) ->
  Reply = (catch do_set_member_state(PlayerId,RoomId,ChangeIndex,ChangeValue)),
  {reply, Reply, State};



handle_call({player_room_id, PlayerId}, _From, State) ->
  %在table中根据playerid找teamid，找到返回teamid
  %未找到返回无效teamid，也就是0
  Reply =
    case ets:lookup(?ROOM_PLAYER, PlayerId) of
      [] ->
        ?NULL_ROOMID;
      [{_, RoomId}] ->
        RoomId
    end,
  {reply, Reply, State};


%%解散队伍

handle_call({delete, RoomId}, _From, State) ->
  Reply = (catch do_delete(RoomId)),
  {reply, Reply, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(loop_update, State)->
  case ets:lookup(?FREE_ROOM_LIST, 1) of
    [] ->
      ok;

    [#room_free{roomlist = FreeList} = _RoomFree] ->
      check_friend_room(FreeList),
      check_friend_room_next_turn(FreeList)
  end,

  start_update(),
  {noreply, State};

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ?DEBUG(?_U("进程停止:~p"), [_Reason]),
  ok.

code_change(_Old, State, _Extra) ->
  {ok, State}.

call(Req) ->
  case gen_server:call(game_misc:whereis_name(?NAME), Req, ?GEN_TIMEOUT) of
    {error, Code} ->
      ?C2SERR(Code);
    Reply ->
      Reply
  end.

%向MemberList发送msg
check_friend_room([])->
  ok;
check_friend_room(RoomIdList) ->
  [begin
     case ets:lookup(?ROOM, RoomId) of
       [#room{game_start_time = StartTime,game_over = GameOver,game_time = GameTime} = Room] ->
         case GameOver of
           true->
             ok;
           false->
             CurSec = wg_util:now_sec(),
             RunTime = CurSec - StartTime,
             %?INFO(?_U("进行秒数:~p"), [RunTime]),
             %?INFO(?_U("开始时间:~p"), [StartTime]),
             case StartTime /= -1 andalso RunTime >= GameTime of
               true->
                 game_over(Room);
               _->
                 ok
             end
         end;
       [] ->
         ok
     end
   end || RoomId <- RoomIdList],
  ok.

check_friend_room_next_turn([])->
  ok;
check_friend_room_next_turn(RoomIdList) ->
  [begin
     case ets:lookup(?ROOM, RoomId) of
       [#room{game_start_time = StartTime,turn_begin_time = TurnStart,change_turn_time = TurnTotalTime} = Room] ->

         CurSec = wg_util:now_sec(),
         RunTime = CurSec - TurnStart,
             %?INFO(?_U("进行秒数:~p"), [RunTime]),
             %?INFO(?_U("开始时间:~p"), [TurnStart]),
         case StartTime /= -1 andalso RunTime >= TurnTotalTime of
           true->
             %?INFO(?_U("开始时间11:~p"), [StartTime]),
             game_change_room_info(Room);
           _->
             ok
         end;

       [] ->
         ok
     end
   end || RoomId <- RoomIdList],
  ok.

is_game_over(Room)->

  #room{game_over = GameOver,max_bet = MaxBet,table_money = TableMoney}= Room ,
  case GameOver of
    true->
      ?IF(TableMoney > MaxBet,false,true);
    false->
      false
  end.

game_change_room_info(Room)->

  case is_game_over(Room) of
    true->
      %?INFO(?_U("send over----:~p"), [1]),

      #room{id = RoomId,game_over_msg_send = IsSendGameOver,game_start_time = GameStartTime}=Room,
      ?IF(IsSendGameOver =:= true,ok,game_over_send_victory(Room)),
      CurSec = wg_util:now_sec(),
      LeftTime = CurSec - GameStartTime,
      ?IF(LeftTime >  26400,do_delete(RoomId),ok);
    false->
      %?INFO(?_U("check----:~p"), [1]),

      #room{roomstate = RoomState}=Room,
      ?IF(RoomState =:= ?ROOM_WAIT_READY,do_friend_game_start(Room),do_game_next_game(Room))
  end.
do_friend_game_start(Room)->
  %?INFO(?_U("好友房间开始逻辑:~p"), [1]),
  #room{gameNum = GameNum,game_time = GameMaxTime,turn = OldTurn,need_card = NeedCard,member = MemberList,min_money = MinMoney,pork_list = PorkList,table_money = OldTabelMoney,game_start_time = GameStartTime,is_delete_roomcard = IsDeleteRoomCard} = Room,

    PersonNum = length(MemberList),
    PokerCardNum = length(PorkList),
    NewTurnList = [X||#room_member{state = State} = X <-MemberList,State =:= ?PLAYER_Ready orelse State =:= ?PLAYER_OFFlINE],
    ValidePlayerNum = length(NewTurnList),
    case ValidePlayerNum > 0 of
      true ->

        ?IF(PokerCardNum  < ?POKER_NUM_MAX, ResetPokerList = room_newplayer_mgr:get_new_poker_list(),ResetPokerList = PorkList),
        [CardOne|PorkLeft] = ResetPokerList,
        [CardTwo|NewPorkList] = PorkLeft,

        #room_member{pos = MaxPos} = lists:last(NewTurnList),
        ?IF(OldTurn  < MaxPos,NewOldTurn = OldTurn,NewOldTurn = 0),
        [YourTurn|_]=[X||#room_member{pos = MemberPos} = X <-NewTurnList,MemberPos > NewOldTurn],
        #room_member{pos = TurnPos} = YourTurn,

        ?IF(GameStartTime =:= -1, NewStartTime =wg_util:now_sec() ,NewStartTime = GameStartTime),
        ?IF(IsDeleteRoomCard =:= false, DeleteCardNum =NeedCard ,DeleteCardNum = 0),

        Room2 = Room#room{game_start_time = NewStartTime,gameNum = GameNum,turn = TurnPos,turn_begin_time = wg_util:now_sec(),roomstate = ?ROOM_START,table_money = OldTabelMoney+MinMoney*PersonNum,cardone = CardOne,cardtwo = CardTwo,pork_list = NewPorkList,is_delete_roomcard = true},
        min_base_chip(Room2),
        LeftTime = wg_util:now_sec() - NewStartTime,
        Req = {?START_GAME, TurnPos, MinMoney,CardOne,CardTwo,GameNum,length(NewPorkList),OldTabelMoney+MinMoney*PersonNum,PokerCardNum  < ?POKER_NUM_MAX,GameMaxTime-LeftTime,DeleteCardNum},

        lists:map
        (
          fun(#room_member{id = SendId}=_MyMember) ->
            %?INFO(?_U("发送玩家准备的id:~p"), [SendId]),

            ok = player_server:s2s_cast(SendId, mod_room, Req)

          end,
          MemberList

        ),
        %?INFO(?_U("开始游戏修改房间信息:~p"), [Room2]),

        Room2;
      _ ->
        %?INFO(?_U("房间没有玩家:~p"), [1])
        ok
    end.

do_game_next_game(Room)->
  #room{table_money = TableMoney,gameNum = GameNum,game_time = GameTime,turn = OldTurn,member = MemberList,pork_list = PorkList,game_start_time = GameStartTime} = Room,

  PokerCardNum = length(PorkList),
  NewTurnList = [X||#room_member{state = State} = X <-MemberList,State =:= ?PLAYER_Ready orelse State =:= ?PLAYER_OFFlINE],
  %?INFO(?_U("房间next逻辑:~p"), [1]),
  ValidePlayerNum = length(NewTurnList),
  case ValidePlayerNum > 0 of
    true ->
      %?INFO(?_U("游戏进行下一个回合,有效人数:~p"), [ValidePlayerNum]),
      ?IF(PokerCardNum  < ?POKER_NUM_MAX, ResetPokerList = room_newplayer_mgr:get_new_poker_list(),ResetPokerList = PorkList),
      [CardOne|PorkLeft] = ResetPokerList,
      [CardTwo|NewPorkList] = PorkLeft,

      #room_member{pos = MaxPos} = lists:last(NewTurnList),
      ?IF(OldTurn  < MaxPos,NewOldTurn = OldTurn,NewOldTurn = 0),
      [YourTurn|_]=[X||#room_member{pos = MemberPos} = X <-NewTurnList,MemberPos > NewOldTurn],
      #room_member{pos = TurnPos} = YourTurn,
      Room2 = Room#room{turn = TurnPos,turn_begin_time = wg_util:now_sec(),cardone = CardOne,cardtwo = CardTwo,pork_list = NewPorkList},

      ets:insert(?ROOM, Room2),

      %?INFO(?_U("max的pos:~p"), [MaxPos]),
      %?INFO(?_U("old的pos:~p"), [OldTurn]),
      %?INFO(?_U("下一个人的pos:~p"), [TurnPos]),
      ?IF(GameStartTime =:= -1, NewStartTime = -1 ,NewStartTime = GameTime - wg_util:now_sec() + GameStartTime),

%%      ?INFO(?_U("max的pos:~p"), [GameStartTime]),
%%      ?INFO(?_U("old的pos:~p"), [GameTime]),
%%      ?INFO(?_U("下一个人的pos:~p"), [NewStartTime]),

      Req = {?START_GAME, TurnPos, 0,CardOne,CardTwo,GameNum,length(NewPorkList),TableMoney,PokerCardNum  < ?POKER_NUM_MAX,NewStartTime,0},

      lists:map
      (
        fun(#room_member{id = SendId}=_MyMember) ->

          ok = player_server:s2s_cast(SendId, mod_room, Req)

        end,
        MemberList

      ),
      %?INFO(?_U("开始游戏修改房间信息:~p"), [Room2]),

      Room2;
    _ ->
      ?INFO(?_U("房间没有玩家:~p"), [1])
  end.
min_base_chip(Room)->
  #room{member = Member,min_money = MinMoney} = Room,
  Val = lists:map
  (
    fun(TempMember) ->
      #room_member{score = OldScore} = TempMember,
      Member2 = TempMember#room_member{score = OldScore-MinMoney},
      %?INFO(?_U("所有人变为准备:~p"), [Member2]),
      Member2
    end,
    Member
  ),
  Room2 = Room#room{member = Val},
  %?INFO(?_U("新的房间成员列表:~p"), [Val]),
  ets:insert(?ROOM, Room2),
  Room2.

game_over_send_victory(#room{} = Room) ->

  Req = {?FRIEND_GAME_OVER,[],[],[],[],[]},

  Room2 = do_send_game_over_msg(Room,Req),

  do_check_delete_room(Room2).

do_send_game_over_msg(Room,Req)->
  #room{member = MemberList} = Room,
  Val = lists:map
  (
    fun(#room_member{id = SendId,state = State}=MyMember) ->
      %?INFO(?_U("发送玩家准备的id:~p"), [IsGet]),
      case State =:= ?PLAYER_OFFlINE of
        true->
          MyMember;
        _->
          ok = player_server:s2s_cast(SendId, mod_room, Req),
          MyMember#room_member{isGetGameResult =  true}
      end

    end,
    MemberList

  ),
  Room2 = Room#room{member = Val,game_over_msg_send = true},
  ?INFO(?_U("结束新的房间成员列表:~p"), [Val]),
  ets:insert(?ROOM, Room2),
  Room2.

do_check_delete_room(Room)->
  #room{id = RoomId,member = NewMember} = Room,

  %?INFO(?_U("checkRoom:~p"), [NewList]),
  IsDelete = lists:all
  (
    fun(#room_member{isGetGameResult = State }=_MyMember) ->
      ?IF(State =:= true, true, false)
    end,
    NewMember
  ),
  ?IF(IsDelete =:= true,do_delete(RoomId),ok).


game_over(#room{member = _MemberList} = Room)->
  Room2 =Room#room{game_over = true},
  ets:insert(?ROOM, Room2).

%%解散队伍


do_delete(RoomId) ->

  do_delete_free_list(RoomId),
  case ets:lookup(?ROOM, RoomId) of
    [] ->
      ?INFO(?_U("删除房间不存在:~p"), [1]),
      ?C2SERR(?Room_No_Find);
    [#room{member = MemberList} = Room] ->
      %删除队伍
      true = ets:delete(?ROOM, RoomId),
      [true = ets:delete(?ROOM_PLAYER, MemberId)
        || #room_member{id = MemberId} <- MemberList],
      %?INFO(?_U("删除房间成功:~p"), [1]),
      Room
  end.

do_get_room_random_id()->
  RandomId = wg_util:rand(100000,200000),
  case do_is_exist_id(RandomId) of
    true->
      do_get_room_random_id();
    false->
      %?INFO(?_U("好友房间id:~p"), [RandomId]),
      RandomId
  end
  .

do_is_exist_id(RoomId)->
  case ets:lookup(?FREE_ROOM_LIST, 1) of
    [] ->
      false;

    [#room_free{roomlist = FreeList} = _RoomFree] ->

      NewFreeList = [X|| X <-FreeList,X =:= RoomId],

      ?IF(length(NewFreeList) =:= 0, false,true)
  end.

do_add_free_list(RoomId) ->
  case ets:lookup(?FREE_ROOM_LIST, 1) of
    [] ->

      RoomFreeList = #room_free{id = 1,roomlist = [RoomId]},
      %?INFO(?_U("添加后的free列表:~p"), [RoomFreeList]),
      ets:insert(?FREE_ROOM_LIST, RoomFreeList);

    [#room_free{roomlist = FreeList} = RoomFree] ->

      NewFreeList = [X|| X <-FreeList,X /= RoomId],
      RoomFree2 = RoomFree#room_free{roomlist = [RoomId | NewFreeList]},
      %?INFO(?_U("添加后的free列表:~p"), [RoomFree2]),
      ets:insert(?FREE_ROOM_LIST, RoomFree2),

      RoomFree2

  end.

add_robot_id(RobotId) ->
  case ets:lookup(?RobotList, 1) of
    [] ->

      RobotFreeList = #robot_free{id = 1,robot_list = [RobotId]},
      ?INFO(?_U("[]添加后的robotfree列表:~p"), [RobotFreeList]),
      ets:insert(?RobotList, RobotFreeList);

    [#robot_free{robot_list = FreeList} = RobotFree] ->

      NewFreeList = [X|| X <-FreeList,X /= RobotId],
      RobotFree2= RobotFree#robot_free{robot_list = [RobotId | NewFreeList]},
      ?INFO(?_U("添加后的robot,free列表:~p"), [RobotFree2]),
      ets:insert(?RobotList, RobotFree2)

  end.


do_delete_free_list(RoomId) ->
  case ets:lookup(?FREE_ROOM_LIST, 1) of
    [] ->
      %?INFO(?_U("删除后的free列表失败:~p"), [1]),
      ok;

    [#room_free{roomlist = FreeList} = RoomFree] ->

      NewFreeList = [X|| X <-FreeList,X /= RoomId],
      RoomFree2 = RoomFree#room_free{roomlist = NewFreeList},
      ets:insert(?FREE_ROOM_LIST, RoomFree2),
      %?INFO(?_U("删除后的free列表:~p"), [NewFreeList]),
      RoomFree2

  end.
%%添加成员
do_add_member(RoomId, Room_Member) ->
  case ets:lookup(?ROOM, RoomId) of
    [] ->

      ?C2SERR(?Room_No_Find);

    [#room{roomstate = RoomState,member = MemberList,game_start_time = GameStartTime} = Room] ->
      % 1 人数判断
      ?IF(length(MemberList)  < ?ROOM_MEMBER_MAX, ok,
        ?C2SERR(?Room_Full)),
      % 2要加的队员是否已经在队伍里
      #room_member{id = MemberId} = Room_Member,

      ?IF(ets:lookup(?ROOM_PLAYER, MemberId) =:= [], ok,
        ?C2SERR(?Already_In_Room)),

      ?IF(RoomState =:= ?ROOM_START, ?C2SERR(?Friend_Room_Already_Start_Error),ok),

      ?IF(GameStartTime =:= -1,ok,?C2SERR(?Friend_Room_Already_Start_Error)),

      Member = Room_Member#room_member
      {
        pos = do_get_idle_pos(MemberList),
        state = ?PLAYER_STATE_NORMAL
      },
      NewMemberList = do_sort_by_pos([Member | MemberList]),
      Room2 = Room#room{member = NewMemberList},
      ets:insert(?ROOM, Room2),
      ets:insert(?ROOM_PLAYER, {MemberId, RoomId}),
      {Room2, Member}

  end.

do_reconnect_add_member(RoomId, Room_Member) ->
  case ets:lookup(?ROOM, RoomId) of
    [] ->

      ?C2SERR(?Room_No_Find);

    [#room{member = MemberList,game_start_time = GameStartTime} = Room] ->
      % 1 人数判断
%%      ?IF(length(MemberList)  < ?ROOM_MEMBER_MAX, ok,
%%        ?C2SERR(?Room_Full)),
      % 2要加的队员是否已经在队伍里
      #room_member{id = MemberId,roomtype = MyRoomType} = Room_Member,

      ?IF(ets:lookup(?ROOM_PLAYER, MemberId) =:= [],ok,?C2SERR(?Already_In_Room)),
      % 3更新要加队员的信息

      MemberState = case GameStartTime =:= -1 andalso ?Friend_Room_create =:= MyRoomType of
                      true->
                          ?PLAYER_STATE_NORMAL;
                      false->
                          ?PLAYER_Ready
                    end,
%%      {Pos,IsSendGameResult} = case CacheList of
%%              []->
%%                {do_get_idle_pos(MemberList),false};
%%              _->
%%                [MyMember] = [X|| #room_member{id = Id} = X <-CacheList,Id =:= MemberId],
%%                #room_member{pos = Mypos,isGetGameResult = SendGameResult} = MyMember,
%%                {Mypos,SendGameResult}
%%
%%            end,

      Func =

        fun(#room_member{id = Id}= Member)->

          case Id =:= MemberId of
            true ->
              ResMember = Member#room_member{state = MemberState},
              ResMember;
            false ->
              ResMember = Member
          end,

          ResMember
        end,
      NewMemberList = lists:map(Func, MemberList),

      TempList = [X|| #room_member{id = TempId} = X <-NewMemberList,TempId =:= MemberId],

      [#room_member{}=MyMember] =TempList,

      % 4更新table数据
      Room2 = Room#room{member = NewMemberList},
      ets:insert(?ROOM, Room2),
      ets:insert(?ROOM_PLAYER, {MemberId, RoomId}),
      {Room2, MyMember}

  end.


%%memberlist 根据pos排序

do_sort_by_pos(L) ->
  lists:sort(fun(M1, M2) -> M1#room_member.pos =< M2#room_member.pos end, L).

do_set_member_state(PlayerId,RoomId,ChangeIndex,ChangeValue) ->

  ?IF((R = ets:lookup(?ROOM, RoomId)) =:= [],
    ?C2SERR(?Room_No_Find), ok),
  [#room{member = MemberList} = Room] = R,
  Func =

    fun(#room_member{id = Id}= Member)->

      case Id =:= PlayerId of
        true ->
          case ChangeIndex of
            ?CHANGE_STATE ->
              ResMember = Member#room_member{state = ChangeValue},
              ResMember;
            ?CHANGE_MONEY_Rand_Data ->
              ResMember = Member#room_member{moneyRank = ChangeValue},
              ResMember;
            ?CHANGE_WIN_RANK_DATA ->
            ResMember = Member#room_member{winRank  = ChangeValue},
            ResMember;
            ?CHANGE_LOSE_DATE ->
              ResMember = Member#room_member{loseRank = ChangeValue},
              ResMember;
            _ ->
              ResMember = Member,
              ResMember
          end;
        false ->
          ResMember = Member
      end,

      ResMember
    end,
  NewMemberList = lists:map(Func, MemberList),

  %?IF(NewMemberList =:= MemberList,
   % ?C2SERR(?Member_No_Find), ok),

  Room2 = Room#room{member = NewMemberList},

  ?IF(ChangeValue =:= ?PLAYER_OFFlINE,true = ets:delete(?ROOM_PLAYER, PlayerId),ok),

  ets:insert(?ROOM, Room2),

  %?INFO(?_U("新的玩家列表:~p"), [NewMemberList]),
  NewMemberList.


do_set_room_state(RoomId, RoomState,Turn) ->
  ?IF((R = ets:lookup(?ROOM, RoomId)) =:= [],
    ?C2SERR(?Room_No_Find), ok),
  [Room] = R,
  Room2 = Room#room{turn = Turn,roomstate = RoomState},
  Room2.

do_set_room_state(RoomId, AddMoney) ->
  ?IF((R = ets:lookup(?ROOM, RoomId)) =:= [],
    ?C2SERR(?Room_No_Find), ok),
  [Room] = R,
  #room{table_money = OldMoney} = Room,
  Room2 = Room#room{table_money = OldMoney + AddMoney},
  Room2.

%%判断要删除的队员是否存在
%%删除table中的队员信息
%%如果删除完memberlist2为空，解散队伍
%%如果memberlis2==membelist表明删除玩家未成功
%%最后删除的如果是队长更改队长id，否则为原来leaderid
do_delete_member(RoomId, MemberId) ->
  ?IF((R = ets:lookup(?ROOM, RoomId)) =:= [],
  ?C2SERR(?Room_No_Find), ok),
  [#room{member = MemberList} = Room] = R,
  true = ets:delete(?ROOM_PLAYER, MemberId),
  MemberList2 = lists:keydelete(MemberId, #room_member.id, MemberList),

  case MemberList2 of
    %ß[] ->

      % 队伍为空，解散
     % do_delete_free_list(RoomId),
      %do_delete(RoomId),
      %[];
    MemberList ->
      % 删除的队员不存在(此人已经通过离开或者开除操作离开队伍)
      ?DEBUG(?_U("删除内的玩家的不存在~w"),[MemberId]),
      [];
    _ ->




      %?DEBUG(?_U("删除内的玩家的不存在~w"),[NewCacheList1]),
      %?INFO(?_U("房间cache delete成员:~p"), [NewCacheList1]),
      Room2 = Room#room{member = MemberList2},

      %?DEBUG(?_U("房间~w删除玩家~w,新的成员列表:~w!"), [RoomId, MemberId, MemberList2]),
      true = ets:insert(?ROOM, Room2),
      MemberList2
  end.
%%获取队伍中没被占用的pos
do_get_idle_pos(MemberList) ->
  PosList = [Pos || #room_member{pos = Pos} <- MemberList],
  [PosIdle | _]= ?ROOM_POS_LIST_FULL -- PosList,
  PosIdle.

do_for(Max,Max)->[Max];
do_for(I,Max)->[I|do_for(I+1,Max)].

shuffle(L) ->
  shuffle(list_to_tuple(L), length(L)).

shuffle(T, 0)->
  tuple_to_list(T);
shuffle(T, Len)->
  Rand = wg_util:rand(1,Len),
  A = element(Len, T),
  B = element(Rand, T),
  T1 = setelement(Len, T,  B),
  T2 = setelement(Rand,  T1, A),
  shuffle(T2, Len - 1).

send_msg_broadcast([], _MsgId, _Msg )->
  ok;
send_msg_broadcast(MemberList, MsgId, Msg) ->
  [begin

     ?IF(Member#room_member.state =:= ?PLAYER_OFFlINE,ok,ok = ?S2C_SEND_MERGE:player(Member#room_member.id, MsgId, Msg))

   end || Member <- MemberList],
  ok.