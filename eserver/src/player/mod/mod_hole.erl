
-module(mod_hole).
-compile([export_all]).
-include("wg.hrl").
-include("game.hrl").
-include("room.hrl").
-include("../src/player/player_internal.hrl").
-include("game_hooks.hrl").
-include("../src/proto/proto.hrl").
-include("pbmessage_pb.hrl").

-behaviour(gen_mod).
-export([start/0]).

%% gen_mod回调函数
-export([i/1, p/1, init/1, terminate/0,
  init_player/2, gather_player/1, terminate_player/1,
  handle_c2s/3, handle_timeout/2, handle_s2s_call/2,handle_s2s_cast/2]).

-export([start_delay_result_timer/2,cancle_delay_by_time/1,get_msg_id/1,do_game_result/3]).





start_delay_result_timer(Time,Fun) ->
  gen_mod:cancel_absolute_timer(?MODULE,Time),
  gen_mod:start_absolute_timer(?MODULE, Time, ?DELAY_CALC_EVENT(Fun)).

cancle_delay_by_time(Time)->
  gen_mod:cancel_absolute_timer(?MODULE,Time).

i(#player{room_id = RoomId}) ->
    [{room_id, RoomId}].

p(Info)->
    ok.

terminate() ->
  ok.
terminate_player(_Player) ->
  ok.

init_player(Player, ?NEW) ->
  Player;
init_player(Player, {?MIGRATE, ?NONE}) ->
  Player.


gather_player(_Player) ->
  ?NONE.

handle_timeout(?DELAY_CALC_EVENT(Fun), #player{roomtype = RoomType, room_id = RoomId} = Player) ->

  Player2 = Fun(Player),
  %?DEBUG(?_U("收到延迟累消息:~p"), [Player2]),
  {ok, Player2};
handle_timeout(_Event, Player) ->
  ?DEBUG(?_U("收到未知time消息:~p"), [_Event]),
  {ok, Player}.

handle_s2s_call(_Req, Player) ->
  ?DEBUG(?_U("未知的s2s_call请求: ~p"), [_Req]),
  {unknown, Player}.

start()->
    gen_mod:start_module(?MODULE, []).

init([]) ->
    ok.

handle_s2s_cast({?Reset_GAME, Code1,Code2}, Player) ->

  #player{id = SendId,roomtype = RoomType} = Player,
  %?DEBUG(?_U("还原玩家准备:~w"), [1]),
  Msg = #gc_ret_ready
  {
    usr_id  = Code1,
    unit_id = Code2
  },
  MsgId = ?PROTO_CONVERT({?MODULE, gc_ret_ready}),

  ok = ?S2C_SEND_MERGE:player(SendId, MsgId, Msg),

  check_player_prepare(),

  Player2 = Player#player{unit_id = Code2,user_id = Code1},

  {ok, Player2};
handle_s2s_cast({?Lose_Video,SendId}, Player) ->

  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),

  #player{loseRank = LoseRank} = Player,
  #lose_rank_data{poker_num = CardNum,money = VideoMoney,table_money = TableMoney,cardone = CardOne,cardtwo = CardTwo,mypos = MyPos,name_list = NameList,image_list = ImageList,money_list = MoneyList,pos_list = PosList} = LoseRank,
  ?DEBUG(?_U("还原玩家准备:~w"), [SendId]),
  ?INFO(?_U("单次输最多纪录发送:~p"), [LoseRank]),
  Msg = #gc_rank_win_money_video
  {
    usr_id  = Code1,
    my_pos = MyPos,
    table_money = TableMoney,
    video_money = VideoMoney,
    cardone = CardOne,
    cardtwo = CardTwo,
    name_list = NameList,
    head_list = ImageList,
    pos_list = PosList,
    money_list = MoneyList,
    cardnum = CardNum,
    unit_id = Code2
  },
  MsgId = ?PROTO_CONVERT({?MODULE, gc_rank_win_money_video}),

  ok = ?S2C_SEND_MERGE:player(SendId, MsgId, Msg),


  Player2 = Player,

  {ok, Player2};


handle_s2s_cast({?Win_Video,SendId}, Player) ->

  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),

  #player{winRank = WinRank} = Player,
  #win_rank_data{poker_num = CardNum,money = VideoMoney,table_money = TableMoney,cardone = CardOne,cardtwo = CardTwo,mypos = MyPos,name_list = NameList,image_list = ImageList,money_list = MoneyList,pos_list = PosList} = WinRank,
  ?DEBUG(?_U("还原玩家准备:~w"), [SendId]),
  ?INFO(?_U("单次赢最多纪录发送:~p"), [WinRank]),
  Msg = #gc_rank_win_money_video
  {
    usr_id  = Code1,
    my_pos = MyPos,
    table_money = TableMoney,
    video_money = VideoMoney,
    cardone = CardOne,
    cardtwo = CardTwo,
    name_list = NameList,
    head_list = ImageList,
    pos_list = PosList,
    money_list = MoneyList,
    cardnum = CardNum,
    unit_id = Code2
  },
  MsgId = ?PROTO_CONVERT({?MODULE, gc_rank_win_money_video}),

  ok = ?S2C_SEND_MERGE:player(SendId, MsgId, Msg),


  Player2 = Player,

  {ok, Player2};
handle_s2s_cast({?FRIEND_GAME_OVER}, Player) ->

  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),
  #player{id = SendId} = Player,
  %?DEBUG(?_U("游戏开始玩家:~w 抓牌:下底数~w"), [Turn, MinMoney]),
  Msg = #gc_game_over
  {
    usr_id =  Code1,
    unit_id = Code2
  },
  MsgId = ?PROTO_CONVERT({mod_room, gc_game_over}),

  ok = ?S2C_SEND_MERGE:player(SendId, MsgId, Msg),

  Player2 = Player#player{user_id = Code1,unit_id = Code2},
  {ok, Player2};
handle_s2s_cast({?START_GAME, Turn,MinMoney,CardOne,CardTWO,GameNum,CardNUM,TableMoney,IsFreshCard,LeftTime}, Player) ->

  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),
  #player{id = SendId,money = Money,roomtype = RoomType} = Player,
  %?DEBUG(?_U("游戏开始玩家:~w 抓牌:下底数~w"), [Turn, MinMoney]),
  Msg = #gc_player_turn
  {
    usr_id  = Code1,
    pos     =Turn,
    cardone = CardOne,
    cardtwo = CardTWO,
    cardnum = CardNUM,
    money = MinMoney,
    left_time = LeftTime,
    table_money = TableMoney,
    isfresh_card = IsFreshCard,
    unit_id = Code2
  },
  MsgId = ?PROTO_CONVERT({?MODULE, gc_player_turn}),

  ok = ?S2C_SEND_MERGE:player(SendId, MsgId, Msg),

  case RoomType of
    ?Friend_Room_create->
      Player2 = Player#player{user_id = Code1,unit_id = Code2,gamenum = GameNum};
    ?Friend_Room_join->
      Player2 = Player#player{user_id = Code1,unit_id = Code2,gamenum = GameNum};
    _->
      Player2 = Player#player{user_id = Code1,unit_id = Code2,money = Money - MinMoney,gamenum = GameNum}
  end,

  {ok, Player2}.

%%处理创建队伍消息

%%-record(room_member, {
%%  pos,            % 玩家在队伍中的编号
%%  id,             % 玩家id
%%  state = ?PLAYER_STATE_NORMAL, % 在线状态
%%  name = <<>>,    % 姓名
%%  image = <<>>,    % 姓名
%%  money = 0 ,       % 性别
%%  pertime_win_money = 0,
%%  rank_money = 1,
%%  rank_win_money = 1
%%}).


handle_c2s(#cg_join_room{usr_id = BeginCode,room_type = RoomType,room_key = RoomKey,min_money = MinMoney,max_bet = MaxBet,is_double = IsDouble,unit_id = EndCode}, _MsgId,  #player{} = Player) ->
  #player{user_id = UserId, unit_id = UnitId} = Player,
  case {BeginCode == UserId andalso EndCode == UnitId,RoomType}of
    {true,_} ->
      case RoomType of
        ?Reconnect_Room ->
          Player2 = do_reconnect_room_logic(Player);
        ?Friend_Room_create->
          NewPlayer = Player#player{roomtype = RoomType},
          Player2 = do_create_friend_room(NewPlayer,MinMoney,MaxBet,IsDouble);
        ?Friend_Room_join->
          NewPlayer = Player#player{roomtype = RoomType},
          Player2 = do_friend_join(RoomKey,NewPlayer);
        _->
          NewPlayer = Player#player{roomtype = RoomType},
          Player2 = do_new_room_logic(NewPlayer)
      end,
      Player2;
    _ ->
      Player2 = Player,
      ?INFO(?_U("加入房间服务器验证码错误:~p"), [1]),
      Player2
  end,
    {ok, Player2};

handle_c2s(#cg_deleteroom{}, _MsgId,  #player{id = PlayerId,room_id = RoomId,roomtype = RoomType} = Player) ->

  Player2 = delete_friend_room(Player),

  {ok, Player2};


handle_c2s(#cg_force_join{}, _MsgId,  #player{} = Player) ->

  Player2 = do_force_join(Player),

  {ok, Player2};

handle_c2s(#cg_bet_money{usr_id = BeginCode,money = Money,unit_id = EndCode}=MsgBet, _MsgId,  #player{roomtype = RoomType,room_id = RoomId,id = PlayerId} = Player) ->
  #player{user_id = UserId,unit_id = UnitId} = Player,
  case BeginCode == UserId andalso EndCode == UnitId of
    true ->
      %?INFO(?_U("玩家开始下注:~p"), [1]),

    IsMyTurn = is_my_turn(RoomType,RoomId,PlayerId),
    Player2 = case Money =:= 0 of
              true->
                ?IF(IsMyTurn =:= true, Player3 = do_quit_bet(Player),Player3 = send_error_msg(Player));
              false->
                ?IF(IsMyTurn =:= true, Player3 = do_money_bet(Player,Money,MsgBet),Player3 = send_error_msg(Player))
            end;
    false ->
      Player2 = Player,
      ?INFO(?_U("玩家下注版本号不对:~p"), [1])
  end,
  {ok, Player2};

handle_c2s(#cg_get_rank{usr_id = BeginCode,type = RankType,unit_id = EndCode}, _MsgId,  #player{id =PlayerId} = Player) ->
  #player{user_id = UserId,unit_id = UnitId} = Player,
  case BeginCode == UserId andalso EndCode == UnitId of
    true ->
      %?INFO(?_U("获得排行榜信息:~p"), [1]),
      do_get_rank(PlayerId,RankType);
    false ->
      ?INFO(?_U("获得排行榜信息版本号不对:~p"), [1])
  end,
  {ok, Player};
handle_c2s(#cg_get_video{usr_id = BeginCode,player_id = GetId,type = Type,unit_id = EndCode}, _MsgId,  #player{id =PlayerId} = Player) ->
  #player{user_id = UserId,unit_id = UnitId} = Player,
  case BeginCode == UserId andalso EndCode == UnitId of
    true ->
      do_get_video(GetId,Type,PlayerId);
    false ->
      ?INFO(?_U("获得video信息版本号不对:~p"), [1])
  end,
  {ok, Player};
handle_c2s(#cg_quit_room{usr_id = BeginCode,type = Type,unit_id = EndCode}, _MsgId,  #player{} = Player) ->
  #player{user_id = UserId,unit_id = UnitId} = Player,
  case BeginCode == UserId andalso EndCode == UnitId of
    true ->
      %?INFO(?_U("玩家退出房间:~p"), [1]),
      Player2 = do_quit_room(Player,Type);
    false ->
      %?INFO(?_U("玩家退出房间版本号不对:~p"), [1]),
      Player2 = Player
  end,
  {ok, Player2};

handle_c2s(#cg_add_money{usr_id = BeginCode,roomtype = RoomType,unit_id = EndCode}, _MsgId,  #player{id = PlayerId,money = MyMoney,room_id = RoomId,user_id = UserId, unit_id = UnitId} = Player) ->
  case {BeginCode == UserId andalso EndCode == UnitId,RoomType} of
    {true,?New_Room} ->
      %?INFO(?_U("新手房准备时,当前的金钱树:~p"), [MyMoney]),
      ?IF(MyMoney >=  ?NewRoom_MinMoney, change_ready_player_state(RoomType,PlayerId,RoomId,?PLAYER_Ready,?CHANGE_STATE),ok);
    {true,?Ordinary_Room} ->
      %?INFO(?_U("普通房准备时,当前的金钱树:~p"), [MyMoney]),
      ?IF(MyMoney >=  ?OrdinaryRoom_MinMoney, change_ready_player_state(RoomType,PlayerId,RoomId,?PLAYER_Ready,?CHANGE_STATE),ok);
    {true,?Master_Room} ->
      %?INFO(?_U("高手准备时,当前的金钱树:~p"), [MyMoney]),
      ?IF(MyMoney >=  ?MasterRoom_MinMoney, change_ready_player_state(RoomType,PlayerId,RoomId,?PLAYER_Ready,?CHANGE_STATE),ok);
    {true,?Friend_Room_create} ->
      case friend_room_is_can_start(Player) of
        true->
          change_ready_player_state(RoomType,PlayerId,RoomId,?PLAYER_Ready,?CHANGE_STATE);
        false->
          Msg = #gc_friend_result
          {
            result = ?Other_No_Prepare
          },
          MsgId = ?PROTO_CONVERT({?MODULE, gc_friend_result}),
          ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg);
        ?No_Enough_Player->
          Msg = #gc_friend_result
          {
            result = ?No_Enough_Player
          },
          MsgId = ?PROTO_CONVERT({?MODULE, gc_friend_result}),
          ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg);
      _->
        ?INFO(?_U("好友房间开始,房间没有找到:~p"), [1])
      end;
    {true,?Friend_Room_join} ->
      change_ready_player_state(RoomType,PlayerId,RoomId,?PLAYER_Ready,?CHANGE_STATE);
    _ ->
      ?INFO(?_U("准备时服务器验证码错误:~p"), [1])
  end,
  {ok, Player}.


delete_friend_room(Player)->
  #player{roomtype = RoomType,room_id = RoomId} = Player,
  case catch get_room(RoomType,RoomId) of
    #room{member = MemberList}=_Room ->
      Msg = #gc_deleteroom
      {
        result = ?E_OK
      },
      MsgId = ?PROTO_CONVERT({?MODULE, gc_deleteroom}),
      send_msg_broadcast(MemberList,MsgId, Msg),
      room_friend_mgr:delete(RoomId),
      Player#player{room_id = -1,roomtype = -1};
    _->
      ?INFO(?_U("解散好友房间没有找到房间:~p"), [1]),
      Player
  end.
get_msg_id(Type)->
  ?PROTO_CONVERT({?MODULE, Type}).

set_room(Room,RoomType)->
  case RoomType of
    ?New_Room ->
      room_newplayer_mgr:set(Room);
    ?Ordinary_Room ->
      room_ordinary_mgr:set(Room);
    ?Master_Room ->
      room_master_mgr:set(Room);
    ?Friend_Room_create ->
      room_friend_mgr:set(Room);
    ?Friend_Room_join ->
      room_friend_mgr:set(Room);
    _ ->
      ?INFO(?_U("更新全部room,信息失败:~p"), [RoomType]),
      ?C2SERR(?Room_No_Find)
  end.

get_room(RoomType,RoomId)->
  case RoomType of
    ?New_Room ->
      room_newplayer_mgr:get(RoomId);
    ?Ordinary_Room ->
      room_ordinary_mgr:get(RoomId);
    ?Master_Room ->
      room_master_mgr:get(RoomId);
    ?Friend_Room_create ->
      room_friend_mgr:get(RoomId);
    ?Friend_Room_join ->
    room_friend_mgr:get(RoomId);
    _ ->
      %?INFO(?_U("更新全部room,信息失败:~p"), [RoomType]),
      ?C2SERR(?Room_No_Find)
  end.
delete_member(RoomType,RoomId,PlayerId,QuitType,PlayerState,Table_Money)->
  case RoomType of
    ?New_Room ->
      case {QuitType =:= ?QUIT_NET_ERROR,PlayerState =:= ?PLAYER_Ready,Table_Money /= 0} of
        {true,true,true}->
          room_newplayer_mgr:add_keep_pos(RoomId);
        _->
          ok
      end,
      room_newplayer_mgr:delete_member(RoomId,PlayerId);
    ?Ordinary_Room ->
      case {QuitType =:= ?QUIT_NET_ERROR,PlayerState =:= ?PLAYER_Ready,Table_Money /= 0} of
        {true,true,true}->
          room_ordinary_mgr:add_keep_pos(RoomId);
        _->
          ok
      end,
      room_ordinary_mgr:delete_member(RoomId,PlayerId);
    ?Master_Room ->
      case {QuitType =:= ?QUIT_NET_ERROR,PlayerState =:= ?PLAYER_Ready,Table_Money /= 0} of
        {true,true,true}->
          room_master_mgr:add_keep_pos(RoomId);
        _->
          ok
      end,
      room_master_mgr:delete_member(RoomId,PlayerId);
    ?Friend_Room_create ->

      room_friend_mgr:delete_member(RoomId,PlayerId);
    ?Friend_Room_join ->
      room_friend_mgr:delete_member(RoomId,PlayerId);
    _ ->
      ?INFO(?_U("更新全部room,信息失败:~p"), [RoomType]),
      ?C2SERR(?Room_No_Find)
  end.

get_free_id(RoomType)->
  case RoomType of
    ?New_Room ->
      room_newplayer_mgr:get_free_id();
    ?Ordinary_Room ->
      room_ordinary_mgr:get_free_id();
    ?Master_Room ->
      room_master_mgr:get_free_id();
    _ ->
      ?INFO(?_U("更新全部room,信息失败:~p"), [RoomType]),
      ?C2SERR(?Room_No_Find)
  end.

create_room(RoomType,Member)->
  case RoomType of
    ?New_Room ->
      room_newplayer_mgr:create(Member);
    ?Ordinary_Room ->
      room_ordinary_mgr:create(Member);
    ?Master_Room ->
      room_master_mgr:create(Member);
    _ ->
      ?INFO(?_U("更新全部room,信息失败:~p"), [RoomType]),
      ?C2SERR(?Room_No_Find)
  end.
add_member(RoomType,RoomId,Member)->

  case RoomType of
    ?New_Room ->
      room_newplayer_mgr:add_member(RoomId,Member);
    ?Ordinary_Room ->
      %?INFO(?_U("添加成员:~p"), [Member]),
      room_ordinary_mgr:add_member(RoomId,Member);
    ?Master_Room ->
      room_master_mgr:add_member(RoomId,Member);
    _ ->
      ?INFO(?_U("更新全部room,信息失败:~p"), [RoomType]),
      ?C2SERR(?Room_No_Find)
  end.

add_reconnect_member(RoomType,RoomId,Member)->

  case RoomType of
    ?New_Room ->
      room_newplayer_mgr:reconnect_add_member(RoomId,Member);
    ?Ordinary_Room ->
      %?INFO(?_U("添加成员:~p"), [Member]),
      room_ordinary_mgr:reconnect_add_member(RoomId,Member);
    ?Master_Room ->
      room_master_mgr:reconnect_add_member(RoomId,Member);
    ?Friend_Room_create ->
      room_friend_mgr:reconnect_add_member(RoomId,Member);
    ?Friend_Room_join ->
      room_friend_mgr:reconnect_add_member(RoomId,Member);
    _ ->
      ?INFO(?_U("更新全部room,信息失败:~p"), [RoomType]),
      ?C2SERR(?Room_No_Find)
  end.


set_member_status(RoomType,PlayerId,RoomId,ChangIndex,PlayerState)->
  case RoomType of
    ?New_Room ->
      room_newplayer_mgr:set_member_status(PlayerId,RoomId,ChangIndex,PlayerState);
    ?Ordinary_Room ->
      room_ordinary_mgr:set_member_status(PlayerId,RoomId,ChangIndex,PlayerState);
    ?Master_Room ->
      room_master_mgr:set_member_status(PlayerId,RoomId,ChangIndex,PlayerState);
    ?Friend_Room_create ->
      room_friend_mgr:set_member_status(PlayerId,RoomId,ChangIndex,PlayerState);
    ?Friend_Room_join ->
      room_friend_mgr:set_member_status(PlayerId,RoomId,ChangIndex,PlayerState);
    _ ->
      ?INFO(?_U("更新全部room,信息失败:~p"), [RoomType]),
      ?C2SERR(?Room_No_Find)
  end.

is_all_ready(RoomType,RoomId)->
  case RoomType of
    ?New_Room ->
      room_newplayer_mgr:is_all_ready(RoomId);
    ?Ordinary_Room ->
      room_ordinary_mgr:is_all_ready(RoomId);
    ?Master_Room ->
      room_master_mgr:is_all_ready(RoomId);
    ?Friend_Room_create ->
      room_friend_mgr:is_all_ready(RoomId);
    ?Friend_Room_join ->
      room_friend_mgr:is_all_ready(RoomId);
    _ ->
      ?INFO(?_U("更新全部room,信息失败:~p"), [RoomType]),
      ?C2SERR(?Room_No_Find)
  end.

reset_keep_pos(RoomType,RoomId)->
  case RoomType of
    ?New_Room ->
      room_newplayer_mgr:reset_keep_pos(RoomId);
    ?Ordinary_Room ->
      room_ordinary_mgr:reset_keep_pos(RoomId);
    ?Master_Room ->
      room_master_mgr:reset_keep_pos(RoomId);
    ?Friend_Room_create ->
      room_friend_mgr:reset_keep_pos(RoomId);
    ?Friend_Room_join ->
      room_friend_mgr:reset_keep_pos(RoomId);
    _ ->
      ?INFO(?_U("更新全部room,信息失败:~p"), [RoomType]),
      ?C2SERR(?Room_No_Find)
  end.
do_force_join(Player)->
  #player{id = PlayerId,roomtype = RoomType,money = MyMoney,room_id = RoomId} = Player,

  case catch get_room(RoomType,RoomId) of
    #room{table_money = Table_money,roomstate = RoomState,min_money = MinMoney,member = Member}= Room ->
      NewTurnList = [X||#room_member{state = State} = X <-Member,State =:= ?PLAYER_Ready],

      PayMoney = Table_money/(length(NewTurnList) + 1),
      ?IF(PayMoney < MinMoney, PayMoney1 = MinMoney, PayMoney1 = PayMoney),
      PayMoney2 = trunc(PayMoney1/MinMoney)*MinMoney,
      %?INFO(?_U("加入房间需要消耗金币数:~p"), [PayMoney2]),
      [#room_member{pos  = MyPos,state = MyState}=MyMember] = [X|| #room_member{id = MemberId} = X <-Member,MemberId =:= PlayerId],
      case {RoomState =:= ?ROOM_START,Table_money > 0,length(Member) > 0,MyMoney >= PayMoney2} of
        {true,true,true,true}->
          %set_member_status(RoomType,PlayerId,RoomId,?CHANGE_STATE,?PLAYER_Ready),

          [#room_member{pos  = MyPos,state = MyState}=MyMember] = [X|| #room_member{id = MemberId} = X <-Member,MemberId =:= PlayerId],
          Player2 = case MyState =:= ?PLAYER_OBSERVER of
                    true->
                      NewMember1 = MyMember#room_member{state = ?PLAYER_Ready},
                      NewMemberList = do_change_member(PlayerId,RoomId,RoomType,NewMember1),
                      Room2 = Room#room{table_money = Table_money+PayMoney2,member = NewMemberList},
                      set_room(Room2,RoomType),

                      Code1 = wg_util:rand(1000,10000000),
                      Code2 = wg_util:rand(1000,10000000),

                      Player4 = Player#player{money = MyMoney-PayMoney2,user_id = Code1,unit_id = Code2},
                      Player5 = mod_attr:check_give_coins(Player4),
                      #player{money = AfterGiveMoney,user_id = NewCode1,unit_id = NewCode2,moneyRank = MoneyRank} = Player5,
                      MoneyRank1 = MoneyRank#money_rank_data{money = AfterGiveMoney},

                      Msg = #gc_force_join
                      {

                        usr_id  = NewCode1,
                        paymoney = PayMoney2,
                        curmoney =AfterGiveMoney,
                        pos =MyPos,
                        unit_id = NewCode2
                      },
                      MsgId = ?PROTO_CONVERT({?MODULE, gc_force_join}),
                      send_msg_broadcast(Member,MsgId,Msg),
                      Player5#player{moneyRank = MoneyRank1};
                    _->
                      do_send_msg_foice_fail(Player,MyPos)
                  end;

        _->
          Player2 = do_send_msg_foice_fail(Player,MyPos)
      end,
      Player2;
    _->
      ?INFO(?_U("强制加入时,房间没有找到:~p,"), [1]),
      Player
  end.


do_send_msg_foice_fail(Player,MyPos)->
  #player{id = PlayerId} = Player,
  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),
  Msg = #gc_force_join
  {
    usr_id  = Code1,
    paymoney = -1,
    curmoney =-1,
    pos = MyPos,
    unit_id = Code2
  },
  MsgId = ?PROTO_CONVERT({?MODULE, gc_force_join}),
  ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg),
  Player.


do_reconnect_room_logic(Player)->


  #player{id = PlayerId,roomtype = RoomType,room_id = RoomId,gamenum = GameNum,moneyRank = MoneyRankData,winRank = WinRankData,loseRank = LostRankData} = Player,

  %?IF(check_money_limit(RoomType,Player)=:=true,ok,?C2SERR(?Money_JoinRoom_Error)),


  case mod_attr:check_reconnect(RoomType,RoomId,PlayerId,GameNum) of
    ?Need_Reconnect->
      ?INFO(?_U("需要重新连接:~p"), [RoomType]),
      Member = #room_member
      {
        id = PlayerId,
        state = ?PLAYER_STATE_NORMAL,
        score = GameNum,
        moneyRank = MoneyRankData,
        winRank = WinRankData,
        loseRank = LostRankData
      },
      Player2 = do_add_reconnect_room_member(RoomType,RoomId,Member,Player),
      Player2;
    ?No_Need_Reconnect->

      Msg = #gc_reconnect_failed
      {
        usr_id = ?E_OK
      },
      MsgId = get_msg_id(gc_reconnect_failed),
      ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg),

      Player2 = Player,
      Player2
  end.

do_create_friend_room(Player,MinMoney,MaxBet,IsDouble)->
  #player{id = PlayerId,roomtype = RoomType,moneyRank = MoneyRankData,winRank = WinRankData,loseRank = LostRankData} = Player,
  ?IF(check_money_limit(RoomType,Player)=:=true,ok,?C2SERR(?Money_JoinRoom_Error)),
  Member = #room_member
  {
    id = PlayerId,
    state = ?PLAYER_STATE_NORMAL,
    moneyRank = MoneyRankData,
    winRank = WinRankData,
    loseRank = LostRankData
  },
  case catch room_friend_mgr:create(Member,MinMoney,MaxBet,IsDouble) of
    #room{} = Room ->
      %?INFO(?_U("创建新房间成功:~p"), [Room]),
      Code1 = wg_util:rand(1000,10000000),
      Code2 = wg_util:rand(1000,10000000),
      #room{id = RoomId,member = NewMember,roomstate = RoomState} = Room,
      [FirstMember|_] = NewMember,
      #room_member{id = PlayerId, moneyRank = MoneyRankData,pos = Pos,state = State,score = Money} = FirstMember,
      #money_rank_data{name = Name,image = Head} = MoneyRankData,
      Msg = #gc_join_room
      {
        result = ?E_OK,
        room_id = RoomState,
        room_type = RoomType,
        room_key = RoomId,
        usr_id = Code1,
        my_pos = Pos,
        cur_pos = 0,
        table_money = 0,
        min_money = MinMoney,
        max_bet = MaxBet,
        is_double = IsDouble,
        name_list = [Name],
        head_list = [Head],
        pos_list = [Pos],
        state_list = [State],
        money_list = [Money],
        unit_id = Code2,
        cardnum = 108
      },
      MsgId = ?PROTO_CONVERT({?MODULE, gc_join_room}),
      ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg),
      Player2 = Player#player{room_id = RoomId,roomtype =RoomType, unit_id = Code2,user_id = Code1},
      Player2;
    _ ->
      Player
  end.


do_friend_join(RoomId,Player)->
  #player{id = PlayerId,roomtype = RoomType,moneyRank = MoneyRankData,winRank = WinRankData,loseRank = LostRankData} = Player,
  ?IF(check_money_limit(RoomType,Player)=:=true,ok,?C2SERR(?Money_JoinRoom_Error)),
  Member = #room_member
  {
    id = PlayerId,
    state = ?PLAYER_STATE_NORMAL,
    moneyRank = MoneyRankData,
    winRank = WinRankData,
    loseRank = LostRankData
  },
  case catch room_friend_mgr:add_member(RoomId,Member) of
    {#room{} = Room2, #room_member{}=Member2} ->
      %?INFO(?_U("加入房间成功:~p"), [Member]),
      Code1 = wg_util:rand(1000,10000000),
      Code2 = wg_util:rand(1000,10000000),
      #room{id = RoomId,min_money = MinMoney,max_bet = MaxBet,isDouble = IsDouble,cardone = CardOne,cardtwo = CardTwo,pork_list = PorkerList,member = NewMember,roomstate = RoomState,table_money = TableMoney,turn = CurTurn} = Room2,
      #room_member{id = SelfId,pos = MyPos,moneyRank = MoneyRankData,state = SelfState,score = SelfMoney} = Member2,
      #money_rank_data{name = SelfName,image = SelfHead} = MoneyRankData,

      Val = lists:map
      (
        fun(TempMember) ->
          %?INFO(?_U("房间成员:~p"), [TempMember]),
          #room_member{id = SendId,moneyRank = MoneyRankData1,pos = Pos,state = State,score = Money} = TempMember,
          #money_rank_data{name = Name,image = Head} = MoneyRankData1,
          {Name, Head,Pos,State,Money,SendId}

        end,
        NewMember

      ),

      [K1,K2,K3,K4,K5,K6] = wg_lists:unzip_more(Val),

      Msg = #gc_join_room
      {
        result = ?E_OK,
        room_id = RoomState,
        room_type = RoomType,
        room_key = RoomId,
        usr_id = Code1,
        my_pos = MyPos,
        table_money = TableMoney,
        cur_pos = CurTurn,
        cardone =CardOne,
        cardtwo = CardTwo,
        min_money = MinMoney,
        max_bet = MaxBet,
        is_double = IsDouble,
        name_list = K1,
        head_list = K2,
        pos_list = K3,
        state_list = K4,
        money_list = K5,
        unit_id = Code2,
        cardnum = length(PorkerList)
      },
      AddMsg = #gc_add_member
      {
        usr_id = Code1,
        name   = SelfName,
        head   = SelfHead,
        pos    = MyPos,
        state  = SelfState,
        money  = SelfMoney,
        unit_id   = Code2
      }
      ,
      MsgId = get_msg_id(gc_join_room),
      MsgId2 = get_msg_id(gc_add_member),
      lists:map
      (
        fun(IdToSend) ->
          ?IF( IdToSend=:= SelfId, ok = ?S2C_SEND_MERGE:player(IdToSend, MsgId, Msg),
            ok = ?S2C_SEND_MERGE:player(IdToSend, MsgId2, AddMsg))

        end,
        K6

      ),
      %?INFO(?_U("加入d房间成员状态:~p"), [SelfState]),
      Player2 = Player#player{room_id = RoomId,roomtype =RoomType,unit_id = Code2,user_id = Code1},
      Player2;
    %Room2;
    {error, ErrorCode} ->
      ?INFO(?_U("加入好友房间错误码:~p"), [ErrorCode]),
      Code1 = wg_util:rand(1000,10000000),
      Code2 = wg_util:rand(1000,10000000),
      Msg = #gc_friend_join_result
      {
        result = ErrorCode,
        usr_id = Code1,
        unit_id = Code2
      },

      MsgId = get_msg_id(gc_friend_join_result),
      ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg),

      Player2 = Player#player{unit_id = Code2,user_id = Code1},
      Player2;
    _->
      ?INFO(?_U("加入好友房间未知错误:~p"), [1]),
      Player
  end.

do_new_room_logic(Player)->
  #player{id = PlayerId,roomtype = RoomType,moneyRank = MoneyRankData,winRank = WinRankData,loseRank = LostRankData} = Player,
  ?IF(check_money_limit(RoomType,Player)=:=true,ok,?C2SERR(?Money_JoinRoom_Error)),
  case get_free_id(RoomType)of
    noFreeRoom ->
      %?INFO(?_U("没有空闲的房间")),
      Member = #room_member
      {
        id = PlayerId,
        state = ?PLAYER_STATE_NORMAL,
        moneyRank = MoneyRankData,
        winRank = WinRankData,
        loseRank = LostRankData
      },
      Player2 = do_create_new_room(Member,Player),

      check_player_prepare(),

      Player2;
    FreeId ->
      %?INFO(?_U("可以加入空闲的房间")),
      Member = #room_member
      {
        id = PlayerId,
        state = ?PLAYER_STATE_NORMAL,
        moneyRank = MoneyRankData,
        winRank = WinRankData,
        loseRank = LostRankData
      },
      Player2 = do_add_newroom_member(RoomType,FreeId,Member,Player),
      Player2
  end.
do_create_new_room(Member,#player{roomtype = RoomType}=Player)->
  case catch create_room(RoomType,Member) of
    #room{} = Room ->
      %?INFO(?_U("创建新房间成功:~p"), [Room]),
      Code1 = wg_util:rand(1000,10000000),
      Code2 = wg_util:rand(1000,10000000),
      #room{id = RoomId,member = NewMember,roomstate = RoomState} = Room,
      [FirstMember|_] = NewMember,
      #room_member{id = PlayerId, moneyRank = MoneyRankData,pos = Pos,state = State} = FirstMember,
      #money_rank_data{name = Name,image = Head,money = Money} = MoneyRankData,
      Msg = #gc_join_room
      {
        result = ?E_OK,
        room_id = RoomState,
        room_type = RoomType,
        usr_id = Code1,
        my_pos = Pos,
        cur_pos = 0,
        table_money = 0,
        name_list = [Name],
        head_list = [Head],
        pos_list = [Pos],
        state_list = [State],
        money_list = [Money],
        unit_id = Code2,
        cardnum = 108
      },
      MsgId = ?PROTO_CONVERT({?MODULE, gc_join_room}),
      ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg),
      Player2 = Player#player{room_id = RoomId,roomtype =RoomType, unit_id = Code2,user_id = Code1},
      Player2;
    _ ->
      Player
  end.


%%在新手房添加成员
do_add_newroom_member(RoomType,RoomId,Member,Player)->
  case catch add_member(RoomType,RoomId,Member) of
    {#room{} = Room2, #room_member{}=Member2} ->
      %?INFO(?_U("加入房间成功:~p"), [Member]),
      Code1 = wg_util:rand(1000,10000000),
      Code2 = wg_util:rand(1000,10000000),
      #room{id = RoomId,cardone = CardOne,cardtwo = CardTwo,pork_list = PorkerList,member = NewMember,roomstate = RoomState,table_money = TableMoney,turn = CurTurn} = Room2,
      #room_member{id = SelfId,pos = MyPos,moneyRank = MoneyRankData,state = SelfState} = Member2,
      #money_rank_data{name = SelfName,image = SelfHead,money = SelfMoney} = MoneyRankData,

      Val = lists:map
      (
        fun(TempMember) ->
          %?INFO(?_U("房间成员:~p"), [TempMember]),
          #room_member{id = SendId,moneyRank = MoneyRankData1,pos = Pos,state = State} = TempMember,
          #money_rank_data{name = Name,image = Head,money = Money} = MoneyRankData1,
          {Name, Head,Pos,State,Money,SendId}

        end,
        NewMember

      ),

      [K1,K2,K3,K4,K5,K6] = wg_lists:unzip_more(Val),

      Msg = #gc_join_room
      {
        result = ?E_OK,
        room_id = RoomState,
        room_type = RoomType,
        usr_id = Code1,
        my_pos = MyPos,
        table_money = TableMoney,
        cur_pos = CurTurn,
        cardone =CardOne,
        cardtwo = CardTwo,
        name_list = K1,
        head_list = K2,
        pos_list = K3,
        state_list = K4,
        money_list = K5,
        unit_id = Code2,
        cardnum = length(PorkerList)
      },
      AddMsg = #gc_add_member
      {
        usr_id = Code1,
        name   = SelfName,
        head   = SelfHead,
        pos    = MyPos,
        state  = SelfState,
        money  = SelfMoney,
        unit_id   = Code2
      }
      ,
      MsgId = get_msg_id(gc_join_room),
      MsgId2 = get_msg_id(gc_add_member),
      lists:map
      (
        fun(IdToSend) ->
          ?IF( IdToSend=:= SelfId, ok = ?S2C_SEND_MERGE:player(IdToSend, MsgId, Msg),
            ok = ?S2C_SEND_MERGE:player(IdToSend, MsgId2, AddMsg))

        end,
        K6

      ),
      %?INFO(?_U("加入d房间成员状态:~p"), [SelfState]),
      case SelfState =:= ?PLAYER_STATE_NORMAL of
        true ->
          check_player_prepare();
        _->
          ok
      end,

      ?IF(length(NewMember) =:= 1, check_game_start2(RoomId,RoomType),ok),
      Player2 = Player#player{room_id = RoomId,roomtype =RoomType,unit_id = Code2,user_id = Code1},
      Player2;
    %Room2;
    Error ->
      ?INFO(?_U("加入房间失败:~p"), [Error]),
      Player
  end.

do_add_reconnect_room_member(RoomType,RoomId,Member,Player)->
  case RoomType of
    ?Friend_Room_create ->
      do_add_friend_reconnect_room_member1(RoomType,RoomId,Member,Player);
    ?Friend_Room_join ->
      do_add_friend_reconnect_room_member1(RoomType,RoomId,Member,Player);
    _->
      do_add_reconnect_room_member1(RoomType,RoomId,Member,Player)
  end.

do_add_reconnect_room_member1(RoomType,RoomId,Member,Player)->
  case catch add_reconnect_member(RoomType,RoomId,Member) of
    {#room{} = Room2, #room_member{}=Member2} ->

      Code1 = wg_util:rand(1000,10000000),
      Code2 = wg_util:rand(1000,10000000),
      #room{id = RoomId,cardone = CardOne,cardtwo = CardTwo,pork_list = PorkerList,member = NewMember,roomstate = RoomState,table_money = TableMoney,turn = CurTurn} = Room2,
      #room_member{id = SelfId,pos = MyPos,moneyRank = MoneyRankData,state = SelfState} = Member2,
      #money_rank_data{name = SelfName,image = SelfHead,money = SelfMoney} = MoneyRankData,
      %?INFO(?_U("加入房间成功list:~p"), [NewMember]),
      Val = lists:map
      (
        fun(TempMember) ->
          %?INFO(?_U("房间成员:~p"), [TempMember]),
          #room_member{id = SendId,moneyRank = MoneyRankData1,pos = Pos,state = State} = TempMember,
          #money_rank_data{name = Name,image = Head,money = Money} = MoneyRankData1,
          {Name, Head,Pos,State,Money,SendId}

        end,
        NewMember

      ),

      [K1,K2,K3,K4,K5,K6] = wg_lists:unzip_more(Val),

      Msg = #gc_join_room
      {
        result = ?E_OK,
        room_id = RoomState,
        room_type = RoomType,
        usr_id = Code1,
        my_pos = MyPos,
        table_money = TableMoney,
        cur_pos = CurTurn,
        cardone =CardOne,
        cardtwo = CardTwo,
        name_list = K1,
        head_list = K2,
        pos_list = K3,
        state_list = K4,
        money_list = K5,
        unit_id = Code2,
        cardnum = length(PorkerList)
      },
      AddMsg = #gc_add_member
      {
        usr_id = Code1,
        name   = SelfName,
        head   = SelfHead,
        pos    = MyPos,
        state  = SelfState,
        money  = SelfMoney,
        unit_id   = Code2
      }
      ,
      MsgId = get_msg_id(gc_join_room),
      MsgId2 = get_msg_id(gc_add_member),
      lists:map
      (
        fun(IdToSend) ->
          ?IF( IdToSend=:= SelfId, ok = ?S2C_SEND_MERGE:player(IdToSend, MsgId, Msg),
            ok = ?S2C_SEND_MERGE:player(IdToSend, MsgId2, AddMsg))

        end,
        K6

      ),

      case SelfState =:= ?PLAYER_Ready of
        true ->
          ok;
        _->
          check_player_prepare()
      end,
      ?IF(length(NewMember) =:= 1, check_game_start2(RoomId,RoomType),ok),

      Player2 = Player#player{room_id = RoomId,roomtype =RoomType,unit_id = Code2,user_id = Code1},
      Player2;
    %Room2;
    Error ->
      ?INFO(?_U("加入房间失败:~p"), [Error]),
      Player
  end.

do_add_friend_reconnect_room_member1(RoomType,RoomId,Member,Player)->
  case catch add_reconnect_member(RoomType,RoomId,Member) of
    {#room{} = Room2, #room_member{}=Member2} ->

      Code1 = wg_util:rand(1000,10000000),
      Code2 = wg_util:rand(1000,10000000),
      #room{min_money = MinMoney,max_bet = MaxBet,isDouble = IsDouble,id = RoomId,cardone = CardOne,cardtwo = CardTwo,pork_list = PorkerList,member = NewMember,roomstate = RoomState,table_money = TableMoney,turn = CurTurn} = Room2,
      #room_member{id = SelfId,pos = MyPos,moneyRank = MoneyRankData,state = SelfState,score = SelfMoney} = Member2,
      #money_rank_data{name = SelfName,image = SelfHead} = MoneyRankData,
      %?INFO(?_U("加入房间成功list:~p"), [NewMember]),
      Val = lists:map
      (
        fun(TempMember) ->
          %?INFO(?_U("房间成员:~p"), [TempMember]),
          #room_member{id = SendId,moneyRank = MoneyRankData1,pos = Pos,state = State,score = Money} = TempMember,
          #money_rank_data{name = Name,image = Head} = MoneyRankData1,
          {Name, Head,Pos,State,Money,SendId}

        end,
        NewMember

      ),

      [K1,K2,K3,K4,K5,K6] = wg_lists:unzip_more(Val),

      Msg = #gc_join_room
      {
        result = ?E_OK,
        room_id = RoomState,
        room_type = RoomType,
        room_key = RoomId,
        usr_id = Code1,
        my_pos = MyPos,
        table_money = TableMoney,
        cur_pos = CurTurn,
        cardone =CardOne,
        cardtwo = CardTwo,
        min_money = MinMoney,
        max_bet = MaxBet,
        is_double = IsDouble,
        name_list = K1,
        head_list = K2,
        pos_list = K3,
        state_list = K4,
        money_list = K5,
        unit_id = Code2,
        cardnum = length(PorkerList)
      },
      AddMsg = #gc_add_member
      {
        usr_id = Code1,
        name   = SelfName,
        head   = SelfHead,
        pos    = MyPos,
        state  = SelfState,
        money  = SelfMoney,
        unit_id   = Code2
      }
      ,
      MsgId = get_msg_id(gc_join_room),
      MsgId2 = get_msg_id(gc_add_member),
      lists:map
      (
        fun(IdToSend) ->
          ?IF( IdToSend=:= SelfId, ok = ?S2C_SEND_MERGE:player(IdToSend, MsgId, Msg),
            ok = ?S2C_SEND_MERGE:player(IdToSend, MsgId2, AddMsg))

        end,
        K6

      ),

      case SelfState =:= ?PLAYER_Ready of
        true ->
          ok;
        _->
          check_player_prepare()
      end,
      ?IF(length(NewMember) =:= 1, check_game_start2(RoomId,RoomType),ok),

      Player2 = Player#player{room_id = RoomId,roomtype =RoomType,unit_id = Code2,user_id = Code1},
      Player2;
    %Room2;
    Error ->
      ?INFO(?_U("加入房间失败:~p"), [Error]),
      Player
  end.

do_money_bet(#player{room_id = RoomId,roomtype = RoomType,money = MyMoney} = Player,BetMoney,MsgBet)->
  case RoomType of
    ?Friend_Room_create ->
      do_friend_room_money_bet(Player,BetMoney,MsgBet);
    ?Friend_Room_join ->
      do_friend_room_money_bet(Player,BetMoney,MsgBet);
    _ ->
      do_money_bet1(Player,BetMoney,MsgBet)
  end.
%玩家下注
do_money_bet1(#player{room_id = RoomId,roomtype = RoomType,money = MyMoney} = Player,BetMoney,MsgBet)->

  case catch get_room(RoomType,RoomId) of
    #room{table_money = TableMoney,pork_list = PokerList,cardone = CardOne,cardtwo = CardTwo}= Room ->

      [ResCard|NewPokerList] = PokerList,
      %?INFO(?_U("下注的金币:~p,"), [BetMoney]),
      %?INFO(?_U(",桌底有~p"), [TableMoney]),
      %?INFO(?_U("自己有~p"), [MyMoney]),
      case BetMoney =< TableMoney andalso  BetMoney =< MyMoney of
        true ->
          GameRes = do_game_result(CardOne,CardTwo,ResCard),
          case GameRes of
            ?Game_Lose->

              Player2 = do_game_losed(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet),
              Player2;
            ?Game_Lose_Double->

              Player2 = do_game_double_losed(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet),
              Player2;
            ?Game_Win->
              Player2 = do_game_win(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet),
              Player2;
            _->
              ?INFO(?_U("玩家输赢返回结果失败:~p"), [1]),
              Player2 = Player
          end,
          Player2;
        false ->
          ?INFO(?_U("下注错误的金币:~p,"), [BetMoney]),
          ?INFO(?_U(",桌底有~p"), [TableMoney]),
          ?INFO(?_U("自己有~p"), [MyMoney]),
          do_quit_room(Player,?QUIT_BY_SELF),
          Player2 = Player,
          Player2
      end,
      %?INFO(?_U("玩一把之后的玩家:~p"), [Player2]),

      Player2;
    _->
      ?INFO(?_U("下注没有找到房间:~p,"), [1]),
      Player
  end.


do_friend_room_money_bet(#player{room_id = RoomId,roomtype = RoomType,money = MyMoney} = Player,BetMoney,MsgBet)->

  case catch get_room(RoomType,RoomId) of
    #room{table_money = TableMoney,pork_list = PokerList,cardone = CardOne,cardtwo = CardTwo,max_bet = MaxBet,isDouble = IsDouble}= Room ->

      [ResCard|NewPokerList] = PokerList,
      %?INFO(?_U("下注的金币:~p,"), [BetMoney]),
      %?INFO(?_U(",桌底有~p"), [TableMoney]),
      %?INFO(?_U("自己有~p"), [MyMoney]),
      case BetMoney =< TableMoney andalso BetMoney =< MaxBet of
        true ->
          GameRes = do_game_result(CardOne,CardTwo,ResCard),
          case GameRes of
            ?Game_Lose->

              Player2 = do_friend_game_losed(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet),
              Player2;
            ?Game_Lose_Double->
              ?INFO(?_U("是否加倍:~p"), [IsDouble]),
              case IsDouble of
                true->
                  Player2 = do_friend_game_double_losed(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet);
                false->
                  Player2 = do_friend_game_losed(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet)
              end,
              Player2;
            ?Game_Win->
              Player2 = do_friend_game_win(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet),
              Player2;
            _->
              ?INFO(?_U("玩家输赢返回结果失败:~p"), [1]),
              Player2 = Player
          end,
          Player2;
        false ->
          ?INFO(?_U("下注错误的金币:~p,"), [BetMoney]),
          ?INFO(?_U(",桌底有~p"), [TableMoney]),
          ?INFO(?_U("自己有~p"), [MyMoney]),
          do_quit_room(Player,?QUIT_BY_SELF),
          Player2 = Player,
          Player2
      end,
      %?INFO(?_U("玩一把之后的玩家:~p"), [Player2]),

      Player2;
    _->
      ?INFO(?_U("下注没有找到房间:~p,"), [1]),
      Player
  end.



%%修改玩家成员信息
do_change_member(PlayerId,RoomId,RoomType,ChangeMember) ->

  case catch get_room(RoomType,RoomId) of
    #room{member = MemberList}= _R ->
      Func =
        fun(#room_member{id = Id}= Member)->

          case Id =:= PlayerId of
            true ->
              ResMember = ChangeMember;
            false ->
              ResMember = Member
          end,

          ResMember
        end,
      NewMemberList = lists:map(Func, MemberList),
      %?INFO(?_U("新的玩家列表:~p"), [NewMemberList]),
      NewMemberList;
    _->
      ?INFO(?_U("修改玩家成员信息,房间没有找到:~p,"), [1]),
      []
  end.




%%修改新手房成员信息
%%change_newroom_player_state(RoomType,PlayerId,RoomId,PlayerState,ChangIndex)->
%%  case catch set_member_status(RoomType,PlayerId,RoomId,ChangIndex,PlayerState) of
%%    NewMemberList when is_list(NewMemberList)->
%%      NewMemberList;
%%    Error ->
%%      ?INFO(?_U("修改玩家房间成员属性失败:~p"), [1])
%%  end.
friend_room_is_can_start(Player)->
  #player{roomtype = RoomType,room_id = RoomId,id = PlayerId} = Player,
  case catch get_room(RoomType,RoomId) of
    #room{member = PlayerList,game_start_time = StartTime}=_Room ->
      case StartTime =:= -1 of
        true->
          TempList = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId /= PlayerId],
          case length(TempList) > 0 of
            true->
              lists:all
              (
                fun(#room_member{state = State }=MyMember) ->
                  ?IF(State =:= ?PLAYER_Ready, true, false)
                end,
                TempList
              );
            _->
              ?No_Enough_Player
          end;

        false->
          true
      end;
    _->
      room_no_find
  end.



%% 修改新手房成员状态
change_ready_player_state(RoomType,PlayerId,RoomId,PlayerState,ChangIndex)->
  case catch set_member_status(RoomType,PlayerId,RoomId,ChangIndex,PlayerState) of
       NewMemberList when is_list(NewMemberList)->
         ?INFO(?_U("修改玩家准备成功:~p"), [1]),
         check_game_start(RoomId,PlayerId,NewMemberList,RoomType);
        Error ->
          ?INFO(?_U("修改玩家准备状态失败:~p"), [Error])
  end.
%
check_game_start(RoomId,PlayerId,NewMemberList,RoomType)->

  IsFullReady = is_all_ready(RoomType,RoomId),


  case IsFullReady of
    true ->
      game_change_room_info(RoomId,RoomType);
    false ->
      case is_friend_over(RoomType,RoomId) of
        true->
          ?INFO(?_U("send over----:~p"), [1]),
          game_over(RoomType,RoomId);
        false->
          ?INFO(?_U("房间不能开始游戏，有玩家还没有准备:~p"), [1]),
          [#room_member{pos = MyPos}=MyMember] = [X|| #room_member{id = MemberId} = X <-NewMemberList,MemberId =:= PlayerId],

          Code1 = wg_util:rand(1000,10000000),
          Code2 = wg_util:rand(1000,10000000),
          Msg = #gc_add_money
          {

            usr_id  = Code1,
            pos     =MyPos,
            unit_id = Code2
          },
          MsgId = ?PROTO_CONVERT({?MODULE, gc_add_money}),
          send_msg_broadcast(NewMemberList,MsgId, Msg)
      end
  end.

check_game_start2(RoomId,RoomType)->

  IsFullReady = is_all_ready(RoomType,RoomId),

  %?INFO(?_U("玩家都准备了嘛:~p"), [IsFullReady]),
  case IsFullReady of
    true ->
      game_change_room_info(RoomId,RoomType);
    false ->
      ok
  end.

check_money_limit(RoomType,Player)->
  #player{money = Money} = Player,
  case RoomType of
    ?New_Room ->
      Res = Money >= ?NewRoom_MinMoney andalso Money =< ?Max_NewRoom;
    ?Ordinary_Room ->
      Res = Money >= ?OrdinaryRoom_MinMoney andalso Money =< ?Max_OrdinaryRoom;
    ?Master_Room ->
      Res = Money >= ?MasterRoom_MinMoney;
    ?Friend_Room_create ->
      Res = Money >= 4000;
    ?Friend_Room_join ->
      Res = Money >= 4000;
    _ ->
      Res = false
  end,
  Res.

do_get_video(PlayerId,Type,SelfId)->
  case Type of
    ?Video_Win_Money->
      ?INFO(?_U("单次赢最多纪录:~p"), [PlayerId]),

      case player_mgr:get_by_id(PlayerId) of
        #player{} = _Player ->
            Req = {?Win_Video,SelfId},
            ok = player_server:s2s_cast(PlayerId, ?MODULE, Req);
        _->
          case catch db_rank_win_money:load(PlayerId) of
            #win_rank_data{} = WinData ->
              #win_rank_data{poker_num = CardNum,money = VideoMoney,table_money = TableMoney,cardone = CardOne,cardtwo = CardTwo,mypos = MyPos,name_list = NameList,image_list = ImageList,money_list = MoneyList,pos_list = PosList} = WinData,
              ?DEBUG(?_U("数据库中查找要发送id:~w"), [SelfId]),
              ?INFO(?_U("单次赢最多纪录发送:~p"), [WinData]),
              Msg = #gc_rank_win_money_video
              {
                usr_id  = 1,
                my_pos = MyPos,
                table_money = TableMoney,
                video_money = VideoMoney,
                cardone = CardOne,
                cardtwo = CardTwo,
                name_list = NameList,
                head_list = ImageList,
                pos_list = PosList,
                money_list = MoneyList,
                cardnum = CardNum,
                unit_id = 2
              },
              MsgId = ?PROTO_CONVERT({?MODULE, gc_rank_win_money_video}),

              ok = ?S2C_SEND_MERGE:player(SelfId, MsgId, Msg);
            _->
              ok
          end
      end;

    ?Video_lose_Money->
      case player_mgr:get_by_id(PlayerId) of
        #player{} = _Player ->
          Req = {?Lose_Video,SelfId},
          ok = player_server:s2s_cast(PlayerId, ?MODULE, Req);
        _->
          case catch db_rank_lose_money:load(PlayerId) of
            #lose_rank_data{} = LoseData ->
              #lose_rank_data{poker_num = CardNum,money = VideoMoney,table_money = TableMoney,cardone = CardOne,cardtwo = CardTwo,mypos = MyPos,name_list = NameList,image_list = ImageList,money_list = MoneyList,pos_list = PosList} = LoseData,
              ?DEBUG(?_U("数据库中查找要发送id:~w"), [SelfId]),
              ?INFO(?_U("单次输最多纪录发送:~p"), [LoseData]),
              Msg = #gc_rank_win_money_video
              {
                usr_id  = 1,
                my_pos = MyPos,
                table_money = TableMoney,
                video_money = VideoMoney,
                cardone = CardOne,
                cardtwo = CardTwo,
                name_list = NameList,
                head_list = ImageList,
                pos_list = PosList,
                money_list = MoneyList,
                cardnum = CardNum,
                unit_id = 2
              },
              MsgId = ?PROTO_CONVERT({?MODULE, gc_rank_win_money_video}),

              ok = ?S2C_SEND_MERGE:player(SelfId, MsgId, Msg);
            _->
              ok
          end
      end
  end.
%玩家获取排行榜
do_get_rank(PlayerId,Type)->
  {NewMoneyRankList,NewWinRankList,NewLose_rank_List} = rank:get_all_rank(),
  case Type of
    ?Money_Rank->
      ?IF(length(NewMoneyRankList)>0,do_get_money_rank(PlayerId,Type,NewMoneyRankList),do_send_null_rank(PlayerId,Type));

    ?Win_Rank->
      %?INFO(?_U("一次赢房间成员:~p"), [NewWinRankList]),
      ?IF(length(NewWinRankList)>0,do_get_win_rank(PlayerId,Type,NewWinRankList),do_send_null_rank(PlayerId,Type));
    ?Lose_Rank->
      %?INFO(?_U("一次输房间成员:~p"), [NewLose_rank_List]),
      ?IF(length(NewLose_rank_List)>0,do_get_lose_rank(PlayerId,Type,NewLose_rank_List),do_send_null_rank(PlayerId,Type))
  end
.
do_send_null_rank(PlayerId,Type)->
  Msg = #gc_get_rank
  {
    usr_id                      = 6780,
    type                        = Type,
    name_list                   = [],
    head_list                   = [],
    money_list                  = [],
    id_list                     = [],
    unit_id                     = 987
  },
  MsgId = ?PROTO_CONVERT({?MODULE, gc_get_rank}),

  ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg).


do_get_money_rank(PlayerId,Type,NewMoneyRankList)->
  Val = lists:map
  (
    fun(TempMember) ->
      %?INFO(?_U("房间成员:~p"), [TempMember]),
      #money_rank_data{id = Id,money = Money,name = Name,image = Image} = TempMember,

      {Id, Money,Name,Image}

    end,
    NewMoneyRankList

  ),

  [K1,K2,K3,K4] = wg_lists:unzip_more(Val),

  Msg = #gc_get_rank
  {
    usr_id                      = 6780,
    type                        = Type,
    name_list                   = K3,
    head_list                   = K4,
    money_list                  = K2,
    id_list                     = K1,
    unit_id                     = 987
  },
  MsgId = ?PROTO_CONVERT({?MODULE, gc_get_rank}),

  ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg).

do_get_win_rank(PlayerId,Type,NewWinRankList)->
  %?INFO(?_U("一次赢房间成员:~p"), [NewWinRankList]),
  Val = lists:map
  (
    fun(TempMember) ->
      %?INFO(?_U("房间成员:~p"), [TempMember]),
      #win_rank_data{id = Id,money = Money,mypos = MyPos,name_list  = NameList,image_list = ImageList,pos_list = PosList} = TempMember,
      N = length([X|| X <-PosList,X < MyPos]) + 1,
      Name = lists:nth(N,NameList),
      Image = lists:nth(N,ImageList),
      {Id, Money,Name,Image}

    end,
    NewWinRankList

  ),

  [K1,K2,K3,K4] = wg_lists:unzip_more(Val),

  Msg = #gc_get_rank
  {
    usr_id                      = 6780,
    type                        = Type,
    name_list                   = K3,
    head_list                   = K4,
    money_list                  = K2,
    id_list                     = K1,
    unit_id                     = 0987
  },
  MsgId = ?PROTO_CONVERT({?MODULE, gc_get_rank}),

  ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg).

do_get_lose_rank(PlayerId,Type,NewLose_rank_List)->
  Val = lists:map
  (
    fun(TempMember) ->
      %?INFO(?_U("房间成员:~p"), [TempMember]),
      #lose_rank_data{id = Id,money = Money,mypos = MyPos,name_list  = NameList,image_list = ImageList,pos_list = PosList} = TempMember,
      N = length([X|| X <-PosList,X < MyPos]) + 1,
      Name = lists:nth(N,NameList),
      Image = lists:nth(N,ImageList),
      {Id, Money,Name,Image}

    end,
    NewLose_rank_List

  ),

  [K1,K2,K3,K4] = wg_lists:unzip_more(Val),

  Msg = #gc_get_rank
  {
    usr_id                      = 6780,
    type                        = Type,
    name_list                   = K3,
    head_list                   = K4,
    money_list                  = K2,
    id_list                     = K1,
    unit_id                     = 0987
  },
  MsgId = ?PROTO_CONVERT({?MODULE, gc_get_rank}),

  ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg).



do_game_win(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet)->
  #player{id = PlayerId,room_id = RoomId,roomtype = RoomType,money = MyMoney,moneyRank = MoneyRank,loseRank = LoseRank,winRank = WinRank} = Player,
  #room{table_money = TableMoney,gameNum = GameNum,member = PlayerList} = Room,
  [#room_member{pos = MyPos}=MyMember] = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId =:= PlayerId],

  HandredNum = BetMoney rem 1000,
  CutNum = (BetMoney-HandredNum)*?CONF(discount,0.1),
  TempMoney = round(BetMoney - CutNum),
  %?IF(RoomType =:= ?Friend_Room, NewMoney = MyMoney + BetMoney,NewMoney = MyMoney + TempMoney),
  NewMoney = MyMoney + TempMoney,
  %?INFO(?_U("玩家赢了扣除:~p"), [CutNum]),

  TableLeftMoney = TableMoney - BetMoney,

  MoneyRank1 = MoneyRank#money_rank_data{money = NewMoney},
  #win_rank_data{money = WinMoney} = WinRank,


  NewRank = rank:get_money_rank(MoneyRank1),
  NewLoseRank = rank:get_lose_rank(LoseRank),

  case WinMoney < BetMoney of
    true ->

      WinRank1 = update_win_rank(PlayerId,BetMoney,MyPos,Room,ResCard,RoomType,MsgBet),
      NewWinRank = rank:get_win_rank(WinRank1);

    false ->
      WinRank1 = WinRank,
      NewWinRank = rank:get_win_rank(WinRank1)
  end,

  NewMember1 = MyMember#room_member{moneyRank = MoneyRank1,winRank = WinRank1},

  NewMemberList = do_change_member(PlayerId,RoomId,RoomType,NewMember1),
  ?IF(TableLeftMoney =:= 0, GameNum1 = GameNum + 1,GameNum1 = GameNum),
  Room2 = Room#room{table_money = TableLeftMoney,gameNum = GameNum1,pork_list = NewPokerList,member = NewMemberList},
  set_room(Room2,RoomType),

  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),

  do_send_game_result(PlayerList,Code1,MyPos,ResCard,GameRes,NewRank,NewWinRank,NewLoseRank,NewMoney,BetMoney,TableLeftMoney,Code2,MsgBet),

  send_delay_msg(TableLeftMoney),
  Player2 = Player#player{user_id = Code1,unit_id = Code2,money = NewMoney,moneyRank = MoneyRank1,winRank = WinRank1},
  %?INFO(?_U("赢了的玩家:~p"), [Player2]),
  Player2.

do_friend_game_win(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet)->
  #player{id = PlayerId,room_id = RoomId,roomtype = RoomType} = Player,
  #room{table_money = TableMoney,member = PlayerList} = Room,
  [#room_member{pos = MyPos,score = MyMoney}=MyMember] = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId =:= PlayerId],

  NewMoney = MyMoney + BetMoney,
  TableLeftMoney = TableMoney - BetMoney,

  ?INFO(?_U("赢了的玩家:~p"), [NewMoney]),
  NewMember1 = MyMember#room_member{score = NewMoney},

  NewMemberList = do_change_member(PlayerId,RoomId,RoomType,NewMember1),

  Room2 = Room#room{table_money = TableLeftMoney,pork_list = NewPokerList,member = NewMemberList},
  set_room(Room2,RoomType),

  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),

  do_send_friend_game_result(PlayerList,Code1,MyPos,ResCard,GameRes,NewMoney,BetMoney,TableLeftMoney,Code2,MsgBet),

  send_delay_msg(TableLeftMoney),
  Player2 = Player#player{user_id = Code1,unit_id = Code2},
  %?INFO(?_U("赢了的玩家:~p"), [Player2]),
  Player2.




do_game_double_losed(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet)->
  #player{id = PlayerId,room_id = RoomId,roomtype = RoomType,money = MyMoney,moneyRank = MoneyRank,loseRank = LoseRank,winRank = WinRank} = Player,
  #room{table_money = TableMoney,member = PlayerList} = Room,
  [#room_member{pos = MyPos}=MyMember] = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId =:= PlayerId],

  TempMoney = MyMoney - BetMoney*2,
  ?IF(TempMoney >= 0,NewMoney = TempMoney,NewMoney = 0),
  ?IF(TempMoney >= 0,AddMoney = BetMoney*2,AddMoney = MyMoney),

  %?INFO(?_U("玩家输了double:~p"), [AddMoney]),
  TableLeftMoney = TableMoney+AddMoney,

  MoneyRank1 = MoneyRank#money_rank_data{money = NewMoney},

  #lose_rank_data{money = MaxLoseMoney} = LoseRank,
  ?IF(AddMoney > MaxLoseMoney,LoseRank1=update_lose_rank(PlayerId,AddMoney,MyPos,Room,ResCard,RoomType,MsgBet,2),LoseRank1 = LoseRank ),


  NewRank = rank:get_money_rank(MoneyRank1),
  NewWinRank = rank:get_win_rank(WinRank),
  NewLoseRank = rank:get_lose_rank(LoseRank1),

  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),

  Player2 = Player#player{user_id = Code1,unit_id = Code2,money = NewMoney,moneyRank = MoneyRank1,loseRank = LoseRank1},

  %%检查赠送

  Player3 = mod_attr:check_give_coins(Player2),
  #player{money = AfterGiveMoney,moneyRank = MoneyRank3} = Player3,
  ?IF(AfterGiveMoney =:= 0,NewMember = MyMember#room_member{state = ?PLAYER_OBSERVER},NewMember = MyMember ),
  NewMember1 = NewMember#room_member{moneyRank = MoneyRank3,loseRank = LoseRank1},
  NewMemberList = do_change_member(PlayerId,RoomId,RoomType,NewMember1),
  Room2 = Room#room{table_money = TableLeftMoney,pork_list = NewPokerList,member = NewMemberList},
  set_room(Room2,RoomType),

  do_send_game_result(PlayerList,Code1,MyPos,ResCard,GameRes,NewRank,NewWinRank,NewLoseRank,AfterGiveMoney,BetMoney,TableLeftMoney,Code2,MsgBet),
  send_delay_msg(TableLeftMoney),

  Player3.

do_friend_game_double_losed(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet)->
  #player{id = PlayerId,room_id = RoomId,roomtype = RoomType} = Player,
  #room{table_money = TableMoney,member = PlayerList} = Room,
  [#room_member{pos = MyPos,score = MyMoney}=MyMember] = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId =:= PlayerId],

  TempMoney = MyMoney - BetMoney*2,
  AddMoney = BetMoney*2,

  TableLeftMoney = TableMoney+AddMoney,


  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),

  Player2 = Player#player{user_id = Code1,unit_id = Code2},

  %%检查赠送

  NewMember1 = MyMember#room_member{score = TempMoney},
  NewMemberList = do_change_member(PlayerId,RoomId,RoomType,NewMember1),
  Room2 = Room#room{table_money = TableLeftMoney,pork_list = NewPokerList,member = NewMemberList},
  set_room(Room2,RoomType),

  do_send_friend_game_result(PlayerList,Code1,MyPos,ResCard,GameRes,TempMoney,BetMoney,TableLeftMoney,Code2,MsgBet),
  send_delay_msg(TableLeftMoney),

  Player2.




do_game_losed(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet)->
  #player{id = PlayerId,room_id = RoomId,roomtype = RoomType,money = MyMoney,moneyRank = MoneyRank,loseRank = LoseRank,winRank = WinRank} = Player,
  #room{table_money = TableMoney,member = PlayerList} = Room,

  [#room_member{pos = MyPos}=MyMember] = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId =:= PlayerId],

  NewMoney = MyMoney - BetMoney,


  %?INFO(?_U("玩家输了:~p"), [NewMoney]),
  TableLeftMoney = TableMoney+BetMoney,

  MoneyRank1 = MoneyRank#money_rank_data{money = NewMoney},

  #lose_rank_data{money = MaxLoseMoney} = LoseRank,
  ?IF(BetMoney > MaxLoseMoney,LoseRank1=update_lose_rank(PlayerId,BetMoney,MyPos,Room,ResCard,RoomType,MsgBet,1),LoseRank1 = LoseRank ),

  NewRank = rank:get_money_rank(MoneyRank1),
  NewWinRank = rank:get_win_rank(WinRank),
  NewLoseRank = rank:get_lose_rank(LoseRank1),

  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),

  Player2 = Player#player{user_id = Code1,unit_id = Code2,money = NewMoney,moneyRank = MoneyRank1,loseRank = LoseRank1},
  %?INFO(?_U("输了之后的玩家:~p"), [Player2]),
  Player3 = mod_attr:check_give_coins(Player2),
  #player{money = AfterGiveMoney,moneyRank = MoneyRank3} = Player3,

  ?IF(AfterGiveMoney =:= 0,NewMember = MyMember#room_member{state = ?PLAYER_OBSERVER},NewMember = MyMember ),
  NewMember1 = NewMember#room_member{moneyRank = MoneyRank3,loseRank = LoseRank1},
  NewMemberList = do_change_member(PlayerId,RoomId,RoomType,NewMember1),
  Room2 = Room#room{table_money = TableLeftMoney,pork_list = NewPokerList,member = NewMemberList},
  set_room(Room2,RoomType),

  do_send_game_result(PlayerList,Code1,MyPos,ResCard,GameRes,NewRank,NewWinRank,NewLoseRank,AfterGiveMoney,BetMoney,TableLeftMoney,Code2,MsgBet),
  send_delay_msg(TableLeftMoney),

  Player3.

do_friend_game_losed(Player,Room,BetMoney,ResCard,GameRes,NewPokerList,MsgBet)->
  #player{id = PlayerId,room_id = RoomId,roomtype = RoomType} = Player,
  #room{table_money = TableMoney,member = PlayerList} = Room,
  [#room_member{pos = MyPos,score = MyMoney}=MyMember] = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId =:= PlayerId],

  TempMoney = MyMoney - BetMoney,
  AddMoney = BetMoney,

  TableLeftMoney = TableMoney+AddMoney,

  ?INFO(?_U("输了的玩家:~p"), [TempMoney]),
  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),

  Player2 = Player#player{user_id = Code1,unit_id = Code2},

  %%检查赠送

  NewMember1 = MyMember#room_member{score = TempMoney},
  NewMemberList = do_change_member(PlayerId,RoomId,RoomType,NewMember1),
  Room2 = Room#room{table_money = TableLeftMoney,pork_list = NewPokerList,member = NewMemberList},
  set_room(Room2,RoomType),

  do_send_friend_game_result(PlayerList,Code1,MyPos,ResCard,GameRes,TempMoney,BetMoney,TableLeftMoney,Code2,MsgBet),
  send_delay_msg(TableLeftMoney),

  Player2.




update_lose_rank(Id,NewMoney,MyPos,Room,ResCard,RoomType,MsgBet,GameRes)->
  #cg_bet_money{one_chip_num = One,two_chip_num = Two,three_chip_num = Three,four_chip_num = Four,five_chip_num = Five}= MsgBet,
  #room{table_money = TableMoney,member = PlayerList,cardone = CardOne,cardtwo = CardTwo,pork_list = PorkerList} = Room,
  Val = lists:map
  (
    fun(TempMember) ->
      %?INFO(?_U("房间成员:~p"), [TempMember]),
      #room_member{moneyRank = MoneyRankData1,pos = Pos} = TempMember,
      #money_rank_data{name = Name,image = Head,money = Money} = MoneyRankData1,
      {Name, Head,Pos,Money}

    end,
    PlayerList
  ),

  [K1,K2,K3,K4] = wg_lists:unzip_more(Val),


  BetNum = One+Two*10+Three*100+Four*1000+Five*10000,
  Res = #lose_rank_data{
    id = Id,
    cardone = CardOne + 1000*RoomType+BetNum*10000,
    cardtwo = CardTwo + 1000*ResCard + GameRes*100000000,
    mypos = MyPos,
    name_list = K1,
    image_list = K2,
    money_list = K4,
    pos_list = K3,
    table_money = TableMoney,
    poker_num = length(PorkerList),
    money = NewMoney
  },
  %?INFO(?_U("玩家输了,刷新了修改排行榜:~p"), [Res]),
  Res.


%%修改房间属性
game_change_room_info(RoomId,RoomType)->

  case is_friend_over(RoomType,RoomId) of
    true->
      ?INFO(?_U("send over----:~p"), [1]),
      game_over(RoomType,RoomId);
    false->
      %?INFO(?_U("check----:~p"), [1]),
      case catch get_room(RoomType,RoomId) of
        #room{roomstate = RoomState}=Room ->
          ?IF(RoomState =:= ?ROOM_WAIT_READY,do_game_start(RoomId,Room,RoomType),do_game_next_game(Room,RoomType));
        _->
          ?INFO(?_U("进行下一轮时,房间没有找到:~p,"), [1]),
          ok
      end
  end.


do_game_start(RoomId,Room,RoomType)->
  case RoomType of
    ?Friend_Room_create ->
      do_friend_game_start(RoomId,Room,RoomType);
    ?Friend_Room_join ->
      do_friend_game_start(RoomId,Room,RoomType);
    _ ->
      do_game_start1(RoomId,Room,RoomType)
  end.
do_game_start1(RoomId,Room,RoomType)->
  #room{id = Id,gameNum = GameNum,turn = OldTurn,member = MemberList,min_money = MinMoney,pork_list = PorkList,table_money = OldTabelMoney} = Room,
  case Id =:= RoomId of
    true ->
      PersonNum = length(MemberList),
      PokerCardNum = length(PorkList),
      NewTurnList = [X||#room_member{state = State} = X <-MemberList,State =:= ?PLAYER_Ready],
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

          Room2 = Room#room{gameNum = GameNum+1,keepnum = 0,turn = TurnPos,roomstate = ?ROOM_START,table_money = OldTabelMoney+MinMoney*PersonNum,cardone = CardOne,cardtwo = CardTwo,pork_list = NewPorkList},
          min_base_money_rank(Room2,RoomType),
          Req = {?START_GAME, TurnPos, MinMoney,CardOne,CardTwo,GameNum+1,length(NewPorkList),OldTabelMoney+MinMoney*PersonNum,PokerCardNum  < ?POKER_NUM_MAX,0},

          lists:map
          (
            fun(#room_member{id = SendId}=MyMember) ->
              %?INFO(?_U("发送玩家准备的id:~p"), [SendId]),

              ok = player_server:s2s_cast(SendId, ?MODULE, Req)

            end,
            MemberList

          ),
          %?INFO(?_U("开始游戏修改房间信息:~p"), [Room2]),

          Room2;
        _ ->
          %?INFO(?_U("房间没有玩家:~p"), [1])
          ok
      end;
    false ->
      %?INFO(?_U("开始游戏失败,id不相等:~p"), [1]),
      Room
  end.

do_friend_game_start(RoomId,Room,RoomType)->
  #room{id = Id,gameNum = GameNum,turn = OldTurn,member = MemberList,min_money = MinMoney,pork_list = PorkList,table_money = OldTabelMoney,game_start_time = GameStartTime} = Room,
  case Id =:= RoomId of
    true ->
      PersonNum = length(MemberList),
      PokerCardNum = length(PorkList),
      NewTurnList = [X||#room_member{state = State} = X <-MemberList,State =:= ?PLAYER_Ready],
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

          Room2 = Room#room{game_start_time = NewStartTime,gameNum = GameNum,turn = TurnPos,roomstate = ?ROOM_START,table_money = OldTabelMoney+MinMoney*PersonNum,cardone = CardOne,cardtwo = CardTwo,pork_list = NewPorkList},
          min_base_chip(Room2,RoomType),
          LeftTime = wg_util:now_sec() - NewStartTime,
          Req = {?START_GAME, TurnPos, MinMoney,CardOne,CardTwo,GameNum,length(NewPorkList),OldTabelMoney+MinMoney*PersonNum,PokerCardNum  < ?POKER_NUM_MAX,LeftTime},

          lists:map
          (
            fun(#room_member{id = SendId}=MyMember) ->
              %?INFO(?_U("发送玩家准备的id:~p"), [SendId]),

              ok = player_server:s2s_cast(SendId, ?MODULE, Req)

            end,
            MemberList

          ),
          %?INFO(?_U("开始游戏修改房间信息:~p"), [Room2]),

          Room2;
        _ ->
          %?INFO(?_U("房间没有玩家:~p"), [1])
          ok
      end;
    false ->
      %?INFO(?_U("开始游戏失败,id不相等:~p"), [1]),
      Room
  end.
do_game_next_game(Room,RoomType)->
  #room{table_money = TableMoney,gameNum = GameNum,turn = OldTurn,member = MemberList,pork_list = PorkList,game_start_time = GameStartTime} = Room,

  PokerCardNum = length(PorkList),
  NewTurnList = [X||#room_member{state = State} = X <-MemberList,State =:= ?PLAYER_Ready],
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
      Room2 = Room#room{turn = TurnPos,cardone = CardOne,cardtwo = CardTwo,pork_list = NewPorkList},

      set_room(Room2,RoomType),
      %?INFO(?_U("max的pos:~p"), [MaxPos]),
      %?INFO(?_U("old的pos:~p"), [OldTurn]),
      %?INFO(?_U("下一个人的pos:~p"), [TurnPos]),
      ?IF(GameStartTime =:= -1, NewStartTime =0 ,NewStartTime = wg_util:now_sec() - GameStartTime),
      Req = {?START_GAME, TurnPos, 0,CardOne,CardTwo,GameNum,length(NewPorkList),TableMoney,PokerCardNum  < ?POKER_NUM_MAX,NewStartTime},

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


update_win_rank(Id,NewMoney,MyPos,Room,CardRes,RoomType,MsgBet)->

  #cg_bet_money{one_chip_num = One,two_chip_num = Two,three_chip_num = Three,four_chip_num = Four,five_chip_num = Five}= MsgBet,
  #room{table_money = TableMoney,member = PlayerList,cardone = CardOne,cardtwo = CardTwo,pork_list = PorkerList} = Room,
  Val = lists:map
  (
    fun(TempMember) ->
      %?INFO(?_U("房间成员:~p"), [TempMember]),
      #room_member{moneyRank = MoneyRankData1,pos = Pos} = TempMember,
      #money_rank_data{name = Name,image = Head,money = Money} = MoneyRankData1,
      {Name, Head,Pos,Money}

    end,
    PlayerList
  ),

  [K1,K2,K3,K4] = wg_lists:unzip_more(Val),


  BetNum = One+Two*10+Three*100+Four*1000+Five*10000,
  Res = #win_rank_data{
    id = Id,
    cardone = CardOne + 1000*RoomType + BetNum*10000,
    cardtwo = CardTwo + 1000*CardRes + 3*100000000,
    mypos = MyPos,
    name_list = K1,
    image_list = K2,
    money_list = K4,
    pos_list = K3,
    table_money = TableMoney,
    poker_num = length(PorkerList),
    money = NewMoney
  },
  %?INFO(?_U("玩家赢了,刷新了修改排行榜:~p"), [Res]),
  Res.
%下底
min_base_money_rank(Room,RoomType)->
  #room{member = Member,min_money = MinMoney} = Room,
  Val = lists:map
  (
    fun(TempMember) ->
      #room_member{moneyRank = OldMoneyRank} = TempMember,
      #money_rank_data{money = OldMoney} = OldMoneyRank,
      NewMoneyRank = OldMoneyRank#money_rank_data{money = OldMoney - MinMoney},
      Member2 = TempMember#room_member{moneyRank = NewMoneyRank},
      %?INFO(?_U("所有人变为准备:~p"), [Member2]),
      Member2
    end,
    Member
  ),
  Room2 = Room#room{member = Val},
  %?INFO(?_U("新的房间成员列表:~p"), [Val]),
  set_room(Room2,RoomType),
  Room2.


min_base_chip(Room,RoomType)->
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
  set_room(Room2,RoomType),
  Room2.

reset_room_ready(Room,RoomType)->
  #room{member = Member} = Room,
  Val = lists:map
  (
    fun(TempMember) ->
      Member2 = TempMember#room_member{state = ?PLAYER_STATE_NORMAL},
      %?INFO(?_U("所有人变为准备:~p"), [Member2]),
      Member2
    end,
    Member
  ),
  Room2 = Room#room{roomstate = ?ROOM_WAIT_READY,member = Val},
  %?INFO(?_U("新的房间成员列表:~p"), [Val]),
  set_room(Room2,RoomType),
  Room2.

send_delay_msg(TableLeftMoney) ->
  case TableLeftMoney of
    0->
      Fun = fun(Player) ->
        #player{roomtype =  RoomType,room_id = RoomId} = Player,

        case catch get_room(RoomType,RoomId) of
          #room{}= Room ->
            Room2 = reset_room_ready(Room,RoomType),
            #room{member = MemberList} = Room2,
            do_send_reset_msg(MemberList),
            Player;
          _->
            ?INFO(?_U("发送重新准备时,房间没有找到:~p,"), [1]),
            Player
        end
            end,

      start_delay_result_timer(?PlayerBetDelay,Fun);
    _ ->

      Fun = fun(Player) ->
        #player{roomtype =  RoomType,room_id = RoomId} = Player,
        %?INFO(?_U("直线我的函数:~p"), [1]),
        game_change_room_info(RoomId,RoomType),
        Player
            end,

      start_delay_result_timer(?PlayerBetDelay,Fun)

  end.
do_send_game_result(NewMemberList,Use_Id,Pos,CardRes,Result,RankMoney,RankWin_Money,RankLose,Curmoney,BetMoney,TabelMoney,Unit_id,MsgBet) ->
  #cg_bet_money{one_chip_num = One,two_chip_num = Two,three_chip_num = Three,four_chip_num = Four,five_chip_num = Five}= MsgBet,
    Msg = #gc_bet_money
    {
      usr_id = Use_Id,
      pos   = Pos,
      cardres   = CardRes,
      result    = Result,
      rank_money= RankMoney,
      rank_win_money = RankWin_Money,
      rank_lose_money = RankLose,
      curmoney = Curmoney,
      betmoney = BetMoney,
      tablemoney = TabelMoney,
      one_chip_num = One,
      two_chip_num = Two,
      three_chip_num = Three,
      four_chip_num = Four,
      five_chip_num = Five,
      unit_id   = Unit_id
    }
    ,
    MsgId = ?PROTO_CONVERT({?MODULE, gc_bet_money}),

    send_msg_broadcast(NewMemberList,MsgId, Msg).

do_send_friend_game_result(NewMemberList,Use_Id,Pos,CardRes,Result,Curmoney,BetMoney,TabelMoney,Unit_id,MsgBet) ->
  #cg_bet_money{one_chip_num = One,two_chip_num = Two,three_chip_num = Three,four_chip_num = Four,five_chip_num = Five}= MsgBet,
  Msg = #gc_bet_money
  {
    usr_id = Use_Id,
    pos   = Pos,
    cardres   = CardRes,
    result    = Result,
    curmoney = Curmoney,
    betmoney = BetMoney,
    tablemoney = TabelMoney,
    one_chip_num = One,
    two_chip_num = Two,
    three_chip_num = Three,
    four_chip_num = Four,
    five_chip_num = Five,
    unit_id   = Unit_id
  }
  ,
  MsgId = ?PROTO_CONVERT({?MODULE, gc_bet_money}),

  send_msg_broadcast(NewMemberList,MsgId, Msg).


send_error_msg(#player{id = PlayerId}=Player)->
  Msg = #gc_bet_money
  {
    usr_id = -1,
    pos   = -1,
    cardres   = -1,
    result    = -1,
    rank_money= -1,
    rank_win_money = -1,
    rank_lose_money = -1,
    curmoney = -1,
    betmoney = -1,
    tablemoney = -1,
    one_chip_num = -1,
    two_chip_num = -1,
    three_chip_num = -1,
    four_chip_num = -1,
    five_chip_num = -1,
    unit_id   = -1
  },
  MsgId = ?PROTO_CONVERT({?MODULE, gc_bet_money}),
  ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg),
  Player.


do_game_result(CardOne,CardTwo,CardRes) ->
  One = CardOne rem 54,
  Two = CardTwo rem 54,
  Res= CardRes rem 54,

  NewOne = do_reform_card_value(One),
  NewTwo = do_reform_card_value(Two),
  NewRes = do_reform_card_value(Res),
  case NewOne >NewTwo of
    true ->
      do_game_res(NewTwo,NewOne,NewRes);
    false ->
      do_game_res(NewOne,NewTwo,NewRes)
  end.



do_reform_card_value(CardNum) ->
  case CardNum of
    0 ->
      NewNum = 0;
    53 ->
      NewNum = 14;
    _ ->
       CardRes = CardNum rem 13,
      ?IF(CardRes =:= 0, NewNum = 13,NewNum = CardRes)
  end,
  NewNum.

do_game_res(CardOne,CardTwo,CardRes) ->
  Res = case CardRes of
    CardOne ->
      ?Game_Lose_Double;
    CardTwo ->
      ?Game_Lose_Double;
    _->
      ?Game_None
  end,
  ?IF(Res =:= ?Game_None, NewRes = do_game_res1(CardOne,CardTwo,CardRes),NewRes = Res),
  NewRes.

do_game_res1(CardOne,CardTwo,CardRes) ->
  case CardRes>CardOne andalso CardRes <CardTwo  of
   true->
     ?Game_Win;
    false->
      ?Game_Lose
  end.


% 检查玩家5妙后是否准备

%玩家放弃
%
is_friend_over(RoomType,RoomId)->

  case RoomType =:= ?Friend_Room_create orelse RoomType =:= ?Friend_Room_join of
    true ->
      case catch get_room(RoomType,RoomId) of
        #room{game_over = GameOver}=_Room ->
          GameOver;
        _->
          false
      end;
    _ ->

      false
  end.



is_my_turn(RoomType,RoomId,PlayerId)->

  case catch get_room(RoomType,RoomId) of
    #room{member = PlayerList,turn = CurTurn}=_Room ->
       TempList = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId =:= PlayerId],
      case length(TempList) > 0 of
        true ->
          [#room_member{pos = MyPos}=_MyMember] = TempList,
          ?IF(MyPos =:= CurTurn,true,false);
        _->
          false
      end;
    _->
      %?INFO(?_U("是不是我的回合,监测时,房间没有找到:~p,"), [1]),
      false
  end.






do_quit_bet(#player{room_id = RoomId,roomtype = RoomType} = Player)->

  %?INFO(?_U("玩家放弃:~p"), [1]),

  game_change_room_info(RoomId,RoomType),

  Player.

do_quit_room(Player,QuitType) ->
  #player{roomtype = RoomType,room_id = RoomId} = Player,
  mod_room:cancle_delay_by_time(?RoomPrepareTime),
  case catch get_room(RoomType,RoomId) of
    #room{roomstate = RoomState}=Room ->
      case RoomType of
        ?Friend_Room_create->
          case RoomState =:= ?ROOM_WAIT_READY of
            true->
              delete_friend_room(Player);
            _->
              do_quit_logic_friend(Room,Player,QuitType)
          end;
        ?Friend_Room_join->
          do_quit_logic_friend(Room,Player,QuitType);
        _->
          do_quit_logic1(Room,Player,QuitType)
      end;
    _->
      %?INFO(?_U("退出房间时,房间没有找到:~p,"), [1]),
      Player
  end.

do_quit_logic1(Room,Player,QuitType)->
  #player{id =PlayerId} = Player,

  #room{id = Id,member = PlayerList} = Room,

  case Id =/= ?NULL_ROOMID of
    true ->
      TempList = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId =:= PlayerId],
      case length(TempList) > 0 of
        true->
          [#room_member{pos  = MyPos,state = PlayerState}=_MyMember] =TempList,
          do_delete_check_restart(Room,Player,QuitType,PlayerState,MyPos),
          Msg = #gc_quit_room
          {
            usr_id                      = 6780,
            pos                         = MyPos,
            type                        = QuitType,
            unit_id                     = 987
          },
          MsgId = get_msg_id(gc_quit_room),
          send_msg_broadcast(PlayerList,MsgId, Msg),

          case {QuitType,PlayerState} of
            {?QUIT_NET_ERROR,?PLAYER_Ready} ->
              Player;
            _ ->
              Player#player{room_id = -1,roomtype = -1}
          end;
        _->
          Player#player{room_id = -1,roomtype = -1}
      end;

    _->
      Player#player{room_id = -1,roomtype = -1}
  end.

do_quit_logic_friend(Room,Player,QuitType)->
  #player{id =PlayerId} = Player,

  #room{id = Id,leader = LeaderId,member = PlayerList} = Room,

  case Id =/= ?NULL_ROOMID of
    true ->
      TempList = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId =:= PlayerId],
      case length(TempList) > 0 of
        true->
          [#room_member{pos  = MyPos,score = Score,state = PlayerState}=_MyMember] =TempList,
          do_friend_delete_check_restart(Room,Player,QuitType,PlayerState,MyPos),
          Msg = #gc_quit_room
          {
            usr_id                      = 6780,
            pos                         = MyPos,
            type                        = QuitType,
            unit_id                     = 987
          },
          MsgId = get_msg_id(gc_quit_room),
          send_msg_broadcast(PlayerList,MsgId, Msg),

          case QuitType of
            ?QUIT_NET_ERROR ->
              Player#player{gamenum = Score};
            _ ->
              Player#player{room_id = -1,roomtype = -1}
          end;
        _->
          Player#player{room_id = -1,roomtype = -1}
      end;

    _->
      Player#player{room_id = -1,roomtype = -1}
  end.


do_friend_delete_check_restart(Room,Player,Type,PlayerState,MyPos)->
  #room{table_money = Table_Money,roomstate = RoomState,turn = CurTurn,game_start_time = StartTime} = Room,
  #player{id =PlayerId,roomtype = RoomType,room_id = RoomId} = Player,
  MemberList =  delete_member(RoomType,RoomId,PlayerId,Type,PlayerState,Table_Money),
  case RoomState of
    ?ROOM_START->
      case {MyPos == CurTurn,Table_Money> 0} of
        {true,true}->
          do_quit_bet(Player);
        {true,false}->
          case catch get_room(RoomType,RoomId) of
            #room{member = NewMemberList}=Room2 ->
              reset_room_ready(Room2,RoomType),
              do_send_reset_msg(NewMemberList);
            _->
              ?INFO(?_U("观看者,变为准备,房间没有找到:~p,"), [1]),
              ok
          end;
        _->
          ok
      end;
    ?ROOM_WAIT_READY->
      case StartTime == -1 of
        true->
          ?INFO(?_U("好友房间没开始---:~p,"), [1]),
          ok;
        _->
          ?IF(length(MemberList) =:= 0,ok,check_game_start2(RoomId,RoomType))
      end
  end.

do_delete_check_restart(Room,Player,Type,PlayerState,MyPos)->
  #room{table_money = Table_Money,roomstate = RoomState,turn = CurTurn} = Room,
  #player{id =PlayerId,roomtype = RoomType,room_id = RoomId} = Player,
  MemberList =  delete_member(RoomType,RoomId,PlayerId,Type,PlayerState,Table_Money),
  case RoomState of
    ?ROOM_START->
      ReadyList = [X|| #room_member{state = State} = X <-MemberList,State =:= ?PLAYER_Ready],
      ObserverList = [X|| #room_member{state = State} = X <-MemberList,State =:= ?PLAYER_OBSERVER],
      case {length(ReadyList) =:= 0,length(ObserverList) /= 0} of
        {true,true}->
          %?INFO(?_U("观看者,变为准备:~p"), [1]),
          case catch get_room(RoomType,RoomId) of
            #room{}=Room2 ->
              reset_room_ready(Room2,RoomType),
              do_send_reset_msg(ObserverList);
            _->
              ?INFO(?_U("观看者,变为准备,房间没有找到:~p,"), [1]),
              ok
          end;

        _->
          case {MyPos == CurTurn,Table_Money> 0} of
            {true,true}->
              do_quit_bet(Player);
            {true,false}->
              case catch get_room(RoomType,RoomId) of
                #room{member = NewMemberList}=Room2 ->
                  reset_room_ready(Room2,RoomType),
                  do_send_reset_msg(NewMemberList);
                _->
                  ?INFO(?_U("观看者,变为准备,房间没有找到:~p,"), [1]),
                  ok
              end;
            _->
              ok
          end,
          ok
      end;
    ?ROOM_WAIT_READY->

      ?IF(length(MemberList) =:= 0,ok,check_game_start2(RoomId,RoomType))

  end.


do_send_reset_msg([])->
  ok;
do_send_reset_msg(MemberList)->

  Code1 = wg_util:rand(1000,10000000),
  Code2 = wg_util:rand(1000,10000000),
  Req = {?Reset_GAME, Code1, Code2},

  lists:map
  (
    fun(#room_member{id = SendId}=_MyMember) ->

      ok = player_server:s2s_cast(SendId, ?MODULE, Req)

    end,
    MemberList

  ).
check_player_prepare()->
  Fun = fun(Player) ->
    check_prepare(Player)
        end,
  start_delay_result_timer(?RoomPrepareTime,Fun).


check_prepare(#player{id = PlayerId,roomtype = RoomType,room_id = RoomId} = Player)->

  case is_friend_over(RoomType,RoomId) of
    true->
      ok;
    false->
      case catch get_room(RoomType,RoomId) of
        #room{id = Id,member = PlayerList}=_Room ->
          case Id =/= ?NULL_ROOMID of
            true ->
              %?INFO(?_U("开始检查房间准备状态:~p"), [1]),
              [#room_member{state  = MyState}=_MyMember] = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId =:= PlayerId],
              ?IF(MyState =:= ?PLAYER_Ready,Player2 = Player, Player2 = do_quit_room(Player,?QUIT_NOT_PREPARE));
            false->
              Player2 = Player
            %?INFO(?_U("检查房间准备状态时,房间没找到:~p"), [1])

          end,
          Player2;
        _->
          ?INFO(?_U("检查玩家是否准备时,房间没有找到:~p,"), [1]),
          Player
      end
  end.




check_player_turn()->
  Fun = fun(Player) ->
    check_turn(Player)
        end,
  start_delay_result_timer(?RoomTurnTime,Fun).


check_turn(#player{roomtype = RoomType,room_id = RoomId} = Player)->
  game_change_room_info(RoomId,RoomType),
  Player.


%向MemberList发送msg
send_msg_broadcast([], _MsgId, _Msg )->
  ok;
send_msg_broadcast(MemberList, MsgId, Msg) ->
    [begin
       ok = ?S2C_SEND_MERGE:player(Member#room_member.id, MsgId, Msg)
    end || Member <- MemberList],
    ok.

game_over(RoomType,RoomId)->
  case catch get_room(RoomType,RoomId) of
    #room{member = MemberList,game_over_msg_send = MsgIsSend} = Room ->
      case MsgIsSend of
        true->
          ok;
        false->
          Req = {?FRIEND_GAME_OVER},

          lists:map
          (
            fun(#room_member{id = SendId}=_MyMember) ->
              %?INFO(?_U("发送玩家准备的id:~p"), [SendId]),

              ok = player_server:s2s_cast(SendId, ?MODULE, Req)

            end,
            MemberList

          ),
          %Room2 =Room#room{game_over_msg_send = true},
          %room_friend_mgr:set(Room2)
          room_friend_mgr:delete(RoomId)
      end;
    _->
      ok
  end.




