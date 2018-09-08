%%%----------------------------------------------------------------------
%%%
%%% @author
%%% @doc  关于f
%%% @end
%%%
%%%----------------------------------------------------------------------
-ifndef(ROOM_HRL).
-define(ROOM_HRL, true).


-define(TEAM_CREATE, 16#ffffffffffffffff).
-define(START_GAME, start_game).
-define(START_STEP_TWO, start_step_two).
-define(START_STEP_THREE, start_step_three).
-define(FRIEND_GAME_OVER, friend_game_over).
-define(Reset_GAME, reset_game).
-define(Win_Video, win_money_video).
-define(Lose_Video, lose_money_video).
-define(Net_Error_Quit_Room, net_error_quit_room).
-define(DELAY_CALC_EVENT(Fun), {'mod_room_delay_calc_event', Fun}).
-define(QUIT_FRIEN_GAME(Fun,Player), {'mod_room_delay_quit_friend_game', Fun,Player}).
-define(GiveCard, give_card).

%%输赢结果类型
-define(Game_Lose, 1).
-define(Game_Lose_Double, 2).
-define(Game_Win, 3).
-define(Game_None, 4).
%%房间类型
-define(New_Room, 1).
-define(Ordinary_Room, 2).
-define(Master_Room, 3).
-define(God_Room, 4).
-define(Friend_Room_create, 5).
-define(Reconnect_Room, 6).
-define(Friend_Room_join, 7).

-define(KenFriend_Room_create, 9).
-define(KenFriend_Room_join, 10).

%%好友房间开始返回结果
-define(Other_No_Prepare, 1).
-define(No_Enough_Player, 2).
%%排行旁类型
-define(Money_Rank, 1).
-define(Win_Rank, 2).
-define(Lose_Rank, 3).

%% 房间最大人数
-define(ROOM_MEMBER_MAX, 7).
-define(POKER_NUM_MAX, 15).
%填坑
-define(ROOM_KEN_MEMBER_MAX, 5).

-define(Rank_list_max, 50).

%%玩家状态
-define(PLAYER_STATE_NORMAL,  0).  % 进入房间并没有准备
-define(PLAYER_OBSERVER, 3).  % 新加入游戏,观看
-define(PLAYER_Ready, 4).  % 新加入游戏,观看
-define(PLAYER_OFFlINE, 5).
-define(PLAYER_FOLD, 6).

%% 填坑个人状态
-define(KEN_NULL,  0).  % 进入房间并没有准备
-define(KEN_BET, 1).  % 新加入游戏,观看
-define(KEN_QIJIAO, 2).  % 新加入游戏,观看
-define(KEN_FANTI, 3).
-define(KEN_GENZHU, 4).
-define(KEN_KOUPAI, 5).


%%房间当前操作
-define(KEN_NOW_BET,  1).
-define(KEN_NOW_TI, 2).
-define(KEN_NOW_FANTI, 3).
-define(KEN_NOW_FOLLOW, 4).
-define(KEN_NOW_Null, 5).
-define(KEN_Now_WIN, 6).

%%房间当前操作
-define(KEN_STEP_ONE,  0).
-define(KEN_STEP_TWO, 1).
-define(KEN_STEP_THREE, 2).
-define(KEN_STEP_FOUR, 3).
-define(KEN_STEP_NULL, 4).
%%房间状态
-define(ROOM_START,  1).      %    房间开始游戏
-define(ROOM_WAIT_READY, 0).  %   房间等待玩家准备


-define(ROOM_ALL_READ,  0).
-define(ROOM_NOT_ALL_READ,  1).
%%房间无效id
-define(NULL_ROOMID, -1).
%%错误码
-define(Room_No_Find,  0).      %    房间开始游戏
-define(Already_In_Room, 1).  %   房间等待玩家准备
-define(Room_Full, 2).   %  房间等待玩家加入
-define(Member_No_Find,  3).      %    房间开始游戏
-define(Player_Pos_Not_Find,  4).      %    房间开始游戏
-define(Money_JoinRoom_Error,5).      %    房间开始游戏
-define(Friend_Room_Already_Start_Error,6).      %    房间开始游戏
%%时间信息
-define(RoomPrepareTime,  15000).      %    玩家准备时间
-define(FriendRoomDelayQuit,  10000).      %    玩家准备时间
-define(RoomTurnTime,  15000).      %    玩家准备时间
-define(QuikpokerTime,  1).      %    玩家棋牌时间
-define(PlayerBetDelay,  3700).      %    玩家棋牌时间

%%退出房间类型
-define(QUIT_NOT_PREPARE,  1).      %    玩家没有准备被踢出
-define(QUIT_BY_SELF,      2).      %    玩家自己离开
-define(QUIT_NET_ERROR,    3).      %    玩家网络断网
-define(QUIT_NO_MONEY,     4).      %    玩家金钱不够提出
-define(QUIT_Much_MONEY,   5).      %    玩家金钱不够提出

%%下底金钱数
-define(NewRoom_MinMoney_di,  100).
-define(OrdinaryRoom_MinMoney_di,      1000).
-define(MasterRoom_MinMoney_di,    10000).

-define(NewRoom_MinMoney,  1000).
-define(OrdinaryRoom_MinMoney,      10000).
-define(MasterRoom_MinMoney,    100000).

-define(Max_NewRoom,  50000).
-define(Max_OrdinaryRoom,      200000).

%%断线重新连接
-define(Need_Reconnect,  1).
-define(No_Need_Reconnect,0).

%%回放类型
-define(Video_Win_Money,  1).
-define(Video_lose_Money,0).
%% 信息
-record(room, {
        id = ?NULL_ROOMID,            % 房间id
        leader,        % 房主id
        gameNum = 0,
        turn,
        keepnum = 0,
        table_money = 0,
        cardone = 0,
        cardtwo = 0,
        min_money = ?NewRoom_MinMoney_di,
        max_bet = 0,
        isDouble = false,
        game_start_time = -1,
        is_delete_roomcard = false,
        game_over = false,
        game_over_msg_send = false,
        roomstate = ?ROOM_WAIT_READY,     % 房间状态
        pork_list = []  ,  % 扑克列表
        member = [] ,   % 房间成员
        member_cache = [],
        shareMoneyPos = [],
        need_card = 2,
        game_time = 600,
        turn_begin_time = 0,
        change_turn_time = 20
}).


-record(room_ken, {
        id = ?NULL_ROOMID,            % 房间id
        person_num = 4,
        min_poker = 10,
        every_bet = true,
        table_money = 0,
        min_money = 1,
        max_bet = 5,                    %可变
        isDouble = false,
        last_is_boom = true,
        game_times = 30,
        left_game_time = 0,             %可变
        is_delete_roomcard = false,     %可变
        game_over = false,              %可变
        game_over_msg_send = false,     %可变
        roomstate = ?ROOM_WAIT_READY,     % 房间状态
        room_now_state = ?KEN_NOW_Null,   %当前点的状态
        room_begin_state = ?KEN_NOW_Null,  %发起点的类型
        step = ?KEN_STEP_NULL,
        start_pos = -1,                   %最开始的点
        begin_pos = -1,                   %发动起点
        follow_pos = -1,    %当前pos
        pork_list = []  ,  % 扑克列表
        member = [] ,   % 房间成员
        need_card = 2,
        chip_one = 1,
        chip_two = 3,
        chip_three = 5,
        step_begin_time = 0
}).


-record(room_free, {
        id,
        roomlist = []    % 房间成员
}).
-record(robot_free, {
        id,
        robot_list = []    % 房间成员
}).
-record(rank_list, {
        id,
        member = []    ,    % 排行榜成员
        member_win = [],   % 排行一次赢得最多金币
        member_lost =[]    % 排行一次赢得最多金币
}).


-define(CHANGE_STATE,  0).
-define(CHANGE_MONEY_Rand_Data, 1).
-define(CHANGE_WIN_RANK_DATA, 2).
-define(CHANGE_LOSE_DATE,3).


-record(room_member, {
        pos,            % 玩家在队伍中的编号
        id,             % 玩家id
        state = ?PLAYER_STATE_NORMAL, % 在线状态
        play_state = ?KEN_NULL, %需要改变
        score = 0,
        moneyRank = [],
        winRank = [],
        loseRank = [],
        pork_1 = -1,%需要改变
        pork_2 = -1,%需要改变
        pork_3 = -1,%需要改变
        pork_4 = -1,%需要改变
        pork_5 = -1,%需要改变
        roomtype = -1,
        isGetGameResult = false,
        is_open_card = false,%需要改变
        is_ti = false%需要改变
    }).

-record(win_rank_data, {
        id,
        cardone,
        cardtwo,
        mypos,
        name_list = [],
        image_list = [],
        money_list = [],
        pos_list = [],
        table_money,
        poker_num,
        money
}).

-record(money_rank_data, {
        id,
        name,
        image,
        money
}).

-record(lose_rank_data, {
        id,
        cardone,
        cardtwo,
        mypos,
        name_list = [],
        image_list = [],
        money_list = [],
        pos_list = [],
        table_money,
        poker_num,
        money
}).
-type team() :: #room{}.

-endif.
