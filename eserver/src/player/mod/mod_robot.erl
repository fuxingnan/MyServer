%%%-------------------------------------------------------------------
%%% @author fx
%%% @copyright (C) 2015, <COMPANY>
%%% @doc 邮件逻辑模块
%%%
%%% @end
%%% Created : 07. 七月 2015 下午2:18
%%%-------------------------------------------------------------------
-module(mod_robot).
-author("fx").
-include("wg.hrl").
-include("game.hrl").
-include("../src/proto/proto.hrl").
-include("pbmessage_pb.hrl").
-include("lang.hrl").
-include("room.hrl").
%% API
-behaviour(gen_mod).
-export([start/0]).
%% gen_mod回调函数
-export([i/1, p/1, init/1, terminate/0,
    init_player/2, gather_player/1, terminate_player/1,
    handle_c2s/3, handle_timeout/2, handle_s2s_call/2, handle_s2s_cast/2]).

-define(DelayJoinRoom,  5000).      %延迟加入房间
-define(CheckPlay,  60000).      %延迟加入房间

-define(BetMoney, betmoney).

-define(BetMoneyRes, betmoneyres).

-define(MsgCheckPlay, checkplay).
-define(MsgCheckJoin, checkplayJoin).
-define(NewRoom_Less_TableMoney, 3000).      %延迟加入房间
start_delay_result_timer(Time,Fun) ->
    gen_mod:cancel_absolute_timer(?MODULE,Time),
    gen_mod:start_absolute_timer(?MODULE, Time, ?DELAY_CALC_EVENT(Fun)).

start_delay_bet_money_timer(Time,Req) ->
    gen_mod:cancel_absolute_timer(?MODULE,Time),
    gen_mod:start_absolute_timer(?MODULE,Time,Req).

start_loop_timer(Time,Req) ->
    gen_mod:start_timer(?MODULE,Time,Req,true).


%% @doc 启动模块
start() ->
    gen_mod:start_module(?MODULE, []).

init([]) ->
    ok.

i(_Player)->
   ok.

p(Info)->
    ok.

terminate() ->
    ok.

terminate_player(_Player) ->
    ok.

init_player(#player{robot = Robot} = Player, ?NEW) ->
    #robot{is_robot = IsRobot} = Robot,
    Player1 = case IsRobot of
                    true ->


                        Req =  {?MsgCheckPlay},
                        Req1 =  {?MsgCheckJoin},

                       Time = wg_util:rand(600000,2000000),
                       Time1 = wg_util:rand(300000,900000),



                        start_loop_timer(Time,Req),
                        start_loop_timer(Time1,Req1),

                        Player;
                        %?INFO(?_U("我是机器人"), []);
                    _->
                        Player
                end,
    Player1;
init_player(Player, {?MIGRATE, ?NONE}) ->
    %?DEBUG(?_U("初始化mod-playrattr: ~p"), ?MIGRATE),
    Player.

gather_player(_Player) ->
    ?NONE.

handle_timeout({?MsgCheckPlay}, #player{roomtype = RoomType,room_id = RoomId} = Player) ->
    #player{robot = Robot} = Player,
    #robot{state = RobotState} = Robot,
    Player2 = case RobotState of
                ?Robot_Wait->
                    Player;
                ?Robot_Play->
                    case catch mod_room:get_room(RoomType,RoomId) of
                        #room{table_money = CurTableMoney,min_money = MinMoney}= _Room ->
                            case CurTableMoney < MinMoney * 10 of
                                true->
                                    Player1 = reset_money_by_type(Player),
                                    do_send_msg_quit(Player1);
                                _->
                                    Player1 = Player
                            end;
                        _->
                            Player1 = Player
                    end,

                    Player1
              end,
    {ok, Player2};
handle_timeout({?MsgCheckJoin}, #player{} = Player) ->
    #player{id = PlayerId,robot = Robot} = Player,
    #robot{state = RobotState} = Robot,
    Player2 = case RobotState of
                  ?Robot_Wait->
                      %?INFO(?_U("玩家状态准备要加入房间,~p"), [PlayerId]),
                      Player1 = reset_money_by_type(Player),
                      join_room(Player1),
                      Player1;
                  ?Robot_Play->
                      Player
              end,
    {ok, Player2};
handle_timeout({?BetMoneyRes,_CurMoney}, #player{} = Player) ->
    Player2 = check_player_is_quit(Player),
    {ok, Player2};
handle_timeout({?BetMoney,_TableMoney,Diff}, #player{} = Player) ->
    #player{robot = Robot,roomtype = RoomType,room_id = RoomId} = Player,
    #robot{type = RobotType} = Robot,

    case catch mod_room:get_room(RoomType,RoomId) of
        #room{table_money = CurTableMoney}= _Room ->
            bet_money(Player,CurTableMoney,Diff,RobotType);
        _->
            do_send_msg_quit(Player)
    end,
    {ok, Player};
handle_timeout(?DELAY_CALC_EVENT(Fun), #player{roomtype = RoomType, room_id = RoomId} = Player) ->

    Player2 = Fun(Player),
    %?DEBUG(?_U("收到延迟累消息:~p"), [Player2]),
    {ok, Player2};
handle_timeout({alert, State}, Player) ->
    {ok, Player};
handle_timeout({enter, _NewState}, Player) ->
    {ok, Player};
handle_timeout(_Event, Player) ->
    ?DEBUG(?_U("收到未知time消息:~p"), [_Event]),
    {ok, Player}.

handle_s2s_call(_Req, Player) ->
    ?DEBUG(?_U("未知的s2s_call请求: ~p"), [_Req]),
    {unknown, Player}.


handle_s2s_cast(#gc_join_room{result = Result,room_id = RoomState,my_pos = MyPos}=_Msg, #player{id = PlayerId,robot = Robot} = Player) ->
    %?INFO(?_U("机器人收到 gc_join_room~p"), [PlayerId]),
    case {RoomState,Result} of
        {?ROOM_WAIT_READY,?E_OK}->
            robot_prepare(Player),
            NewRobot = Robot#robot{my_pos = MyPos,state = ?Robot_Play},
            NewPlayer = Player#player{robot = NewRobot};
        {?ROOM_START,?E_OK}->
            NewRobot = Robot#robot{my_pos = MyPos,state = ?Robot_Play},
            NewPlayer = Player#player{robot = NewRobot};
        _->
            %?INFO(?_U("机器人加入房间失败~p"), [PlayerId]),
            NewPlayer = Player
    end,
    {ok, NewPlayer};
handle_s2s_cast(#gc_ret_ready{}=_Msg, #player{id = PlayerId} = Player) ->

    %?INFO(?_U("机器人重新准备~p"), [PlayerId]),
    robot_prepare(Player),
    {ok, Player};
handle_s2s_cast(#gc_quit_room{pos = CurPos}=_Msg, #player{id = PlayerId,robot = Robot} = Player) ->
    #robot{my_pos = MyPos} = Robot,

    case CurPos == MyPos andalso  CurPos > 0of
        true->
            %?INFO(?_U("机器人我真的退出了~p"), [PlayerId]),
            NewRobot = Robot#robot{state  = ?Robot_Wait,my_pos = -1},
            NewPlayer = Player#player{robot = NewRobot};
        _->
            NewPlayer = Player
    end,
    {ok, NewPlayer};
handle_s2s_cast(#gc_bet_money{pos = CurPos,result = GameRes,betmoney = BetMoney}=_Msg, #player{room_id = RoomId,roomtype = RoomType, id = PlayerId,robot = Robot} = Player) ->
    #robot{my_pos = MyPos} = Robot,

    case CurPos == MyPos andalso  CurPos > 0 of
        true->
            %?INFO(?_U("机器人下注返回~p"), [PlayerId]),
            MinMoney1 = case catch mod_room:get_room(RoomType,RoomId) of
                            #room{min_money = MinMoney}= _Room ->
                                MinMoney;
                            _->
                                1000
                        end,
            case GameRes =:= ?Game_Win andalso BetMoney > 6*MinMoney1 of
                true->
                    do_send_voice_msg(Player);
                _->
                    ok
            end,
            check_player_is_quit(Player),
            NewPlayer = Player;
        _->
            NewPlayer = Player
    end,

    {ok, NewPlayer};
handle_s2s_cast(#gc_player_turn{cardnum = CardNum,pos = CurPos,cardone = CardOne,cardtwo = CardTwo,table_money = TableMoney}=_Msg, #player{id =Id,robot = Robot} = Player) ->
    #robot{my_pos = MyPos} = Robot,
    case CurPos == MyPos of
        true->
            One = CardOne rem 54,
            Two = CardTwo rem 54,
            NewCardOne = mod_room:do_reform_card_value(One),
            NewCardTwo = mod_room:do_reform_card_value(Two),
            Diff = ?IF(NewCardTwo > NewCardOne,NewCardTwo - NewCardOne,NewCardOne - NewCardTwo),

            Req = {?BetMoney,TableMoney,Diff},
            Time = case CardNum > 20 of
                        true->
                            wg_util:rand(2000,5000);
                        false->
                            wg_util:rand(3000,10000)
                    end,
            start_delay_bet_money_timer(Time,Req),
            NewPlayer = Player;
        false->
            NewPlayer = Player
    end,
    {ok, NewPlayer};
handle_s2s_cast(_Msg, #player{} = Player) ->

    %do_receive_mail(Player, SenderType, SenderGuid, MailUpdate),

    {ok, Player}.
handle_c2s(_, _MsgId,  #player{} = _Player) ->
    ok.

check_player_is_quit(Player)->
    #player{robot = Robot,money = MyMoney} = Player,
    #robot{type = RobotType} = Robot,
    Player2 = case RobotType of
                  ?New_Room_Robot ->
                      case {MyMoney < ?NewRoom_MinMoney,MyMoney > ?Max_NewRoom} of
                          {false,false}->
                              Player;
                          {_,_}->
                              do_send_msg_quit(Player)
                      end;
                  ?Ordinary_Room_Robot ->
                      case {MyMoney < ?OrdinaryRoom_MinMoney,MyMoney > ?Max_OrdinaryRoom} of
                          {false,false}->
                              Player;
                          {_,_}->
                              do_send_msg_quit(Player)
                      end;
                  ?Mastr_Room_Robot ->
                      case MyMoney < ?MasterRoom_MinMoney of
                          false->
                              Player;
                          true->
                              do_send_msg_quit(Player)
                      end;
                  _->
                      Player
              end,
    Player2.

reset_money_by_type(#player{robot = Robot,moneyRank = MoneyRank} = Player)->
    #robot{type = RobotType} = Robot,
    ImageUrlId = wg_util:rand(1,18),
    case RobotType of
        ?New_Room_Robot ->
            %?INFO(?_U("重新加钱"), []),
            NewMoneyRank = MoneyRank#money_rank_data{money = 15000,name = gate_acc:random_name(),image = ?U2B("Robot/robot_"++integer_to_list(ImageUrlId)++".png")},
            Player#player{money = 15000,moneyRank = NewMoneyRank};
        ?Ordinary_Room_Robot ->
            NewMoneyRank = MoneyRank#money_rank_data{money = 34000,name = gate_acc:random_name(),image = ?U2B("Robot/robot_"++integer_to_list(ImageUrlId)++".png")},
            Player#player{money = 34000,moneyRank = NewMoneyRank};
        ?Mastr_Room_Robot ->
            NewMoneyRank = MoneyRank#money_rank_data{money = 234000,name = gate_acc:random_name(),image = ?U2B("Robot/robot_"++integer_to_list(ImageUrlId)++".png")},
            Player#player{money = 234000,moneyRank = NewMoneyRank};
        _->
            Player
    end.
join_room(#player{robot = Robot} = Player)->
    %?INFO(?_U("加入房间执行"), []),
    #robot{type = RobotType} = Robot,
    case RobotType of
        ?New_Room_Robot ->
            do_send_msg_type(?New_Room,Player);
        ?Ordinary_Room_Robot ->
            do_send_msg_type(?Ordinary_Room,Player);
        ?Mastr_Room_Robot ->
            do_send_msg_type(?Master_Room,Player);
        _->
            ok
    end.

robot_prepare(Player)->

    #player{robot = Robot} = Player,

    #robot{type = RobotType} = Robot,

    case RobotType of
        ?New_Room_Robot ->
            do_send_msg_prepare(?New_Room,Player);
        ?Ordinary_Room_Robot ->
            do_send_msg_prepare(?Ordinary_Room,Player);
        ?Mastr_Room_Robot ->
            do_send_msg_prepare(?Master_Room,Player);
        _->
            ok
    end.

bet_money(Player,TableMoney,Diff,RobotType)->
    case RobotType of
        ?New_Room_Robot ->

            do_send_msg_bet(Player,Diff,TableMoney,?NewRoom_MinMoney_di);
        ?Ordinary_Room_Robot ->
            do_send_msg_bet(Player,Diff,TableMoney,?OrdinaryRoom_MinMoney_di);
        ?Mastr_Room_Robot ->
            do_send_msg_bet(Player,Diff,TableMoney,?MasterRoom_MinMoney_di);
        _->
            ok
    end.
do_send_msg_bet(Player,Diff,TableMoney,MinMoney)->
    case TableMoney > ?NewRoom_Less_TableMoney of
        true->
            do_bet_logic_smart(Player,Diff,TableMoney,MinMoney);
        false->
            do_bet_logic_smart(Player,Diff,TableMoney,MinMoney)
    end.
do_send_msg_prepare(RoomType,Player)->
    #player{id = PlayerId,user_id = Use_Id,unit_id = Unit_Id} = Player,
    Msg = #cg_add_money
    {
        usr_id = Use_Id,
        roomtype = RoomType,
        unit_id = Unit_Id
    },
    MsgId = ?PROTO_CONVERT({mod_room, cg_add_money}),
    %?INFO(?_U("发送准备房间"), []),
    player_server:client_msg(PlayerId,mod_room,MsgId,Msg).


do_send_msg_quit(Player)->
    #player{id = PlayerId,user_id = Use_Id,unit_id = Unit_Id,roomtype = RoomType,room_id = RoomId} = Player,

    case catch mod_room:get_room(RoomType,RoomId) of
        #room{}= _Room ->
            Msg = #cg_quit_room
            {
                usr_id = Use_Id,
                type = ?QUIT_BY_SELF,
                unit_id = Unit_Id
            },
            MsgId = ?PROTO_CONVERT({mod_room, cg_quit_room}),
            %?INFO(?_U("机器人发送退出房间信息~p"), [PlayerId]),
            player_server:client_msg(PlayerId,mod_room,MsgId,Msg),
            Player;
        _->
            Player
    end.




do_send_msg_foice_join(Player)->
    #player{id = PlayerId,user_id = Use_Id,unit_id = Unit_Id} = Player,
    Msg = #cg_force_join
    {
        usr_id = Use_Id,
        unit_id = Unit_Id
    },
    MsgId = ?PROTO_CONVERT({mod_room, cg_force_join}),
    player_server:client_msg(PlayerId,mod_room,MsgId,Msg).



do_send_voice_msg(Player)->
    #player{id = PlayerId,user_id = Use_Id,unit_id = Unit_Id} = Player,
    Msg = #cg_sound
    {
        usr_id = Use_Id,
        id = 2001,
        unit_id = Unit_Id
    },
    MsgId = ?PROTO_CONVERT({mod_chat, cg_sound}),
    %?INFO(?_U("发送加入房间"), []),
    player_server:client_msg(PlayerId,mod_chat,MsgId,Msg).

do_send_msg_type(RoomType,Player)->
    #player{id = PlayerId,user_id = Use_Id,unit_id = Unit_Id} = Player,
    Msg = #cg_join_room
    {
        usr_id = Use_Id,
        room_type = RoomType,
        unit_id = Unit_Id
    },
    MsgId = ?PROTO_CONVERT({mod_room, cg_join_room}),
    %?INFO(?_U("发送加入房间"), []),
    player_server:client_msg(PlayerId,mod_room,MsgId,Msg).

do_bet_logic_smart(Player,Diff,TableMoney,MinMoney)->
    %?INFO(?_U("smart 桌面money:~p"), [TableMoney]),
    #player{money = MyMoney} = Player,
    case {Diff > 5 andalso Diff < 9,Diff > 8} of
        {true,false}->
            ChipsNum = wg_util:rand(1,5),

            HalfMoney = MinMoney*ChipsNum,

            ?IF(HalfMoney < TableMoney, HalfMoney1 = HalfMoney, HalfMoney1 = TableMoney),
            ?IF(HalfMoney1 > MyMoney, do_send_msg_bet_money(MyMoney,Player),do_send_msg_bet_money(HalfMoney1,Player));
        {false,true}->
            ChipsNum = wg_util:rand(5,12),
            HalfMoney = MinMoney*ChipsNum,
            ?IF(HalfMoney < TableMoney, HalfMoney1 = HalfMoney, HalfMoney1 = TableMoney),
            ?IF(HalfMoney1 > MyMoney, do_send_msg_bet_money(MyMoney,Player),do_send_msg_bet_money(HalfMoney1,Player));
        _->
            do_send_msg_bet_money(0,Player)
    end .


do_bet_logic_stupid(Player,Diff,TableMoney,MinMoney)->
    %?INFO(?_U("stupid 桌面money:~p"), [TableMoney]),
    #player{money = MyMoney} = Player,
    case {Diff > 3 andalso Diff < 6,Diff > 5} of
        {true,false}->
            HalfMoney = TableMoney/2,
            ?IF(HalfMoney < MinMoney, HalfMoney1 = MinMoney, HalfMoney1 = HalfMoney),
            HalfMoney3 = trunc(HalfMoney1/MinMoney)*MinMoney,

            ?IF(HalfMoney3 < TableMoney, HalfMoney4 = HalfMoney3, HalfMoney4 = TableMoney),

            ?IF(HalfMoney4 > MyMoney, do_send_msg_bet_money(MyMoney,Player),do_send_msg_bet_money(HalfMoney4,Player));

        {false,true}->
            ?IF(TableMoney > MyMoney, do_send_msg_bet_money(MyMoney,Player),do_send_msg_bet_money(TableMoney,Player));
        _->
            do_send_msg_bet_money(0,Player)
    end .
do_send_msg_bet_money(BetMoney,Player)->
    #player{id = PlayerId,user_id = Use_Id,robot = Robot,unit_id = Unit_Id} = Player,
    #robot{type = RobotType} = Robot,
    case RobotType of
        ?New_Room_Robot ->
            OneChip = 100,
            TwoChip = 500,
            ThreeChip = 1000,
            FourChip = 5000,
            FiveChip = 10000;
        ?Ordinary_Room_Robot ->
            OneChip = 1000,
            TwoChip = 5000,
            ThreeChip = 10000,
            FourChip = 50000,
            FiveChip = 100000;
        ?Mastr_Room_Robot ->
            OneChip = 10000,
            TwoChip = 50000,
            ThreeChip = 100000,
            FourChip = 500000,
            FiveChip = 1000000
    end,

    FiveNum = trunc(BetMoney/FiveChip),

    BetMoney1 = BetMoney - FiveNum*FiveChip,
    FourNum = trunc(BetMoney1/FourChip),

    BetMoney2 = BetMoney1 - FourNum*FourChip,
    ThreeNum = trunc(BetMoney2/ThreeChip),

    BetMoney3 = BetMoney2 - ThreeNum*ThreeChip,
    TwoNum = trunc(BetMoney3/TwoChip),

    BetMoney4 = BetMoney3 - TwoNum*TwoChip,
    OneNum = trunc(BetMoney4/OneChip),

    Sum = FiveNum*FiveChip + FourNum*FourChip + ThreeNum*ThreeChip + TwoNum*TwoChip + OneNum*OneChip,
    Msg = #cg_bet_money
    {
    usr_id = Use_Id,
    money = Sum,
    five_chip_num = FiveNum,
    four_chip_num = FourNum,
    three_chip_num = ThreeNum,
    two_chip_num = TwoNum,
    one_chip_num = OneNum,
    unit_id = Unit_Id
    },
    MsgId = ?PROTO_CONVERT({mod_room, cg_bet_money}),
    %?INFO(?_U("机器人id~p,bet money ~p finally ~p"), [PlayerId,BetMoney,Sum]),

    player_server:client_msg(PlayerId,mod_room,MsgId,Msg).
do_force_join_room(Player)->
    #player{roomtype = RoomType,money = MyMoney,room_id = RoomId} = Player,

    case catch mod_room:get_room(RoomType,RoomId) of
        #room{table_money = Table_money,min_money = MinMoney,member = Member}= _Room ->
            NewTurnList = [X||#room_member{state = State} = X <-Member,State =:= ?PLAYER_Ready],
            PayMoney = Table_money/(length(NewTurnList) + 1),
            ?IF(PayMoney < MinMoney, PayMoney1 = MinMoney, PayMoney1 = PayMoney),
            PayMoney2 = trunc(PayMoney1/MinMoney)*MinMoney,
            case {Table_money > 0,length(Member) > 0,MyMoney >= PayMoney2+5000} of
                {true,true,true}->
                    do_send_msg_foice_join(Player);
                _->
                    ok
            end;
        _->
            ok
    end.
send_msg_broadcast([], _MsgId, _Msg )->
    ok;
send_msg_broadcast(MemberList, MsgId, Msg) ->
    [begin

         ?IF(Member#room_member.state =:= ?PLAYER_OFFlINE,ok,ok = ?S2C_SEND_MERGE:player(Member#room_member.id, MsgId, Msg))

     end || Member <- MemberList],
    ok.
