%%%-------------------------------------------------------------------
%%% @author fx
%%% @copyright (C) 2015, <COMPANY>
%%% @doc 邮件逻辑模块
%%%
%%% @end
%%% Created : 07. 七月 2015 下午2:18
%%%-------------------------------------------------------------------
-module(mod_attr).
-author("fx").
-include("wg.hrl").
-include("game.hrl").
-include("../src/proto/proto.hrl").
-include("pbmessage_pb.hrl").
-include("lang.hrl").
-include("sys_daily_reward.hrl").
-include("room.hrl").
%% API
-behaviour(gen_mod).
-export([start/0]).
%% gen_mod回调函数
-export([i/1, p/1, init/1, terminate/0,
    init_player/2, gather_player/1, terminate_player/1,
    handle_c2s/3, handle_timeout/2, handle_s2s_call/2, handle_s2s_cast/2]).
-export([check_give_coins/1,check_reconnect/4]).


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

init_player(#player{id = PlayerId,giveTimes = Times, lastGiveTime = LastRegisterTime, money = Money} = Player, ?NEW) ->

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


handle_s2s_cast({recv_mail, _}, #player{} = Player) ->

    %do_receive_mail(Player, SenderType, SenderGuid, MailUpdate),

    {ok, Player}.

handle_c2s(#cg_req_money{name = Name,image_url = Image } = _ReqMoney,_MsgId, #player{id = PlayerId,moneyRank = MoneyRank} = Player) ->
    ?IF(MoneyRank =:= [], Player1 = do_init_rank(Player,Name,Image),Player1 = Player),
    Player2 = check_give_coins(Player1),
    player_server:set_old_rank(PlayerId),
    {ok, Player2}.

do_init_rank(Player,Name,Image)->
    %?INFO(?_U("初始化排行榜玩家名字:~p"), [Name]),
    %?INFO(?_U("初始化排行榜玩家头像:~p"), [Image]),
    Player1 = do_init_money_rand(Player,Name,Image),
    Player2 = do_init_lose_rand(Player1),
    Player3 = do_init_win_rand(Player2),

    %?INFO(?_U("初始化排行榜后的玩家:~p"), [Player3]),
    Player3.
%%初始化玩家排行榜数据
do_init_money_rand(#player{id = PlayerId,money = Money} = Player,Name,Image)->
    case catch db_rank_money:load(PlayerId) of
        #money_rank_data{} = MoneyData ->
            %?INFO(?_U("金钱排行榜存在:~p"), [MoneyData]),
            Player1 = Player#player{moneyRank = MoneyData#money_rank_data{id = PlayerId,name = Name,image = Image,money = Money}};
        _->
            %?INFO(?_U("金钱排行榜不存在,需要创建:~p"), [1]),
            Res = #money_rank_data{id = PlayerId,name = Name,image = Image,money = Money},
            db_rank_money:create(Res),
            Player1 = Player#player{moneyRank = Res}
    end,
    Player1.

do_init_lose_rand(#player{id = PlayerId,money = Money} = Player)->
    case catch db_rank_lose_money:load(PlayerId) of
        #lose_rank_data{} = LoseData ->
            %?INFO(?_U("一次输排行榜存在:~p"), [LoseData]),
            Player1 = Player#player{loseRank = LoseData};
        _->
            %?INFO(?_U("一次输排行榜不存在,需要创建:~p"), [1]),

            Res = #lose_rank_data{
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
            db_rank_lose_money:create(Res),
            Player1 = Player#player{loseRank = Res}
    end,
    Player1.

do_init_win_rand(#player{id = PlayerId,money = Money} = Player)->
    case catch db_rank_win_money:load(PlayerId) of
        #win_rank_data{} = WinData ->
            %?INFO(?_U("一次赢排行榜存在:~p"), [WinData]),
            Player1 = Player#player{winRank = WinData};
        _->
            %?INFO(?_U("一次赢排行榜不存在,需要创建:~p"), [1]),

            Res = #win_rank_data{
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
            db_rank_win_money:create(Res),
            Player1 = Player#player{winRank = Res}
    end,
    Player1.

check_give_coins(#player{id = PlayerId,roomtype = RoomType,gamenum = GameNum,room_id = RoomId,lastGiveTime = LastRegisterTime, money = Money,moneyRank = MoneyRank,winRank = WinRank,loseRank = LoseRank,card_room = RoomCardNum} = Player) ->
    case Money < ?CONF(money_min,1000) of
        % 被邀请者已经在队伍里
        true->
            IsCurDay = wg_util:is_time_in_one_day(LastRegisterTime),
            Player1 = ?IF(IsCurDay,do_give_mony(Player),do_give_mony(Player#player{giveTimes =0,lastGiveTime = wg_util:now_sec()}));
        _->
            %?INFO(?_U("金币足够,玩家id:~p 发送属性信息"), [PlayerId]),
            Code1 = wg_util:rand(1000,10000000),
            Code2 = wg_util:rand(1000,10000000),
            Player1 = Player#player{user_id = Code1,unit_id = Code2},
            #win_rank_data{money = FirstMoney} = WinRank,
            #lose_rank_data{money = LoseMoney} = LoseRank,
            Msg = #gc_give_money
            {
                usr_id = Code1,
                money = Money,
                addmoney = 0,
                unit_id = Code2,
                moneyrank = rank:get_money_rank(MoneyRank),
                firstmoney = FirstMoney,
                firstrank = rank:get_win_rank(WinRank),
                losemoney = LoseMoney,
                loserank = rank:get_lose_rank(LoseRank),
                times = 0,
                reconnect = check_reconnect(RoomType,RoomId,PlayerId,GameNum),
                room_type = RoomType,
                table_money = get_table_money(RoomType,RoomId),
                room_card = RoomCardNum
            },
            MsgId = ?PROTO_CONVERT({?MODULE, gc_give_money}),
            ok = ?S2C_SEND_PUSH:player(PlayerId, MsgId, Msg),
            ok
    end ,
    Player1.
do_give_mony(#player{id = PlayerId,roomtype = RoomType,gamenum = GameNum,room_id = RoomId,giveTimes = Times,money = Money,moneyRank = MoneyRank,winRank = WinRank,loseRank = LoseRank,card_room = RoomCardNum}= Player)->
    #win_rank_data{money = FirstMoney} = WinRank,
    #lose_rank_data{money = LoseMoney} = LoseRank,
    case Times < ?CONF(give_times,4) of
        % 被邀请者已经在队伍里
        true->
            %?DEBUG(?_U("金币不足,曾送充足发送数据属性:")),
            Code1 = wg_util:rand(1000,10000000),
            Code2 = wg_util:rand(1000,10000000),
            MoneyRank2 = MoneyRank#money_rank_data{money = Money + 5000},
            Player1 = Player#player{money = Money + 5000,moneyRank = MoneyRank2,giveTimes = Times + 1,user_id = Code1,unit_id = Code2},
            Msg = #gc_give_money
            {
                usr_id = Code1,
                money = Money + 5000,
                addmoney = 5000,
                unit_id = Code2,
                moneyrank = rank:get_money_rank(MoneyRank2),
                firstmoney = FirstMoney,
                firstrank = rank:get_win_rank(WinRank),
                losemoney = LoseMoney,
                loserank = rank:get_lose_rank(LoseRank),
                times = 3-Times,
                reconnect = check_reconnect(RoomType,RoomId,PlayerId,GameNum),
                room_type = RoomType,
                table_money = get_table_money(RoomType,RoomId),
                room_card = RoomCardNum
            },
            MsgId = ?PROTO_CONVERT({?MODULE, gc_give_money}),
            ok = ?S2C_SEND_PUSH:player(PlayerId, MsgId, Msg);
        _->
            %?DEBUG(?_U("金币不足,曾送次数已经到:")),
            Code1 = wg_util:rand(1000,10000000),
            Code2 = wg_util:rand(1000,10000000),

            Msg = #gc_give_money
            {
                usr_id = Code1,
                money = Money,
                addmoney = 0,
                unit_id = Code2,
                moneyrank = rank:get_money_rank(MoneyRank),
                firstmoney = FirstMoney,
                firstrank = rank:get_win_rank(WinRank),
                losemoney = LoseMoney,
                loserank = rank:get_lose_rank(LoseRank),
                times = 0,
                reconnect = check_reconnect(RoomType,RoomId,PlayerId,GameNum),
                room_type = RoomType,
                table_money = get_table_money(RoomType,RoomId),
                room_card = RoomCardNum
            },
            MsgId = ?PROTO_CONVERT({?MODULE, gc_give_money}),
            ok = ?S2C_SEND_PUSH:player(PlayerId, MsgId, Msg),
            Player1 = Player#player{user_id = Code1,unit_id = Code2}
    end ,
    Player1.

get_table_money(RoomType,RoomId)->
    Reply = case RoomType of
                ?New_Room ->
                    room_newplayer_mgr:get(RoomId);
                ?Ordinary_Room ->
                    room_ordinary_mgr:get(RoomId);
                ?Master_Room ->
                    room_master_mgr:get(RoomId);
                _ ->
                    nofound_room
            end,

    case Reply of
        #room{table_money = TableMoney} = _Room->
            TableMoney;
        _->
            0
    end.
check_reconnect(RoomType,RoomId,MemberId,GameNum)->

    Reply = case RoomType of
                ?New_Room ->
                    room_newplayer_mgr:check_reconnect(RoomId,MemberId,GameNum);
                ?Ordinary_Room ->
                    room_ordinary_mgr:check_reconnect(RoomId,MemberId,GameNum);
                ?Master_Room ->
                    room_master_mgr:check_reconnect(RoomId,MemberId,GameNum);
                ?Friend_Room_create ->
                    room_friend_mgr:check_reconnect(RoomId,MemberId,GameNum);
                ?Friend_Room_join ->
                    room_friend_mgr:check_reconnect(RoomId,MemberId,GameNum);
                ?KenFriend_Room_create ->
                    ken_room_mgr:check_reconnect(RoomId,MemberId,GameNum);
                ?KenFriend_Room_join ->
                    ken_room_mgr:check_reconnect(RoomId,MemberId,GameNum);
                _ ->
                    %?INFO(?_U("更新全部room,信息失败:~p"), [RoomType])
                    nofound_room
            end,

    case Reply of
        ?Need_Reconnect->
            ?Need_Reconnect;
        _->
            ?No_Need_Reconnect
    end.

