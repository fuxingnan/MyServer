%%%-------------------------------------------------------------------
%%% @author fx
%%% @copyright (C) 2015, <COMPANY>
%%% @doc 邮件逻辑模块
%%%1
%%% @end
%%% Created : 07. 七月 2015 下午2:18
%%%-------------------------------------------------------------------
-module(mod_kenroom).
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

init_player(#player{} = Player, ?NEW) ->

    Player;
init_player(Player, {?MIGRATE, ?NONE}) ->
    %?DEBUG(?_U("初始化mod-playrattr: ~p"), ?MIGRATE),
    Player.

gather_player(_Player) ->
    ?NONE.

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

handle_s2s_cast({?START_GAME, CurPos,CurState,TableMoney,LeftTime,RoomState,RoomStep,CardNUM,MaxBet,Poker1,Poker2,PokerList3,PosList,NeedCard}, Player) ->

    #player{id = SendId,roomtype = RoomType,card_room = RoomCardNum} = Player,

    Msg = #gc_ken_player_turn
    {
        cur_pos = CurPos,
        cur_state = CurState,
        table_money =  TableMoney,
        left_time = LeftTime,
        room_state = RoomState,
        room_step =  RoomStep,
        card_num  =  CardNUM,
        max_bet   =  MaxBet,
        over_time = 0,
        poker1 = Poker1,
        poker2 = Poker2,
        poker_list3 = PokerList3,
        poker_list4 = [],
        poker_list5 = [],
        open_list   = [],
        pos_list = PosList,
        isbegin = true
    },
    ?INFO(?_U("发送开始游戏消息:~p"), [Msg]),
    MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_player_turn}),

    ok = ?S2C_SEND_MERGE:player(SendId, MsgId, Msg),
    LeftCard= RoomCardNum - NeedCard,
    ?IF(LeftCard < 0 , NewLeftCard = 0, NewLeftCard = LeftCard),

    case RoomType of
        ?KenFriend_Room_create->
            Player2 = Player#player{card_room = NewLeftCard};
        _->
            Player2 = Player
    end,

    {ok, Player2};
handle_s2s_cast({?START_STEP_TWO, CurPos,CurState,RoomStep,CardNUM,Poker4List,PosList}, Player) ->

    #player{id = SendId} = Player,

    Msg = #gc_ken_player_turn
    {
        cur_pos = CurPos,
        cur_state = CurState,
        table_money =  0,
        left_time = 0,
        room_state = 0,
        room_step =  RoomStep,
        card_num  =  CardNUM,
        max_bet   =  0,
        over_time = 0,
        poker1 = -1,
        poker2 = -1,
        poker_list3 = [],
        poker_list4 = Poker4List,
        poker_list5 = [],
        open_list   = [],
        pos_list = PosList,
        isbegin = false
    },
    ?INFO(?_U("发送第二阶段开始游戏消息:~p"), [Msg]),
    MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_player_turn}),

    ok = ?S2C_SEND_MERGE:player(SendId, MsgId, Msg),


    {ok, Player};
handle_s2s_cast({?START_STEP_THREE, CurPos,CurState,RoomStep,CardNUM,Poker5List,PosList}, Player) ->

    #player{id = SendId} = Player,

    Msg = #gc_ken_player_turn
    {
        cur_pos = CurPos,
        cur_state = CurState,
        table_money =  0,
        left_time = 0,
        room_state = 0,
        room_step =  RoomStep,
        card_num  =  CardNUM,
        max_bet   =  0,
        over_time = 0,
        poker1 = -1,
        poker2 = -1,
        poker_list3 = [],
        poker_list4 = [],
        poker_list5 = Poker5List,
        open_list   = [],
        pos_list = PosList,
        isbegin = false
    },
    ?INFO(?_U("发送第二阶段开始游戏消息:~p"), [Msg]),
    MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_player_turn}),

    ok = ?S2C_SEND_MERGE:player(SendId, MsgId, Msg),


    {ok, Player};
handle_s2s_cast({recv_mail, _}, #player{} = Player) ->

    %do_receive_mail(Player, SenderType, SenderGuid, MailUpdate),

    {ok, Player}.

handle_c2s(#cg_join_ken_room{usr_id = BeginCode,min_poker = MinPoker,person_num = MaxPerson,every_bet =IsEveryBet,room_type = RoomType,room_key = RoomKey,need_card = NeedCard,game_times = GameTimes,min_money = MinMoney,max_bet = MaxBet,is_double = IsDouble,last_is_boom = LastIsBoom,unit_id = EndCode}, _MsgId,  #player{} = Player) ->
    #player{user_id = UserId, unit_id = UnitId} = Player,

    case {BeginCode == UserId andalso EndCode == UnitId,RoomType}of
        {true,_} ->
            case RoomType of
                ?Reconnect_Room ->
                    Player2 = do_reconnect_room_logic(Player);
                ?KenFriend_Room_create->
                    NewPlayer = Player#player{roomtype = RoomType},
                    Player2 = do_create_friend_room(NewPlayer,MaxPerson,MinPoker,IsEveryBet,MaxBet,LastIsBoom,IsDouble,MinMoney,GameTimes,NeedCard);
                ?KenFriend_Room_join->
                    NewPlayer = Player#player{roomtype = RoomType},
                    Player2 = do_friend_join(RoomKey,NewPlayer);
                _->
                    Player2 = Player
            end,
            Player2;
        _ ->
            Player2 = Player,
            ?INFO(?_U("加入房间服务器验证码错误:~p"), [1]),
            Player2
    end,

    {ok, Player2};

handle_c2s(#cg_ken_bet_money{usr_id = BeginCode,money = BetMoney,unit_id = EndCode}, _MsgId,  #player{} = Player) ->
    #player{user_id = UserId, unit_id = UnitId} = Player,

    case BeginCode == UserId andalso EndCode == UnitId of
        true ->

            Player2 = do_bet_money_logic(Player,BetMoney),

            Player2;
        _ ->
            Player2 = Player,
            ?INFO(?_U("加入房间服务器验证码错误:~p"), [1]),
            Player2
    end,

    {ok, Player2};
handle_c2s(#cg_ken_open_card{type = Type,pos = Pos}, _MsgId,  #player{id = MyID} = Player) ->

    #player{room_id = RoomId, roomtype =  RoomType} = Player,
    case catch mod_room:get_room(RoomType,RoomId) of
        #room_ken{member = Member,step = Step}= Room ->
            [#room_member{pork_1 = Poker1,pork_2 = Poker2}=MyMember] = [X|| #room_member{id = MemberId} = X <-Member,MemberId =:= MyID],
            ?IF(Step =:=?KEN_STEP_FOUR,PokerMsg1 = Poker1,PokerMsg1 = -1),
            ?IF(Step =:=?KEN_STEP_FOUR,PokerMsg2 = Poker2,PokerMsg2 = -1),

            case Type =:= 2 of
                true->
                    NewMember1 = MyMember#room_member{is_open_card = true},
                    NewMemberList1 = do_change_member(MyID,Member,NewMember1),

                    Room2 = Room#room_ken{member = NewMemberList1},
                    mod_room:set_room(Room2,?KenFriend_Room_create);
                _->
                    ok
            end,


            Msg = #gc_ken_open_card
            {
                type = Type,
                pos   = Pos,
                poker1 = PokerMsg1,
                poker2 = PokerMsg2
            }
            ,
            MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_open_card}),

            mod_room:send_msg_broadcast(Member,MsgId, Msg);
        _->
            ok
    end,

    {ok, Player};
handle_c2s(#cg_ken_add_money{roomtype = RoomType}, _MsgId,  #player{id = PlayerId,money = MyMoney,room_id = RoomId} = Player) ->
    case RoomType  of
        ?KenFriend_Room_create ->
            case friend_room_is_can_start(Player) of
                true->
                    do_create_change_ready_player_state(RoomType,PlayerId,RoomId,?PLAYER_Ready,?CHANGE_STATE);
                false->
                    Msg = #gc_friend_result
                    {
                        result = ?Other_No_Prepare
                    },
                    MsgId = ?PROTO_CONVERT({mod_room, gc_friend_result}),
                    ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg);
                ?No_Enough_Player->
                    Msg = #gc_friend_result
                    {
                        result = ?No_Enough_Player
                    },
                    MsgId = ?PROTO_CONVERT({mod_room, gc_friend_result}),
                    ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg);
                _->
                    ?INFO(?_U("好友房间开始,房间没有找到:~p"), [1])
            end;
        ?KenFriend_Room_join ->
            change_friend_join_ready_player_state(RoomType,PlayerId,RoomId,?PLAYER_Ready,?CHANGE_STATE);
        _ ->
            ?INFO(?_U("准备时服务器验证码错误:~p"), [1])
    end,
    {ok, Player}.
do_bet_money_logic(Player,BetMoney)->
    #player{room_id = RoomId, roomtype =  RoomType} = Player,
    case catch mod_room:get_room(RoomType,RoomId) of
        #room_ken{room_now_state = RoomNowState}= Room ->
            case RoomNowState of
                ?KEN_NOW_BET->
                    bet_state_logic(Player,Room,BetMoney);
                ?KEN_NOW_FOLLOW->
                    follow_state_logic(Player,Room,BetMoney);
                _->
                    Player
            end;
        _->
            Player
    end.

follow_state_logic(Player,Room,BetMoney)->
    case BetMoney =:= 0 of
        true->
            do_follow_koupai_state_logic(Player,Room,BetMoney);
        _->
            do_follow_state_logic(Player,Room,BetMoney)
    end.


do_follow_state_logic(Player,Room,BetMoney)->
    #player{id = MyID} = Player,
    #room_ken{member = MemberList,table_money = OldTableMoney,begin_pos = OldBeginPos}=Room,
    NewMemberList = [X||#room_member{play_state = State} = X <-MemberList,State =/= ?KEN_KOUPAI],

    [#room_member{pos = MyPos,score = OldScore}=MyMember] = [X|| #room_member{id = MemberId} = X <-NewMemberList,MemberId =:= MyID],

    #room_member{pos = MaxPos} = lists:last(NewMemberList),
    ?IF(MyPos  < MaxPos,NewOldTurn = MyPos,NewOldTurn = 0),
    [YourTurn|_]=[X||#room_member{pos = MemberPos} = X <-NewMemberList,MemberPos > NewOldTurn],
    #room_member{pos = TurnPos} = YourTurn,

    NewMember1 = MyMember#room_member{play_state = ?KEN_GENZHU,score = OldScore - BetMoney},
    NewMemberList1 = do_change_member(MyID,MemberList,NewMember1),
    Code1 = wg_util:rand(1000,10000000),
    Code2 = wg_util:rand(1000,10000000),

    case TurnPos =:= OldBeginPos of
        true->
            do_next_turn(Room#room_ken{table_money = OldTableMoney + BetMoney,member = NewMemberList1},Player,MyPos,BetMoney);
        _->
            Room2 = Room#room_ken{table_money = OldTableMoney + BetMoney,room_now_state = ?KEN_NOW_FOLLOW,follow_pos = TurnPos,member = NewMemberList1},
            mod_room:set_room(Room2,?KenFriend_Room_create),
            send_bet_result_msg(MemberList,Code1,MyPos,BetMoney,?KEN_GENZHU,TurnPos,?KEN_NOW_FOLLOW,Code2),

            Player#player{user_id = Code1,unit_id = Code2}
    end.

do_next_turn(Room,Player,MyPos,BetMoney)->
    #room_ken{member = MemberList,step = NowStep,begin_pos = OldBeginPos,room_begin_state = OldBeginState,start_pos = StartPos}=Room,
    Code1 = wg_util:rand(1000,10000000),
    Code2 = wg_util:rand(1000,10000000),
    NewMemberList = [X||#room_member{play_state = State} = X <-MemberList,State =/= ?KEN_KOUPAI],
    #room_member{pos = MaxPos} = lists:last(NewMemberList),
    ?IF(OldBeginPos  < MaxPos,NewOldTurn1 = OldBeginPos,NewOldTurn1 = 0),
    [YourTurn1|_]=[X||#room_member{pos = MemberPos1} = X <-NewMemberList,MemberPos1 > NewOldTurn1],
    #room_member{pos = TurnPos1} = YourTurn1,
    case OldBeginState of
        ?KEN_NOW_BET->
            Room2 = Room#room_ken{room_now_state = ?KEN_NOW_TI,room_begin_state = ?KEN_NOW_Null,begin_pos = -1,follow_pos = OldBeginPos},
            mod_room:set_room(Room2,?KenFriend_Room_create),
            send_bet_result_msg(MemberList,Code1,MyPos,BetMoney,?KEN_GENZHU,OldBeginPos,?KEN_NOW_TI,Code2);
        ?KEN_NOW_TI->
            Room2 = Room#room_ken{room_now_state = ?KEN_NOW_FANTI,room_begin_state = ?KEN_NOW_Null,begin_pos = -1,follow_pos = TurnPos1},
            mod_room:set_room(Room2,?KenFriend_Room_create),
            send_bet_result_msg(MemberList,Code1,MyPos,BetMoney,?KEN_GENZHU,TurnPos1,?KEN_NOW_FANTI,Code2);
        ?KEN_NOW_FANTI->
            IsAllTi = lists:all
            (
                fun(#room_member{is_ti = Ti }=_MyMember) ->
                    ?IF(Ti =:= true, true, false)
                end,
                NewMemberList
            ),


            case {TurnPos1 =:= StartPos, IsAllTi} of
                {true,true}->
                    Room2 = Room#room_ken{room_now_state = ?KEN_NOW_TI,room_begin_state = ?KEN_NOW_Null,begin_pos = -1,follow_pos = TurnPos1},
                    mod_room:set_room(Room2,?KenFriend_Room_create),
                    send_bet_result_msg(MemberList,Code1,MyPos,BetMoney,?KEN_GENZHU,TurnPos1,?KEN_NOW_TI,Code2);
                {true,false}->
                    mod_room:set_room(Room,?KenFriend_Room_create),
                    send_bet_result_msg(MemberList,Code1,MyPos,BetMoney,?KEN_GENZHU,-1,-1,Code2),
                    case NowStep of
                        ?KEN_STEP_ONE->
                            do_friend_step_two(Room,?KenFriend_Room_create);
                        ?KEN_STEP_TWO->
                            do_friend_step_two(Room,?KenFriend_Room_create);
                        ?KEN_STEP_THREE->
                            do_friend_step_two(Room,?KenFriend_Room_create)
                    end;

                _->
                    Room2 = Room#room_ken{room_now_state = ?KEN_NOW_FANTI,room_begin_state = ?KEN_NOW_Null,begin_pos = -1,follow_pos = TurnPos1},
                    mod_room:set_room(Room2,?KenFriend_Room_create),
                    send_bet_result_msg(MemberList,Code1,MyPos,BetMoney,?KEN_GENZHU,TurnPos1,?KEN_NOW_FANTI,Code2)
            end
    end,
    Player#player{user_id = Code1,unit_id = Code2}.

do_bet_koupai_state_logic(Player,Room,BetMoney)->
    #player{id = MyID} = Player,
    #room_ken{member = MemberList,table_money = TableMoney}=Room,
    [#room_member{pos = MyPos}=MyMember] = [X|| #room_member{id = MemberId} = X <-MemberList,MemberId =:= MyID],

    NewMember1 = MyMember#room_member{play_state = ?KEN_KOUPAI},
    NewMemberList = do_change_member(MyID,MemberList,NewMember1),

    NewMemberListNoKouPai = [X||#room_member{play_state = State} = X <-NewMemberList,State =/= ?KEN_KOUPAI],

    Code1 = wg_util:rand(1000,10000000),
    Code2 = wg_util:rand(1000,10000000),
    case length(NewMemberListNoKouPai) =:= 1 of
        true->
            [#room_member{id = Winid,score = OldWinScore,pos = WinPos}=WinMember] = NewMemberListNoKouPai,
            NewWinMember = WinMember#room_member{score = OldWinScore +  TableMoney},
            NewMemberList3 = do_change_member(Winid,NewMemberList,NewWinMember),
            Room2 = Room#room_ken{member = NewMemberList3,table_money = 0,room_now_state = ?KEN_NOW_Null,room_begin_state = ?KEN_NOW_Null,step = ?KEN_STEP_FOUR,start_pos = -1,begin_pos = -1,follow_pos = -1,step_begin_time = wg_util:now_sec()},
            mod_room:set_room(Room2,?KenFriend_Room_create),

            Msg = #gc_ken_bet_money
            {
                usr_id = Code1,
                pos   = MyPos,
                money = BetMoney,
                type = ?KEN_KOUPAI,
                next_type = ?KEN_Now_WIN,
                next_pos = WinPos,
                unit_id   = Code2
            }
            ,
            MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_bet_money}),

            mod_room:send_msg_broadcast(MemberList,MsgId, Msg);
        false->
%%            case TurnPos =:= OldBeginPos of
%%
%%            end,
            NextStartPos = get_next_begin_pos(NewMemberListNoKouPai,MyPos),

            Room2 = Room#room_ken{room_now_state = ?KEN_NOW_BET,room_begin_state = ?KEN_NOW_Null,start_pos = NextStartPos,begin_pos = -1,follow_pos = -1,member = NewMemberList},
            mod_room:set_room(Room2,?KenFriend_Room_create),

            Msg = #gc_ken_bet_money
            {
                usr_id = Code1,
                pos   = MyPos,
                money = BetMoney,
                type = ?KEN_KOUPAI,
                next_type = ?KEN_NOW_BET,
                next_pos = NextStartPos,
                unit_id   = Code2
            }
            ,
            MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_bet_money}),

            mod_room:send_msg_broadcast(MemberList,MsgId, Msg)
    end,


    Player#player{user_id = Code1,unit_id = Code2}.




send_bet_result_msg(MemberList,Code1,MyPos,BetMoney,Type,NextPos,NextType,Code2)->
    Msg = #gc_ken_bet_money
    {
        usr_id = Code1,
        pos   = MyPos,
        money = BetMoney,
        type = Type,
        next_type = NextType,
        next_pos = NextPos,
        unit_id   = Code2
    }
    ,
    MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_bet_money}),
    mod_room:send_msg_broadcast(MemberList,MsgId, Msg).


bet_state_logic(Player,Room,BetMoney)->
    case BetMoney =:= 0 of
        true->
            do_bet_koupai_state_logic(Player,Room,BetMoney);
        _->
            do_bet_state_logic(Player,Room,BetMoney)
    end.
do_bet_state_logic(Player,Room,BetMoney)->
    #player{id = MyID} = Player,
    #room_ken{member = MemberList,table_money = OldTableMoney}=Room,
    NewMemberList = [X||#room_member{play_state = State} = X <-MemberList,State =/= ?KEN_KOUPAI],

    [#room_member{pos = MyPos,score = OldScore}=MyMember] = [X|| #room_member{id = MemberId} = X <-NewMemberList,MemberId =:= MyID],

    #room_member{pos = MaxPos} = lists:last(NewMemberList),
    ?IF(MyPos  < MaxPos,NewOldTurn = MyPos,NewOldTurn = 0),
    [YourTurn|_]=[X||#room_member{pos = MemberPos} = X <-NewMemberList,MemberPos > NewOldTurn],
    #room_member{pos = TurnPos} = YourTurn,

    NewMember1 = MyMember#room_member{play_state = ?KEN_BET,score = OldScore - BetMoney},
    NewMemberList1 = do_change_member(MyID,MemberList,NewMember1),

    Room2 = Room#room_ken{table_money = OldTableMoney + BetMoney,room_now_state = ?KEN_NOW_FOLLOW,room_begin_state = ?KEN_NOW_BET,begin_pos = MyPos,follow_pos = TurnPos,member = NewMemberList1},
    mod_room:set_room(Room2,?KenFriend_Room_create),

    Code1 = wg_util:rand(1000,10000000),
    Code2 = wg_util:rand(1000,10000000),
    Msg = #gc_ken_bet_money
    {
        usr_id = Code1,
        pos   = MyPos,
        money = BetMoney,
        type = ?KEN_BET,
        next_type = ?KEN_NOW_FOLLOW,
        next_pos = TurnPos,
        unit_id   = Code2
    }
    ,
    MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_bet_money}),

    mod_room:send_msg_broadcast(MemberList,MsgId, Msg),
    Player#player{user_id = Code1,unit_id = Code2}.

do_follow_koupai_state_logic(Player,Room,BetMoney)->
    #player{id = MyID} = Player,
    #room_ken{member = MemberList,table_money = TableMoney,follow_pos = OldFollowPos,begin_pos = BeginPos}=Room,
    [#room_member{pos = MyPos}=MyMember] = [X|| #room_member{id = MemberId} = X <-MemberList,MemberId =:= MyID],

    NewMember1 = MyMember#room_member{play_state = ?KEN_KOUPAI},
    NewMemberList = do_change_member(MyID,MemberList,NewMember1),

    NewMemberListNoKouPai = [X||#room_member{play_state = State} = X <-NewMemberList,State =/= ?KEN_KOUPAI],

    Code1 = wg_util:rand(1000,10000000),
    Code2 = wg_util:rand(1000,10000000),
    case length(NewMemberListNoKouPai) =:= 1 of
        true->
            [#room_member{id = Winid,score = OldWinScore,pos = WinPos}=WinMember] = NewMemberListNoKouPai,
            NewWinMember = WinMember#room_member{score = OldWinScore +  TableMoney},
            NewMemberList3 = do_change_member(Winid,NewMemberList,NewWinMember),
            Room2 = Room#room_ken{member = NewMemberList3,table_money = 0,room_now_state = ?KEN_NOW_Null,room_begin_state = ?KEN_NOW_Null,step = ?KEN_STEP_FOUR,start_pos = -1,begin_pos = -1,follow_pos = -1,step_begin_time = wg_util:now_sec()},
            mod_room:set_room(Room2,?KenFriend_Room_create),

            Msg = #gc_ken_bet_money
            {
                usr_id = Code1,
                pos   = MyPos,
                money = BetMoney,
                type = ?KEN_KOUPAI,
                next_type = ?KEN_Now_WIN,
                next_pos = WinPos,
                unit_id   = Code2
            }
            ,
            MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_bet_money}),

            mod_room:send_msg_broadcast(MemberList,MsgId, Msg);
        false->
            #room_member{pos = MaxPos} = lists:last(NewMemberList),
            ?IF(OldFollowPos  < MaxPos,NewOldTurn1 = OldFollowPos,NewOldTurn1 = 0),
            [YourTurn1|_]=[X||#room_member{pos = MemberPos1} = X <-NewMemberListNoKouPai,MemberPos1 > NewOldTurn1],
            #room_member{pos = TurnPos1} = YourTurn1,

            case TurnPos1 =:= BeginPos of
                true->
                    do_next_turn(Room#room_ken{member = NewMemberList},Player,MyPos,BetMoney);
                false->
                    Room2 = Room#room_ken{follow_pos = TurnPos1,member = NewMemberList},
                    mod_room:set_room(Room2,?KenFriend_Room_create),
                    Msg = #gc_ken_bet_money
                    {
                        usr_id = Code1,
                        pos   = MyPos,
                        money = BetMoney,
                        type = ?KEN_KOUPAI,
                        next_type = ?KEN_NOW_FOLLOW,
                        next_pos = TurnPos1,
                        unit_id   = Code2
                    }
                    ,
                    MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_bet_money}),

                    mod_room:send_msg_broadcast(MemberList,MsgId, Msg)
            end
    end,
    Player#player{user_id = Code1,unit_id = Code2}.


do_reconnect_room_logic(Player)->


    #player{id = PlayerId,roomtype = RoomType,room_id = RoomId,gamenum = GameNum,moneyRank = MoneyRankData,winRank = WinRankData,loseRank = LostRankData} = Player,


    case mod_attr:check_reconnect(RoomType,RoomId,PlayerId,GameNum) of
        ?Need_Reconnect->
            %?INFO(?_U("需要重新连接:~p"), [RoomType]),
            Member = #room_member
            {
                id = PlayerId,
                state = ?PLAYER_STATE_NORMAL,
                score = GameNum,
                moneyRank = MoneyRankData,
                winRank = WinRankData,
                loseRank = LostRankData,
                roomtype = RoomType
            },
            Player2 = do_add_reconnect_room_member(RoomType,RoomId,Member,Player),
            Player2;
        ?No_Need_Reconnect->

            Msg = #gc_reconnect_failed
            {
                usr_id = ?E_OK
            },
            MsgId = mod_room:get_msg_id(gc_reconnect_failed),
            ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg),

            Player2 = Player,
            Player2
    end.
do_add_reconnect_room_member(RoomType,RoomId,Member,Player)->
    case RoomType of
        ?KenFriend_Room_create ->
            do_add_friend_reconnect_room_member1(RoomType,RoomId,Member,Player);
        ?KenFriend_Room_join ->
            do_add_friend_reconnect_room_member1(RoomType,RoomId,Member,Player);
        _->
            ok
    end.

do_add_friend_reconnect_room_member1(RoomType,RoomId,Member,Player)->
    case catch ken_room_mgr:reconnect_add_member(RoomId,Member) of
        {#room_ken{} = Room2, #room_member{}=Member2} ->

            ?INFO(?_U("re加入房间成功:~p"), [Member]),
            Code1 = wg_util:rand(1000,10000000),
            Code2 = wg_util:rand(1000,10000000),
            #room_ken{id = RoomId,step_begin_time = Step_Begin_Time,step = Step,left_game_time = LeftGameTime,person_num = MaxPerson,min_poker = MinPoker,min_money = MinMoney,max_bet = MaxBet,last_is_boom = LastIsBoom,isDouble = IsDouble,game_times = GameTimes,member = NewMember,roomstate = RoomState,follow_pos = CurPos,room_now_state = CurState,table_money = TableMoney,pork_list = PokerList} = Room2,
            #room_member{id = SelfId,pos = MyPos,pork_1 = MyPoker1,pork_2 = MyPoker2,pork_3 = MyPoker3,pork_4 = MyPoker4,pork_5 = MyPoker5,moneyRank = MoneyRankData,state = SelfState,play_state = SelfState1,score = SelfMoney} = Member2,
            #money_rank_data{name = SelfName,image = SelfHead} = MoneyRankData,
            %?INFO(?_U("加入房间成功:~p"), [NewMember]),
            Val = lists:map
            (
                fun(TempMember) ->
                    %?INFO(?_U("房间成员:~p"), [TempMember]),
                    #room_member{id = SendId,moneyRank = MoneyRankData1,pos = Pos,state = State,play_state = PlayState,score = Money,is_open_card = IsOpenCard,pork_1 = Poker1,pork_2 = Poker2,pork_3 = Poker3,pork_4 = Poker4,pork_5 = Poker5} = TempMember,
                    #money_rank_data{name = Name,image = Head} = MoneyRankData1,
                    {Name, Head,Pos,State,Money,SendId,PlayState,Poker3,Poker4,Poker5,Poker1,Poker2,IsOpenCard}

                end,
                NewMember

            ),

            [K1,K2,K3,K4,K5,K6,K7,K8,K9,K10,K11,K12,K13] = wg_lists:unzip_more(Val),
            ?INFO(?_U("re加入房间成功:~p"), [K4]),
            ?INFO(?_U("re加入房间成功:~p"), [K7]),
            ?IF(Step =:=?KEN_STEP_FOUR,Poker1List = K11,Poker1List = []),
            ?IF(Step =:=?KEN_STEP_FOUR,Poker2List = K12,Poker2List = []),
            Msg = #gc_join_ken_room
            {
                usr_id = Code1,
                room_key = RoomId,
                room_type = RoomType,
                person_num = MaxPerson,
                min_poker = MinPoker,
                max_bet = MaxBet,
                last_is_boom = LastIsBoom,
                is_double = IsDouble,
                min_money = MinMoney,
                game_times = GameTimes,

                my_pos = MyPos,
                cur_pos = CurPos,
                cur_state = CurState,
                table_money = TableMoney,
                card_num = length(PokerList),
                room_state = RoomState,
                room_step = Step,

                name_list = K1,
                head_list = K2,
                pos_list = K3,
                state_list = K4,
                state_list1 = K7,
                money_list = K5,
                poker_list1 = Poker1List,
                poker_list2 = Poker2List,
                poker_list3 = K8,
                poker_list4 = K9,
                poker_list5 = K10,
                poker1 = MyPoker1,
                poker2 = MyPoker2,
                open_list = K13,
                left_game_time = LeftGameTime,
                over_time = wg_util:now_sec() - Step_Begin_Time,
                unit_id = Code2
            },
            AddMsg = #gc_add_ken_member
            {
                name   = SelfName,
                head   = SelfHead,
                pos    = MyPos,
                state  = SelfState,
                state1 = SelfState1,
                money  = SelfMoney,
                poker3 = MyPoker3,
                poker4 = MyPoker4,
                poker5 = MyPoker5

            }
            ,
            MsgId = ?PROTO_CONVERT({?MODULE, gc_join_ken_room}),
            MsgId2 = ?PROTO_CONVERT({?MODULE, gc_add_ken_member}),
            lists:map
            (
                fun(IdToSend) ->
                    %?INFO(?_U("房间id:~p"), [IdToSend]),
                    ?IF( IdToSend=:= SelfId, ok = ?S2C_SEND_MERGE:player(IdToSend, MsgId, Msg),
                        ok = ?S2C_SEND_MERGE:player(IdToSend, MsgId2, AddMsg))

                end,
                K6

            ),

            case LeftGameTime >  GameTimes of
                true->
                    %?INFO(?_U("send over----:~p"), [1]),
                    game_over(RoomType,RoomId);
                false->
                    %?INFO(?_U("check----:~p"), [1]),
                    ok
            end,

            %?INFO(?_U("加入d房间成员状态:~p"), [SelfState]),
            Player2 = Player#player{room_id = RoomId,roomtype =RoomType,unit_id = Code2,user_id = Code1},
            Player2;
        %Room2;
        Error ->
            ?INFO(?_U("rejoin加入房间失败:~p"), [Error]),
            Player
    end.
do_create_friend_room(Player,MaxPerson,MinPoker,IsEveryBet,MaxBet,LastIsBoom,IsDouble,MinMoney,GameTimes,NeedCard)->

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
    ?INFO(?_U("创建填大坑房间成功1:~p"), [Member]),
    ?INFO(?_U("创建填大坑房间成功2:~p"), [MaxPerson]),
    ?INFO(?_U("创建填大坑房间成功3:~p"), [MinPoker]),
    ?INFO(?_U("创建填大坑房间成功4:~p"), [MaxBet]),
    ?INFO(?_U("创建填大坑房间成功5:~p"), [LastIsBoom]),
    ?INFO(?_U("创建填大坑房间成功6:~p"), [IsDouble]),
    ?INFO(?_U("创建填大坑房间成功7:~p"), [MinMoney]),
    ?INFO(?_U("创建填大坑房间成功8:~p"), [GameTimes]),
    ?INFO(?_U("创建填大坑房间成功9:~p"), [NeedCard]),
    case catch ken_room_mgr:create(Member,MaxPerson,MinPoker,MaxBet,LastIsBoom,IsDouble,MinMoney,GameTimes,NeedCard) of
        #room_ken{} = Room ->
            ?INFO(?_U("创建填大坑房间成功:~p"), [Room]),
            Code1 = wg_util:rand(1000,10000000),
            Code2 = wg_util:rand(1000,10000000),
            #room_ken{id = RoomId,step_begin_time = Step_Begin_Time,member = NewMember,roomstate = RoomState} = Room,
            [FirstMember|_] = NewMember,
            #room_member{id = PlayerId, moneyRank = MoneyRankData,pos = Pos,state = State,score = Money,play_state = State1} = FirstMember,
            #money_rank_data{name = Name,image = Head} = MoneyRankData,

            Msg = #gc_join_ken_room
            {
                usr_id = Code1,
                room_key = RoomId,
                room_type = RoomType,
                person_num = MaxPerson,
                min_poker = MinPoker,
                every_bet = IsEveryBet,
                max_bet = MaxBet,
                last_is_boom = LastIsBoom,
                is_double = IsDouble,
                min_money = MinMoney,
                game_times = GameTimes,

                my_pos = Pos,
                cur_pos = 0,
                cur_state = 0,
                table_money = 0,
                card_num = 0,
                room_state = RoomState,
                room_step = -1,

                name_list = [Name],
                head_list = [Head],
                pos_list = [Pos],
                state_list = [State],
                state_list1 = [State1],
                money_list = [Money],
                poker_list1 = [],
                poker_list2 = [],
                poker_list3 = [],
                poker_list4 = [],
                poker_list5 = [],
                poker1 = -1,
                poker2 = -1,
                left_game_time = 0,
                over_time = wg_util:now_sec() - Step_Begin_Time,
                unit_id = Code2
            },
            MsgId = ?PROTO_CONVERT({?MODULE, gc_join_ken_room}),
            ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg),
            Player2 = Player#player{room_id = RoomId,roomtype =RoomType, unit_id = Code2,user_id = Code1},
            Player2;
        Error ->
            ?INFO(?_U("创建填大坑房间成功:~p"), [Error]),
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
    ?INFO(?_U("加入填大坑房间成功:~p"), [1]),
    case catch ken_room_mgr:add_member(RoomId,Member) of
        {#room_ken{} = Room2, #room_member{}=Member2} ->
            ?INFO(?_U("加入房间成功:~p"), [Member]),
            Code1 = wg_util:rand(1000,10000000),
            Code2 = wg_util:rand(1000,10000000),
            #room_ken{id = RoomId,step_begin_time = Step_Begin_Time,step = Step,left_game_time = LeftGameTime,person_num = MaxPerson,min_poker = MinPoker,min_money = MinMoney,max_bet = MaxBet,last_is_boom = LastIsBoom,isDouble = IsDouble,game_times = GameTimes,member = NewMember,roomstate = RoomState,follow_pos = CurPos,room_now_state = CurState,table_money = TableMoney,pork_list = PokerList} = Room2,
            #room_member{id = SelfId,pos = MyPos,pork_3 = MyPoker3,pork_4 = MyPoker4,pork_5 = MyPoker5,moneyRank = MoneyRankData,state = SelfState,play_state = SelfState1,score = SelfMoney} = Member2,
            #money_rank_data{name = SelfName,image = SelfHead} = MoneyRankData,
            %?INFO(?_U("加入房间成功:~p"), [NewMember]),
            Val = lists:map
            (
                fun(TempMember) ->
                    %?INFO(?_U("房间成员:~p"), [TempMember]),
                    #room_member{id = SendId,moneyRank = MoneyRankData1,pos = Pos,state = State,play_state = PlayState,score = Money,is_open_card = IsOpenCard,pork_1 = Poker1,pork_2 = Poker2,pork_3 = Poker3,pork_4 = Poker4,pork_5 = Poker5} = TempMember,
                    #money_rank_data{name = Name,image = Head} = MoneyRankData1,
                    {Name, Head,Pos,State,Money,SendId,PlayState,Poker3,Poker4,Poker5,Poker1,Poker2,IsOpenCard}

                end,
                NewMember

            ),

            [K1,K2,K3,K4,K5,K6,K7,K8,K9,K10,K11,K12,K13] = wg_lists:unzip_more(Val),
            ?IF(Step =:=?KEN_STEP_FOUR,Poker1List = K11,Poker1List = []),
            ?IF(Step =:=?KEN_STEP_FOUR,Poker2List = K12,Poker2List = []),
            Msg = #gc_join_ken_room
            {
                usr_id = Code1,
                room_key = RoomId,
                room_type = RoomType,
                person_num = MaxPerson,
                min_poker = MinPoker,
                max_bet = MaxBet,
                last_is_boom = LastIsBoom,
                is_double = IsDouble,
                min_money = MinMoney,
                game_times = GameTimes,

                my_pos = MyPos,
                cur_pos = CurPos,
                cur_state = CurState,
                table_money = TableMoney,
                card_num = length(PokerList),
                room_state = RoomState,
                room_step = Step,

                name_list = K1,
                head_list = K2,
                pos_list = K3,
                state_list = K4,
                state_list1 = K7,
                money_list = K5,
                poker_list1 = Poker1List,
                poker_list2 = Poker2List,
                poker_list3 = K8,
                poker_list4 = K9,
                poker_list5 = K10,
                poker1 = -1,
                poker2 = -1,
                open_list = K13,
                left_game_time = LeftGameTime,
                over_time = wg_util:now_sec() - Step_Begin_Time,
                unit_id = Code2
            },
            AddMsg = #gc_add_ken_member
            {
                name   = SelfName,
                head   = SelfHead,
                pos    = MyPos,
                state  = SelfState,
                state1 = SelfState1,
                money  = SelfMoney,
                poker3 = MyPoker3,
                poker4 = MyPoker4,
                poker5 = MyPoker5

            }
            ,
            MsgId = ?PROTO_CONVERT({?MODULE, gc_join_ken_room}),
            MsgId2 = ?PROTO_CONVERT({?MODULE, gc_add_ken_member}),
            lists:map
            (
                fun(IdToSend) ->
                    %?INFO(?_U("房间id:~p"), [IdToSend]),
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

            MsgId = ?PROTO_CONVERT({mod_room, gc_friend_join_result}),
            ok = ?S2C_SEND_MERGE:player(PlayerId, MsgId, Msg),

            Player2 = Player#player{unit_id = Code2,user_id = Code1},
            Player2;
        _->
            ?INFO(?_U("加入好友房间未知错误:~p"), [1]),
            Player
    end.

do_create_change_ready_player_state(RoomType,PlayerId,RoomId,PlayerState,ChangIndex)->
    case catch mod_room:set_member_status(RoomType,PlayerId,RoomId,ChangIndex,PlayerState) of
        NewMemberList when is_list(NewMemberList)->
            %ß?INFO(?_U("修改玩家准备成功:~p"), [1]),
            [#room_member{pos = MyPos}=_MyMember] = [X|| #room_member{id = MemberId} = X <-NewMemberList,MemberId =:= PlayerId],


            Msg = #gc_ken_add_money
            {
                pos     =MyPos
            },
            MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_add_money}),
            mod_room:send_msg_broadcast(NewMemberList,MsgId, Msg),


            game_change_room_info(RoomId,RoomType);
        Error ->
            ?INFO(?_U("修改玩家准备状态失败:~p"), [Error])
    end.
change_friend_join_ready_player_state(RoomType,PlayerId,RoomId,PlayerState,ChangIndex)->
    case catch mod_room:set_member_status(RoomType,PlayerId,RoomId,ChangIndex,PlayerState) of
        NewMemberList when is_list(NewMemberList)->
            %ß?INFO(?_U("修改玩家准备成功:~p"), [1]),
            [#room_member{pos = MyPos}=_MyMember] = [X|| #room_member{id = MemberId} = X <-NewMemberList,MemberId =:= PlayerId],


            Msg = #gc_ken_add_money
            {
                pos     =MyPos
            },
            MsgId = ?PROTO_CONVERT({?MODULE, gc_ken_add_money}),
            mod_room:send_msg_broadcast(NewMemberList,MsgId, Msg);

        Error ->
            ?INFO(?_U("修改玩家准备状态失败:~p"), [Error])
    end.
%%修改房间属性
game_change_room_info(RoomId,RoomType)->

    case catch mod_room:get_room(RoomType,RoomId) of
        #room_ken{roomstate = RoomState}=Room ->
            ?IF(RoomState =:= ?ROOM_WAIT_READY,do_friend_game_start(Room,RoomType),ok);
        _->
            ok
    end.
get_poker_real_val(PokerNum)->

    IsBig20 = (PokerNum >= 20),
    IsBig16 = (PokerNum >= 16),
    IsBig12 = (PokerNum >= 12),
    IsBig8 = (PokerNum >= 8),
    IsBig4 = (PokerNum >= 4),
    IsBig0 = (PokerNum >= 0),

    case {IsBig20,IsBig16,IsBig12,IsBig8,IsBig4,IsBig0} of
        {true,_,_,_,_,_} ->
            9;
        {false,true,_,_,_,_} ->
            10;
        {false,false,true,_,_,_} ->
            11;
        {false,false,false,true,_,_} ->
            12;
        {false,false,false,false,true,_} ->
            13;
        {false,false,false,false,false,true} ->
            15;
        _->
            0
    end.

do_get_new_poker_list(MinPoker)->
    case MinPoker of
        9->
            shuffle(do_for(0,23));
        10->
            shuffle(do_for(0,19));
        11->
            shuffle(do_for(0,15))
    end.

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
do_friend_game_start(Room,RoomType)->
    %?INFO(?_U("好友房间开始逻辑:~p"), [1]),
    #room_ken{min_poker = MinPoker,max_bet = MaxBet,need_card = NeedCard,left_game_time = OldLeftTime,member = MemberList,min_money = MinMoney,is_delete_roomcard = IsDeleteRoomCard} = Room,

    PorkList = do_get_new_poker_list(MinPoker),
    PersonNum = length(MemberList),

    case PersonNum > 0 of
        true ->
            Func =
                fun(#room_member{pos = MyPos}= Member,{NewMemberList1,NewPokerList,CurPos,MaxPork3})->

                    {CardOne,CardTwo,CardThree,PorkLeft2} = deal_three_card(NewPokerList),
                    RealCardThreeVal = get_poker_real_val(CardThree),
                    ?IF(RealCardThreeVal > MaxPork3, NewMaxPoker3 = RealCardThreeVal, NewMaxPoker3 = MaxPork3),
                    ?IF(RealCardThreeVal > MaxPork3, NewCurPos = MyPos, NewCurPos = CurPos),

                    NewMember1 = Member#room_member{is_open_card = false,play_state = ?KEN_NULL,pork_1 = CardOne,pork_2 = CardTwo,pork_3 = CardThree,pork_4 = -1,pork_5 = -1,is_ti = false},
                    NewMemberList2 = NewMemberList1 ++ [NewMember1],

                    {NewMemberList2,PorkLeft2,NewCurPos,NewMaxPoker3}
                end,

            {NewMemberList,FinnalPokerLeft,FinalCurPos,FinalMax3Poker} = lists:foldl(Func, {[],PorkList,1,-1}, MemberList),
            ?INFO(?_U("剩余扑克:~p"), [FinnalPokerLeft]),
            ?INFO(?_U("发牌之后的玩家:~p"), [NewMemberList]),
            ?INFO(?_U("发牌之后的玩家:~p"), [FinalCurPos]),
            ?INFO(?_U("发牌之后的玩家:~p"), [FinalMax3Poker]),

            ?IF(IsDeleteRoomCard =:= false, DeleteCardNum = NeedCard ,DeleteCardNum = 0),

            Room2 = Room#room_ken{roomstate = ?ROOM_START,pork_list = FinnalPokerLeft,member = NewMemberList,table_money = MinMoney*PersonNum,left_game_time = OldLeftTime + 1,room_now_state = ?KEN_NOW_BET,room_begin_state = ?KEN_NOW_Null,step = ?KEN_STEP_ONE,start_pos = FinalCurPos,begin_pos = -1,follow_pos = FinalCurPos,is_delete_roomcard = true,step_begin_time = wg_util:now_sec()},
            min_base_chip(Room2,RoomType),


            Val = lists:map
            (
                fun(TempMember) ->
                    %?INFO(?_U("房间成员:~p"), [TempMember]),
                    #room_member{pork_3 = Poker3,pos =Pos} = TempMember,

                    {Poker3,Pos}

                end,
                NewMemberList

            ),

            [K1,K2] = wg_lists:unzip_more(Val),




            lists:map
            (
                fun(#room_member{id = SendId,pork_1 = Poker1,pork_2 = Poker2}=_MyMember) ->
                    %?INFO(?_U("发送玩家准备的id:~p"), [SendId]),
                    Req = {?START_GAME, FinalCurPos,?KEN_NOW_BET,MinMoney*PersonNum,OldLeftTime + 1,?ROOM_START,?KEN_STEP_ONE,length(FinnalPokerLeft),MaxBet,Poker1,Poker2,K1,K2,DeleteCardNum},
                    ok = player_server:s2s_cast(SendId, ?MODULE, Req)

                end,
                NewMemberList

            ),
            %?INFO(?_U("开始游戏修改房间信息:~p"), [Room2]),

            Room2;
        _ ->
            %?INFO(?_U("房间没有玩家:~p"), [1])
            ok
    end.


do_friend_step_two(Room,RoomType)->
    %?INFO(?_U("好友房间开始逻辑:~p"), [1]),
    #room_ken{member = MemberList,pork_list = PorkList} = Room,

    Func =
        fun(#room_member{pos = MyPos}= Member,{NewMemberList1,NewPokerList,CurPos,MaxPork3})->

            {CardFour,PorkLeft2} = deal_one_card(NewPokerList),
            RealCardFour = get_poker_real_val(CardFour),
            ?IF(RealCardFour > MaxPork3, NewMaxPoker3 = RealCardFour, NewMaxPoker3 = MaxPork3),
            ?IF(RealCardFour > MaxPork3, NewCurPos = MyPos, NewCurPos = CurPos),

            NewMember1 = Member#room_member{is_open_card = false,play_state = ?KEN_NULL,pork_4 = CardFour,pork_5 = -1,is_ti = false},
            NewMemberList2 = NewMemberList1 ++ [NewMember1],

            {NewMemberList2,PorkLeft2,NewCurPos,NewMaxPoker3}
        end,

    {NewMemberList,FinnalPokerLeft,FinalCurPos,FinalMax3Poker} = lists:foldl(Func, {[],PorkList,1,-1}, MemberList),
    ?INFO(?_U("第二阶段剩余扑克:~p"), [FinnalPokerLeft]),
    ?INFO(?_U("第二阶段发牌之后的玩家:~p"), [NewMemberList]),
    ?INFO(?_U("第二阶段发牌之后的玩家:~p"), [FinalCurPos]),
    ?INFO(?_U("第二阶段发牌之后的玩家:~p"), [FinalMax3Poker]),



    Room2 = Room#room_ken{pork_list = FinnalPokerLeft,member = NewMemberList,room_now_state = ?KEN_NOW_BET,room_begin_state = ?KEN_NOW_Null,step = ?KEN_STEP_TWO,start_pos = FinalCurPos,begin_pos = -1,follow_pos = FinalCurPos,step_begin_time = wg_util:now_sec()},
    mod_room:set_room(Room2,RoomType),


    Val = lists:map
    (
        fun(TempMember) ->
            %?INFO(?_U("房间成员:~p"), [TempMember]),
            #room_member{pork_4 = Poker4,pos =Pos} = TempMember,

            {Poker4,Pos}

        end,
        NewMemberList

    ),

    [K1,K2] = wg_lists:unzip_more(Val),




    lists:map
    (
        fun(#room_member{id = SendId,pork_1 = Poker1,pork_2 = Poker2}=_MyMember) ->
            %?INFO(?_U("发送玩家准备的id:~p"), [SendId]),
            Req = {?START_STEP_TWO, FinalCurPos,?KEN_NOW_BET,?KEN_STEP_TWO,length(FinnalPokerLeft),K1,K2},
            ok = player_server:s2s_cast(SendId, ?MODULE, Req)

        end,
        NewMemberList

    ),
    %?INFO(?_U("开始游戏修改房间信息:~p"), [Room2]),

    Room2.

do_friend_step_three(Room,RoomType)->
    %?INFO(?_U("好友房间开始逻辑:~p"), [1]),
    #room_ken{member = MemberList,pork_list = PorkList} = Room,
    case length(PorkList) =:= 0 of
        true->
            Func =
                fun(#room_member{}= Member,{NewMemberList1})->

                    NewMember1 = Member#room_member{is_open_card = true,is_ti = false},
                    NewMemberList2 = NewMemberList1 ++ [NewMember1],

                    {NewMemberList2}
                end,

            {NewMemberList} = lists:foldl(Func, {[]}, MemberList),
            Room2 = Room#room_ken{member = NewMemberList,table_money = 0,room_now_state = ?KEN_NOW_Null,room_begin_state = ?KEN_NOW_Null,step = ?KEN_STEP_FOUR,start_pos = -1,begin_pos = -1,follow_pos = -1,step_begin_time = wg_util:now_sec()},
            mod_room:set_room(Room2,?KenFriend_Room_create);
        _->
            Func =
                fun(#room_member{pos = MyPos}= Member,{NewMemberList1,NewPokerList,CurPos,MaxPork3})->

                    {CardFive,PorkLeft2} = deal_one_card(NewPokerList),
                    RealCardFive = get_poker_real_val(CardFive),
                    ?IF(RealCardFive > MaxPork3, NewMaxPoker3 = RealCardFive, NewMaxPoker3 = MaxPork3),
                    ?IF(RealCardFive > MaxPork3, NewCurPos = MyPos, NewCurPos = CurPos),

                    NewMember1 = Member#room_member{is_open_card = false,play_state = ?KEN_NULL,pork_5 = CardFive,is_ti = false},
                    NewMemberList2 = NewMemberList1 ++ [NewMember1],

                    {NewMemberList2,PorkLeft2,NewCurPos,NewMaxPoker3}
                end,

            {NewMemberList,FinnalPokerLeft,FinalCurPos,FinalMax3Poker} = lists:foldl(Func, {[],PorkList,1,-1}, MemberList),
            ?INFO(?_U("第3阶段剩余扑克:~p"), [FinnalPokerLeft]),
            ?INFO(?_U("第3阶段发牌之后的玩家:~p"), [NewMemberList]),
            ?INFO(?_U("第3阶段发牌之后的玩家:~p"), [FinalCurPos]),
            ?INFO(?_U("第3阶段发牌之后的玩家:~p"), [FinalMax3Poker]),



            Room2 = Room#room_ken{pork_list = FinnalPokerLeft,member = NewMemberList,room_now_state = ?KEN_NOW_BET,room_begin_state = ?KEN_NOW_Null,step = ?KEN_STEP_THREE,start_pos = FinalCurPos,begin_pos = -1,follow_pos = FinalCurPos,step_begin_time = wg_util:now_sec()},
            mod_room:set_room(Room2,RoomType),


            Val = lists:map
            (
                fun(TempMember) ->
                    %?INFO(?_U("房间成员:~p"), [TempMember]),
                    #room_member{pork_5 = Poker5,pos =Pos} = TempMember,

                    {Poker5,Pos}

                end,
                NewMemberList

            ),

            [K1,K2] = wg_lists:unzip_more(Val),




            lists:map
            (
                fun(#room_member{id = SendId}=_MyMember) ->
                    %?INFO(?_U("发送玩家准备的id:~p"), [SendId]),
                    Req = {?START_STEP_TWO, FinalCurPos,?KEN_NOW_BET,?KEN_STEP_THREE,length(FinnalPokerLeft),K1,K2},
                    ok = player_server:s2s_cast(SendId, ?MODULE, Req)

                end,
                NewMemberList

            ),
            %?INFO(?_U("开始游戏修改房间信息:~p"), [Room2]),

            Room2
    end.




get_next_begin_pos(MemberList,MainPos)->
    Func =
        fun(#room_member{pos = MyPos,pork_3 = Poker3,pork_4 = Poker4,pork_5 = Poker5}= _Member,{CurPos,MaxPork3})->


            Total = get_poker_real_val(Poker3) + get_poker_real_val(Poker4) + get_poker_real_val(Poker5),

            case {Total =:= MaxPork3,Total > MaxPork3} of
                {true,false}->
                    ?IF(MyPos < MainPos, TempPosTotal = MyPos + 5, TempPosTotal = MyPos),
                    ?IF(CurPos < MainPos, TempPosTotal1 = CurPos + 5, TempPosTotal1 = CurPos),
                    ?IF(TempPosTotal < TempPosTotal1, NewCurPos = MyPos, NewCurPos = CurPos),
                    NewMaxPoker3 = MaxPork3;
                {false,true}->
                    NewMaxPoker3 = Total,
                    NewCurPos = MyPos;
                _->
                    NewMaxPoker3 = MaxPork3,
                    NewCurPos = CurPos

            end,

            {NewCurPos,NewMaxPoker3}
        end,

    {FinalCurPos,_FinalMax3Poker} = lists:foldl(Func, {1,-1}, MemberList),
    FinalCurPos.
min_base_chip(Room,RoomType)->
    #room_ken{member = Member,min_money = MinMoney} = Room,
    ?INFO(?_U("所有人变为准备----:~p"), [Member]),
    Val = lists:map
    (
        fun(TempMember) ->
            #room_member{score = OldScore} = TempMember,
            ?INFO(?_U("所有人变为准备:~p"), [TempMember]),
            Member2 = TempMember#room_member{score = OldScore-MinMoney},
            %?INFO(?_U("所有人变为准备:~p"), [Member2]),
            Member2
        end,
        Member
    ),
    Room2 = Room#room_ken{member = Val},
    %?INFO(?_U("新的房间成员列表:~p"), [Val]),
    mod_room:set_room(Room2,RoomType),
    Room2.

do_game_next_game(Room,RoomType)->
    ok.
%%修改玩家成员信息
do_change_member(PlayerId,MemberList,ChangeMember) ->

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
    NewMemberList.

deal_three_card(PorkList)->
    [CardOne|PorkLeft] = PorkList,
    [CardTwo|PorkLeft1] = PorkLeft,
    [CardThree|PorkLeft2] = PorkLeft1,
    {CardOne,CardTwo,CardThree,PorkLeft2}.

deal_one_card(PorkList)->
    [CardOne|PorkLeft] = PorkList,

    {CardOne,PorkLeft}.

%%检验函数
check_money_limit(RoomType,Player)->
    #player{money = _Money,card_room = RoomCardNum} = Player,
    case RoomType of
        ?KenFriend_Room_create ->
            Res = RoomCardNum > 0;
        ?KenFriend_Room_join ->
            Res = true;
        _ ->
            Res = false
    end,
    Res.

friend_room_is_can_start(Player)->
    #player{roomtype = RoomType,room_id = RoomId,id = PlayerId} = Player,
    case catch mod_room:get_room(RoomType,RoomId) of
        #room_ken{member = PlayerList,roomstate = RoomState}=_Room ->
            case RoomState =:= ?ROOM_WAIT_READY of
                true->
                    TempList = [X|| #room_member{id = MemberId} = X <-PlayerList,MemberId /= PlayerId],
                    case length(TempList) > 0 of
                        true->
                            lists:all
                            (
                                fun(#room_member{state = State }=_MyMember) ->
                                    ?IF(State =:= ?PLAYER_Ready, true, false)
                                end,
                                TempList
                            );
                        _->
                            ?No_Enough_Player
                    end;

                false->
                    false
            end;
        _->
            room_no_find
    end.

game_over(RoomType,RoomId)->
    case catch mod_room:get_room(RoomType,RoomId) of
        #room_ken{} = Room ->
            Req = {?FRIEND_GAME_OVER,[],[],[],[],[]},

            Room2 = do_send_game_over_msg(Room,Req),

            do_check_delete_room(Room2);
        _->
            ok
    end.

do_send_game_over_msg(Room,Req)->
    #room_ken{member = MemberList} = Room,
    Val = lists:map
    (
        fun(#room_member{id = SendId,state = State}=MyMember) ->
            %?INFO(?_U("发送玩家准备的id:~p"), [IsGet]),
            case State =:= ?PLAYER_OFFlINE of
                true->
                    MyMember;
                _->
                    ok = player_server:s2s_cast(SendId,mod_room, Req),
                    MyMember#room_member{isGetGameResult =  true}
            end

        end,
        MemberList

    ),
    Room2 = Room#room_ken{member = Val,game_over_msg_send = true},
    %?INFO(?_U("结束新的房间成员列表:~p"), [Val]),
    ken_room_mgr:set(Room2),
    Room2.

do_check_delete_room(Room)->
    #room_ken{id = RoomId,member = NewMember} = Room,

    %?INFO(?_U("checkRoom:~p"), [NewList]),
    IsDelete = lists:all
    (
        fun(#room_member{isGetGameResult = State }=_MyMember) ->
            ?IF(State =:= true, true, false)
        end,
        NewMember
    ),
    ?IF(IsDelete =:= true,ken_room_mgr:delete(RoomId),ok).