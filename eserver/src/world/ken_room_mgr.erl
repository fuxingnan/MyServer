
-module(ken_room_mgr).
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

-export([get/1,is_full/1,is_all_ready/1,set/1,check_reconnect/3,reconnect_add_member/2]).


%% 创建添加更新

-export([create/9,create_table/0,add_member/2,set_member_status/4]).


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

-define(ROOM_POS_LIST_FULL, [1, 2, 3, 4,5]).

%% 表名称

-define(ROOM, 'room_friend_ken').
-define(ROOM_PLAYER, 'room_friend_ken_player').
-define(FREE_ROOM_LIST, 'kenfriend_room_list').
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
    {ken_friend_room_count, length(L)}
  ].

start_link()->
    ?DEBUG(?_U("启动ken_room__friend_mgr服务"),[]),
    gen_server:start_link(?START_NAME, ?MODULE, [], []).




init(_Type) ->
    erlang:process_flag(trap_exit, true),
    erlang:process_flag(priority, high),
    create_table(),
    register(?NAME, self()),
    {ok, #state{}}.

create_table() ->
    ?ROOM = ets:new(?ROOM, [set, public, named_table,
            {keypos, #room_ken.id},
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
    ok.
%%创建房间





create(Room_Member,MaxPerson,MinPoker,MaxBet,LastIsBoom,IsDouble,MinMoney,GameTimes,NeedCard) ->
  call({create, Room_Member,MaxPerson,MinPoker,MaxBet,LastIsBoom,IsDouble,MinMoney,GameTimes,NeedCard}).

set_member_status(PlayerId,RoomId,ChangeIndex,ChangeValue) ->
  call({member_state,PlayerId,RoomId,ChangeIndex,ChangeValue}).

check_reconnect(RoomId,MemberId,GameNum)->
  call({check_reconnect,RoomId,MemberId,GameNum}).
get(RoomId) ->
  call({get, RoomId}).

set(Room) ->
  call({set, Room}).



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

is_all_ready(RoomId) ->
  #room_ken{member = MemberList} = ?MODULE:get(RoomId),

  case length(MemberList) > 1 of
    true->
      lists:all
      (
        fun(#room_member{state = State }=_MyMember) ->
          ?IF(State =:= ?PLAYER_Ready, true, false)
        end,
        MemberList
      );
    _->
      false
  end.

%%判断队伍是否满

is_full(RoomId) ->
  #room_ken{member = MemberList,person_num = MaxPerson} = ?MODULE:get(RoomId),
  length(MemberList)  >= MaxPerson.

handle_call({create, Room_Member,MaxPerson,MinPoker,MaxBet,LastIsBoom,IsDouble,MinMoney,GameTimes,NeedCard}, _From, State) ->
  ?INFO(?_U("创建填大坑房间成功:~p"), [1]),
  Room_Member2 = Room_Member#room_member{pos = 1},
  #room_member{id = PlayerId} = Room_Member2,
  ChipsOne = MaxBet/5,
  ChipsTwo = ChipsOne + (MaxBet - ChipsOne)/2,
  Poker = case MinPoker of
            9->
              shuffle(do_for(0,23));
            10->
              shuffle(do_for(0,19));
            11->
              shuffle(do_for(0,15))
          end,
  CreateRoomId = do_get_room_random_id(),

  Room = #room_ken
  {
        id = CreateRoomId,
        person_num = MaxPerson,
        min_poker = MinPoker,
        table_money = 0,
        min_money = MinMoney,
        max_bet = MaxBet,
        isDouble = IsDouble,
        last_is_boom = LastIsBoom,
        roomstate = ?ROOM_WAIT_READY,
        pork_list = Poker,
        member = [Room_Member2],
        need_card = NeedCard,
        game_times = GameTimes,
        chip_one = ChipsOne,
        chip_two = ChipsTwo,
        chip_three = MaxBet

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
      [#room_ken{} = Room] ->
        Room;
      [] ->
        Room = #room_ken{id = ?NULL_ROOMID} ,
        Room
    end,
  {reply, Reply, State};

handle_call({check_reconnect,RoomId,MemberId,_GameNum}, _From, State) ->
  %根据teamid 在table中查询，如果找到返回#team信息，
  % 未找到返回#team内容都为空
  Reply =
    case ets:lookup(?ROOM, RoomId) of
      [#room_ken{} = _Room] ->
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
    [#room_ken{member = MemberList} = Room] ->
      %删除队伍
      true = ets:delete(?ROOM, RoomId),
      [true = ets:delete(?ROOM_PLAYER, MemberId)
        || #room_member{id = MemberId} <- MemberList],
      %?INFO(?_U("删除房间成功:~p"), [1]),
      Room
  end.

do_get_room_random_id()->
  RandomId = wg_util:rand(200001,300000),
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

    [#room_ken{roomstate = RoomState,member = MemberList,person_num = PerSonNum} = Room] ->
      % 1 人数判断
      ?IF(length(MemberList)  < PerSonNum, ok,
        ?C2SERR(?Room_Full)),
      % 2要加的队员是否已经在队伍里
      #room_member{id = MemberId} = Room_Member,

      ?IF(ets:lookup(?ROOM_PLAYER, MemberId) =:= [], ok,
        ?C2SERR(?Already_In_Room)),

      ?IF(RoomState =:= ?ROOM_START, ?C2SERR(?Friend_Room_Already_Start_Error),ok),


      Member = Room_Member#room_member
      {
        pos = do_get_idle_pos(MemberList),
        state = ?PLAYER_STATE_NORMAL
      },
      NewMemberList = do_sort_by_pos([Member | MemberList]),
      Room2 = Room#room_ken{member = NewMemberList},
      ets:insert(?ROOM, Room2),
      ets:insert(?ROOM_PLAYER, {MemberId, RoomId}),
      {Room2, Member}

  end.

do_reconnect_add_member(RoomId, Room_Member) ->
  case ets:lookup(?ROOM, RoomId) of
    [] ->

      ?C2SERR(?Room_No_Find);

    [#room_ken{member = MemberList,roomstate = RoomState} = Room] ->
      % 1 人数判断
%%      ?IF(length(MemberList)  < ?ROOM_MEMBER_MAX, ok,
%%        ?C2SERR(?Room_Full)),
      % 2要加的队员是否已经在队伍里
      #room_member{id = MemberId,roomtype = MyRoomType} = Room_Member,

      ?IF(ets:lookup(?ROOM_PLAYER, MemberId) =:= [],ok,?C2SERR(?Already_In_Room)),
      % 3更新要加队员的信息

      MemberState = case RoomState =:= ?ROOM_WAIT_READY andalso ?KenFriend_Room_create =:= MyRoomType of
                      true->
                        ?PLAYER_STATE_NORMAL;
                      false->
                        ?PLAYER_Ready
                    end,
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
      Room2 = Room#room_ken{member = NewMemberList},
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
  [#room_ken{member = MemberList} = Room] = R,
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

  Room2 = Room#room_ken{member = NewMemberList},

  ets:insert(?ROOM, Room2),
  ?IF(ChangeValue =:= ?PLAYER_OFFlINE,true = ets:delete(?ROOM_PLAYER, PlayerId),ok),
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
  [#room{member = MemberList,member_cache = CacheList,game_start_time = GameTime} = Room] = R,
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

      NewCacheList1 = case GameTime == -1 of
                        true->
                          [];
                        false->
                          NewCacheList = lists:keydelete(MemberId, #room_member.id, CacheList),
                          [MyMember] = [X|| #room_member{id = Id} = X <-MemberList,Id =:= MemberId],
                          NewAddMember = MyMember#room_member{state = ?PLAYER_OFFlINE},
                          [NewAddMember | NewCacheList]
                      end,



      %?DEBUG(?_U("删除内的玩家的不存在~w"),[NewCacheList1]),
      %?INFO(?_U("房间cache delete成员:~p"), [NewCacheList1]),
      Room2 = Room#room{member = MemberList2,member_cache = NewCacheList1},

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