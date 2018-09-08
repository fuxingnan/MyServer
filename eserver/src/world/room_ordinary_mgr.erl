
-module(room_ordinary_mgr).
-author("fuxing").
-vsn('0.1').
-include("wg.hrl").
-include("game.hrl").
%-include("../src/player/player_internal.hrl").
%-include("game_hooks.hrl").
%-include("../src/proto/proto.hrl").
-include("room.hrl").
%-include("player.hrl").

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1]).


%% 查询相关

-export([get/1,member_count/1,is_full/1,player_room_id/1,get_free_id/0,is_all_ready/1,get_new_poker_list/0,set/1,check_reconnect/3,reconnect_add_member/2]).


%% 创建添加更新

-export([create/1,create_table/0,add_member/2,set_room_status/3,set_member_status/4,set_table_Money/2,add_keep_pos/1,delete_keep_pos/1,reset_keep_pos/1]).


%% 删除

-export([delete/1,delete_member/2]).


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


%% 表名称

-define(ROOM, 'room_ordinary').
-define(ROOM_PLAYER, 'room_ordinary_player').
-define(FREE_ROOM_LIST, 'free_room_ordinary_list').
%% @doc 启动

start_link()->
  ?DEBUG(?_U("启动room__newplayer_mgr服务"),[]),
  gen_server:start_link(?START_NAME, ?MODULE, [], []).


%%初始化

init(_Type) ->
  erlang:process_flag(trap_exit, true),
  erlang:process_flag(priority, high),
  create_table(),
  register(?NAME, self()),
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
  ok.

%%获得新的扑克列表
get_new_poker_list()->
  shuffle(do_for(0,107)).
%%创建房间

create(Room_Member) ->
  call({create, Room_Member}).

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

    [#room_free{roomlist = FreeList} = RoomFree] ->

      % 更新table数据
      case length(FreeList) =:= 0 of
        true ->
          noFreeRoom;
        false ->
          N = wg_util:rand(1,length(FreeList)),
          Id = lists:nth(N,FreeList)
      end
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
  #room{table_money = TableMoney,member = MemberList} = ?MODULE:get(RoomId),
  IsReconnect = TableMoney > 0 andalso length(MemberList) =:=1,
  case {length(MemberList) > 1,IsReconnect} of
    {_,true} ->
      lists:all
      (
        fun(#room_member{state = State }=MyMember) ->
          ?IF(State =:= ?PLAYER_Ready, true, false)
        end,
        MemberList
      );
    {false,_} ->
      false;
    {true,_} ->
      lists:all
      (
        fun(#room_member{state = State }=MyMember) ->
          ?IF(State =:= ?PLAYER_Ready, true, false)
        end,
        MemberList
      )
  end.

%%判断队伍是否满

is_full(RoomId) ->
  #room{member = MemberList} = ?MODULE:get(RoomId),
  length(MemberList)  >= ?ROOM_MEMBER_MAX.

handle_call({create, Room_Member}, _From, #state{id_new = IdNew} = State) ->
  Poker = shuffle(do_for(0,107)),
  %?DEBUG(?_U("初始化房间扑克列表:~p"), [Poker]),
  Room_Member2 = Room_Member#room_member{pos = 1},
  Room = #room
  {
    id = IdNew,
    turn = 0,
    min_money = ?OrdinaryRoom_MinMoney_di,
    roomstate = ?ROOM_WAIT_READY,
    pork_list = Poker,
    member = [Room_Member2]
  },
  #room_member{id = PlayerId} = Room_Member2,


  %更新table信息
  do_add_free_list(IdNew),
  true = ets:insert(?ROOM, Room),
  true = ets:insert(?ROOM_PLAYER, {PlayerId, IdNew}),
  {reply, Room, State#state{id_new = IdNew + 1}};


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

handle_call({check_reconnect,RoomId,MemberId,GameNum}, _From, State) ->
  %根据teamid 在table中查询，如果找到返回#team信息，
  % 未找到返回#team内容都为空
  Reply =
    case ets:lookup(?ROOM, RoomId) of
      [#room{gameNum = CurGameNum} = _Room] ->
        case ets:lookup(?ROOM_PLAYER, MemberId) =:= [] of
          true->
            ?IF(CurGameNum =:= GameNum,?Need_Reconnect,?No_Need_Reconnect);
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


%%解散队伍


do_delete(RoomId) ->

  case ets:lookup(?ROOM, RoomId) of
    [] ->
      ?INFO(?_U("删除房间不存在:~p"), [1]),
      ?C2SERR(?Room_No_Find);
    [#room{member = MemberList} = Room] ->
      %删除队伍
      true = ets:delete(?ROOM, RoomId),
%%      [true = ets:delete(?ROOM_PLAYER, MemberId)
%%        || #room_member{id = MemberId} <- MemberList],
      %?INFO(?_U("删除房间成功:~p"), [1]),
      Room
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
      %?INFO(?_U("添加后的free列表:~p"), [RoomId | NewFreeList]),
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

    [#room{roomstate = RoomState,table_money = Table_Money,keepnum = KeepNum,member = MemberList} = Room] ->
      % 1 人数判断
      ?IF(length(MemberList)  < ?ROOM_MEMBER_MAX, ok,
        ?C2SERR(?Room_Full)),
      % 2要加的队员是否已经在队伍里
      #room_member{id = MemberId} = Room_Member,

      ?IF(ets:lookup(?ROOM_PLAYER, MemberId) =:= [], ok,
        ?C2SERR(?Already_In_Room)),
      % 3更新要加队员的信息


      case {length(MemberList) =:= 0,Table_Money > 0} of
        {true,true}->
          Member = Room_Member#room_member{
            pos = do_get_idle_pos(MemberList),
            state = ?PLAYER_Ready
          },
          NewMemberList = do_sort_by_pos([Member | MemberList]),
          Room2 = Room#room{roomstate = ?ROOM_START,member = NewMemberList},
          ets:insert(?ROOM, Room2),
          ets:insert(?ROOM_PLAYER, {MemberId, RoomId}),
          PeopleNum = length(NewMemberList) +KeepNum,
          ?IF(PeopleNum  < ?ROOM_MEMBER_MAX, ok,do_delete_free_list(RoomId)),
          {Room2, Member};

        _->
          ?IF(RoomState =:= ?ROOM_START, MemberState = ?PLAYER_OBSERVER,MemberState = ?PLAYER_STATE_NORMAL),
          Member = Room_Member#room_member{
            pos = do_get_idle_pos(MemberList),
            state = MemberState
          },
          %?INFO(?_U("add room:~p"), [Member]),
          NewMemberList = do_sort_by_pos([Member | MemberList]),
          Room2 = Room#room{member = NewMemberList},
          ets:insert(?ROOM, Room2),
          ets:insert(?ROOM_PLAYER, {MemberId, RoomId}),
          PeopleNum = length(NewMemberList) +KeepNum,
          ?IF(PeopleNum  < ?ROOM_MEMBER_MAX, ok,do_delete_free_list(RoomId)),
          {Room2, Member}
      end
  end.
do_reconnect_add_member(RoomId, Room_Member) ->
  case ets:lookup(?ROOM, RoomId) of
    [] ->

      ?C2SERR(?Room_No_Find);

    [#room{keepnum = KeepNum,member = MemberList} = Room] ->
      % 1 人数判断
      ?IF(length(MemberList)  < ?ROOM_MEMBER_MAX, ok,
        ?C2SERR(?Room_Full)),
      % 2要加的队员是否已经在队伍里
      #room_member{id = MemberId} = Room_Member,

      ?IF(ets:lookup(?ROOM_PLAYER, MemberId) =:= [], ok,
        ?C2SERR(?Already_In_Room)),
      % 3更新要加队员的信息


      Member = Room_Member#room_member{
        pos = do_get_idle_pos(MemberList),
        state = ?PLAYER_Ready
      },
      %?INFO(?_U("添加成员:~p"), [Member]),
      % 4更新table数据
      NewMemberList = do_sort_by_pos([Member | MemberList]),
      NewKeepNum = KeepNum - 1,
      ?IF(NewKeepNum < 0, NewKeepNum1 = 0,NewKeepNum1 = NewKeepNum),
      Room2 = Room#room{roomstate = ?ROOM_START, member = NewMemberList,keepnum = NewKeepNum1},
      ets:insert(?ROOM, Room2),
      ets:insert(?ROOM_PLAYER, {MemberId, RoomId}),
      PeopleNum = length(NewMemberList) +NewKeepNum1,
      ?IF(PeopleNum  < ?ROOM_MEMBER_MAX, ok,do_delete_free_list(RoomId)),
      {Room2, Member}

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
  ?IF(NewMemberList =:= MemberList,
    ?C2SERR(?Member_No_Find), ok),

  Room2 = Room#room{member = NewMemberList},

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
  [#room{member = MemberList,table_money = TableMoney,keepnum = KeepNum} = Room] = R,
  true = ets:delete(?ROOM_PLAYER, MemberId),
  MemberList2 = lists:keydelete(MemberId, #room_member.id, MemberList),

  case MemberList2 of
    [] ->

      % 队伍为空，解散
      case TableMoney =:= 0 of
        true ->
          do_delete_free_list(RoomId),
          do_delete(RoomId);
        false ->
          Room2 = Room#room{turn = 0,roomstate = ?ROOM_WAIT_READY,member = MemberList2},
          true = ets:insert(?ROOM, Room2)
      end,
      [];
    MemberList ->
      % 删除的队员不存在(此人已经通过离开或者开除操作离开队伍)
      ?DEBUG(?_U("删除内的玩家的不存在~w"),[MemberId]),
      [];
    _ ->

      Room2 = Room#room{member = MemberList2},

      %?DEBUG(?_U("房间~w删除玩家~w,新的成员列表:~w!"), [RoomId, MemberId, MemberList2]),
      PeopleNum = length(MemberList2) + KeepNum,
      ?IF(PeopleNum < (?ROOM_MEMBER_MAX), do_add_free_list(RoomId),ok),

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