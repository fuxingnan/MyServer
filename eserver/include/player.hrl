%%%----------------------------------------------------------------------
%%%
%%% @author: kebo
%%% @date: 2012-11-03
%%% @doc 游戏角色的相关定义
%%%
%%%----------------------------------------------------------------------
-ifndef(PLAYER_HRL).
-define(PLAYER_HRL, true).

%% 游戏包类型
-define(WORDCANDY,        1).
-define(WORDSEARCH,       2).
-define(WORDSEARCH_IOS,   3).
-define(WORDSEARCH_OTHER, 4).
-define(WORDCANDY_NEW,    5).

%% 复活类型
-define(REVIVE_TYPE_NAUTOBUY, 1).       % 原地复活(当前地图口)
-define(REVIVE_TYPE_SAFE,     2).       % 安全区复活(复活点洱海)
-define(REVIVE_TYPE_AUTOBUY,  3).       % 原地复活(消耗元宝)
-define(REVIVE_TYPE_COUNTER, 'relive_counter').   % 原地复活(消耗元宝)计算器

%% 玩家PK模式
-define(PK_MODE_MIN, 1).        % 最小值

-define(PK_MODE_PEACE, 1).      % 和平
-define(PK_MODE_PK, 2).         % 杀戮
-define(PK_MODE_REALM, 3).      % 阵营(废弃)
-define(PK_MODE_GUILD, 4).   % 公会(废弃)
-define(PK_MODE_TEAM, 5).       % 组队(废弃)
-define(PK_MODE_ALL, 6).        % 所有的模式

-define(PK_MODE_MAX, 2).        % 最大值
-define(PKMODE_PEACE_CD, 1800). % 玩家pk模式切换回和平模式的cd时间(这里是秒)

%% 玩家打坐模式
-define(MEDITATE_NONE, 0).    % 不在打坐
-define(MEDITATE_SINGLE, 1).  % 单人打坐
-define(MEDITATE_DOUBLE, 2).  % 双人打坐

%% 玩家交易
-define(PLAYER_TRADE_STATUS, "player_trade_status").
-define(PLAYER_TRADE_WITH_STATUS, "player_trade_with_status").
%% 存储玩家发送过的交易请求(作为主动交易方)
-define(PLAYER_TRADE_OUT, "player_trade_out").
%% 存储玩家收到的交易请求(作为被动交易方)
-define(PLAYER_TRADE_IN, "player_trade_in").
%% 玩家当前交易进行的对象
-define(PLAYER_TRADE_WITH, "player_trade_with").

-define(TRADE_GOODS_OUT, "trade_goods_out").
-define(TRADE_GOODS_IN, "trade_goods_in").
-define(TRADE_MONEY_OUT, "trade_money_out").
-define(TRADE_MONEY_IN, "trade_money_in").


%% 玩家交易状态
-define(TRADE_STATUS_TRADING, 0).
-define(TRADE_STATUS_LOCK, 1).   %锁定
-define(TRADE_STATUS_COMMIT, 2). %提交
-define(TRADE_STATUS_COMPLETE, 3).%完成(双方都已提交)
-define(TRADE_STATUS_FAIL, 4).

%% 玩家速度
-define(PLAYER_SPEED_DEFAULT, 4).      % 玩家默认每秒走4个格子
-define(PLAYER_SPEED_TIME_BASE, 1000). % 计算玩家每走4格需要时间的基准1000ms
-define(PLAYER_SPEED_STEP_TIME_BASE, 240).  % 玩家走一个格子的基准时间

%% 玩家活力值相关
-ifdef(TEST).
-define(PLAYER_VIGOR_RECOVER_ONLINE, 15).	% 在线恢复一点活力所需时间(秒)
-define(PLAYER_VIGOR_RECOVER_OFFLINE, 30).	% 离线恢复一点活力所需时间(秒)
-else.
-define(PLAYER_VIGOR_RECOVER_ONLINE, 300).	% 在线恢复一点活力所需时间(秒)
-define(PLAYER_VIGOR_RECOVER_OFFLINE, 300).	% 离线恢复一点活力所需时间(秒)
-endif.

-define(PLAYER_VIGOR_MAX, 1000).	% 活力值上限
-define(PLAYER_VIGOR_INIT, 900).	% 活力值初始值

%% 玩家的怒值相关
-define(PLAYER_FURY_FULL, 10000).   % 怒值满值

%% 玩家进程启动时数据来源类型
-define(NEW, new).          % 新登录
-define(MIGRATE, migrate).  % 数据迁移
%% 玩家血池补充血量或者魔法或宠物血量
-define(BLOOD_POOL_HP, 1).      % 血池补充人物血量
-define(BLOOD_POOL_MP, 2).      % 血池补充人物魔法值
-define(BLOOD_POOL_PET_HP, 3).  % 血池补充宠物血量
-define(BLOOD_POOL_FURY, 4).    % 血池补充人物怒气

-define(MAX_BLOOD_POOL_HP, 30000000).           % 血池血量最大值
-define(MAX_BLOOD_POOL_MP, 30000000).           % 血池魔法最大值
-define(MAX_BLOOD_POOL_PET_HP, 30000000).       % 血池宠物血量最大值
-define(MAX_BLOOD_POOL_FURY, 30000000).         % 血池怒气最大值


-define(MAX_SERVER_VERSION, 30000000).           % 版本最大id

%机器人类型
-define(New_Room_Robot, 1).
-define(Ordinary_Room_Robot,2).
-define(Mastr_Room_Robot,3).

-define(Robot_Wait, 1).
-define(Robot_Play,2).


-record(robot, {
        is_robot = false,
        id,
        type,
        state,
        my_pos = -1,
        loop_time = 0,
        join_room_time = 0,
        force_join_time = 0,
        prepare_time = 0,
        bet_money_time = 0,
        bet_money_check_quik = 0
}).

%% 玩家基本信息(修改数据库时，需要修改此record)
-record(player, {
        room_id = -1,
        id,
        user_id = 0,
        unit_id = 0,
        giveTimes = 0,
        lastGiveTime = 0,
        money,
        firstmoney = 0,
        cardone = -1,
        cardtwo = -1,
        gamenum = -1,
        roomtype = -1,
        card_room = 0,
        client,
        pid,
        status,
        moneyRank = [],
        winRank = [],
        loseRank = [],
        robot = #robot{is_robot = false}
}).
-type player() :: #player{}.




-record(player_db, {
        id,
        room_id,
        user_id,
        unit_id,
        giveTimes,
        lastGiveTime,
        money,
        firstmoney,
        cardone,
        cardtwo,
        gamenum,
        roomtype,
        card_room
}).

%% 玩家私有数据(不需要同步到player_mgr和world_online中)
%% 新开发功能时,尽量将私有数据放置与此,防止#player过分庞大
-record(player_priv, {
        accname = "",       % 平台帐号
        reg_time,           % 注册时间
        exp_cur,            % 本级经验
        exp,                % 总经验
        silver,             % 银币
        silver_bind,        % 绑定银币
        gold,               % 金币(RMB)
        gold_bind,          % 绑定金币
        bag_count,          % 玩家背包格子数(49=<N=<210)
        store_count,        % 玩家仓库格子数(12=<N=<180)
        hp_blood_pool,      % 玩家当前血池的生命量
        mp_blood_pool,      % 玩家当前血池的魔法量
        pet_hp_blood_pool,  % 玩家宠物血池的生命量
        x_priv,             % 前次地图x位置
        y_priv              % 前次地图y位置

}).

%% 玩家基础属性值
-record(sys_base_attr, {
        id,             % id{lvl, career}
        lvl,            % 等级
        career,         % 职业

        hp,             % 生命
        mp,             % 魔法
        xp,             % xp
        att_phy,        % 物理攻击
        def_phy,        % 物理防御
        att_poi,        % 魔法攻击(毒)
        def_poi,        % 魔法防御(毒)
        hit,            % 命中
        dodge,          % 闪避
        crit,           % 暴击
        def_crit,       % 暴抗
        ten,            % 韧性
        pene,           % 穿透
        crit_add,       % 暴击伤害加成
        crit_mis,       % 暴击伤害减免
        speed           % 速度
}).

%% 玩家属性变化
%% 每个字段可能为:
%%  * 数字,表示增加值
%%  * 元组,{变化值,百分比}
-record(player_attr_var, {
        hp = 0,             % 血上限
        mp = 0,             % 蓝上限
        xp = 0,             % xp上限

        hit = 0,            % 命中
        dodge = 0,          % 躲避
        crit = 0,           % 暴击
        def_crit = 0,       % 暴抗
        ten = 0,            % 韧性
        pene = 0,           % 穿透
        crit_add = 0,       % 暴击伤害加成
        crit_mis = 0,       % 暴击伤害减免

        att_phy = 0,        % 物理攻击
        def_phy = 0,        % 物理防御
        att_poi = 0,        % 药性攻击(魔法攻击)
        def_poi = 0,        % 药性防御(魔法防御)
        speed = 0           % 速度
}).
-type player_attr_var() :: #player_attr_var{}.

-record(player_basic_intro, {
        id,
        name,
        lvl,
        sex,
        career,
        battle_stren,
        guild_name,
        state,
        vip,
        last_login_time
}).

%%---------
%% 血池相关
%%---------
-record(sys_blood_pool, {
        lvl,            % 等级(对人就是人物等级，对宠就是宠物等级)
        hp,             % 单次补充血量
        mp,             % 单次补充魔法量
        pet_hp          % 宠物单次补充血量
}).

-type sys_blood_pool() :: #sys_blood_pool{}.

%%---------
%% cd相关
%%---------

%% cd类型
-define(CD_TYPE_SKILL, 1).      % 技能
-define(CD_TYPE_GOODS, 2).      % 物品
-define(CD_TYPE_EXERCISE, 3).   % 神格
-define(CD_TYPE_VIPBUFF, 5).    % vip祝福
-define(CD_TYPE_BLOOD, 6).      % 玩家血池
%% 公共cd是一种subtype
-define(CD_TYPE_PUBLIC, 0). % 公共

%% 物品cd类型id
-define(CD_GOODS_RECOVER_WINK_HP, 1). % 血瞬加恢复类
-define(CD_GOODS_RECOVER_LAST_HP, 2). % 血持续恢复类
-define(CD_GOODS_RECOVER_WINK_MP, 3). % 魔法瞬加恢复类
-define(CD_GOODS_RECOVER_LAST_MP, 4). % 魔法持续恢复类
-define(CD_GOODS_RECOVER_WINK_PET_HP, 5). % 宠物血瞬加恢复类
-define(CD_GOODS_RECOVER_LAST_PET_HP, 6). % 宠物血持续恢复类
-define(CD_GOODS_RECOVER_FURY, 7).    % 玩家怒气补充
%% 玩家血池cd类型id
-define(CD_BLOOD_RECOVER_HP, 1).      % 血量恢复类
-define(CD_BLOOD_RECOVER_MP, 2).      % 魔法恢复类
-define(CD_BLOOD_RECOVER_PET_HP, 3).  % 宠物血量恢复类
-define(CD_BLOOD_RECOVER_FURY, 4).    % 玩家怒气恢复
%% 普通血池cd时间(ms)
-define(CD_BLOOD_TIME, 10000).
%% 怒气池cd时间(10分钟)
-define(CD_BLOOD_FURY_TIME, 600000).  % 10分钟
%% 公共cd时间(ms)
-define(CD_PUBLIC_TIME, 1000).

%% 移动cd对应key(某些操作后,会设置一个移动cd)
-define(CD_MOVE_KEY, '$cd_move_key').   % 移动cd对应的key
-define(CD_MOVE_TIME, 200).             % 200ms

%% 玩家cd信息(需要持久化)
-record(cd, {
        id :: tuple(),         % id为{type, subtype}
        type ::integer(),      % cd类型
        subtype ::integer(),   % 对应的id(当type为技能时对应技能id，
        % 当为物品时为物品cd类型id，其它情况未指定)
        expire ::integer()     % 过期时间(ms)
}).
-type cd() :: #cd{}.

%%--------------
%% 玩家状态相关
%%--------------

%% 玩家状态信息
-record(player_state, {
        dead = false,       % 是否死亡
        battle = false,     % 是否处于战斗状态
        trade = false,      % 是否处于交易状态
        collection = false, % 是否处于采集状态
        convoy = false,	    % 是否处于护送过程
        convoy_protect = false,     % 是否处于护送保护状态
        convoy_rob_tired = false,   % 是否处于截镖疲劳状态
        switching = false,  % 是否切图中
        business = false,   % 是否处于跑商状态
        business_rob_tired = false, % 是否处于劫商疲劳状态

        %%
        %% 权限
        %%
        gm = false,         % 是否可使用gm指令
        move = true,        % 是否可移动
        use_skill = true,   % 是否可使用技能
        use_goods = true,   % 是否可使用物品

        %%
        %% buff相关
        %%
        unbeatable = false, % 是否无敌状态
        damage_enhance = 0, % 伤害输出加成值(0表示没有加成,100表示100%)
        damaged_add = 0,    % 受到伤害加成值(0表示没有加成)
        damaged_dec = 0,    % 伤害减免(0表示没有加成, 100表示100%)
        fixed_body = false, % 是否定身状态
        freeze = false,     % 是否冻结状态
        orderless = false,  % 混乱状态

        vip_trial = false,  % 是否在体验VIP
        carry_tool = false, % 玩家在攻城战斗是否带有工具箱
        carry_shell = false,% 玩家在攻城战斗是否带有炮弹
        crit = false,       % 是否必然暴击状态

        %%
        %% 外观显示相关
        %%
        dizzy = false       % 眩晕状态
}).

%% 玩家状态类型(协议p_player_state.state_list和state_sight.state使用)
-define(STATE_TYPE_UNBEATABLE, 1).      % 无敌
-define(STATE_TYPE_DAMAGE_ENHANCE, 2).  % 伤害输出加强
-define(STATE_TYPE_DIZZY, 3).           % 眩晕
-define(STATE_TYPE_DAMAGED_ADD, 4).     % 受到伤害加成
-define(STATE_TYPE_VIP_TRIAL, 5).       % VIP体验
-define(STATE_TYPE_CARRY_SHELL, 6).     % 采集炮弹
-define(STATE_TYPE_CARRY_TOOL, 7).      % 采集工具
-define(STATE_TYPE_COVER, 8).           % 保护膜状态
-define(STATE_TYPE_FREEZE, 9).          % 冻结状态
-define(STATE_TYPE_FIXED_BODY, 10).     % 定身状态
-define(STATE_TYPE_ORDERLESS, 11).      % 混乱状态
-define(STATE_TYPE_SLEEP, 12).          % 睡眠状态
-define(STATE_TYPE_BATTLE, 13).         % 战斗状态
-define(STATE_TYPE_MARS, 14).           % 战神之佑状态
-define(STATE_TYPE_DAMAGED_DEC, 15).    % 受到伤害减免

%%-------------
%% 快捷栏
%%-------------

%% 快捷类型
-define(SHORTCUT_TYPE_SKILL, 1).        % 技能
-define(SHORTCUT_TYPE_GOODS, 2).        % 物品

%%----------------------
%% 定义s2s需要的一些tag
%%----------------------

%% S2S 调用
-define(S2S_CAST, player_server:s2s_cast).
-define(S2S_CAST(Id, Req), player_server:s2s_cast(Id, ?MODULE, Req)).
-define(S2S_CALL, player_server:s2s_call).
-define(S2S_CALL(Id, Req), player_server:s2s_call(Id, ?MODULE, Req)).


%% 杀死怪物
-define(KILL_MON, kill_mon).
%% 作为队伍成员分享队友杀死的怪物
-define(KILL_MON_IN_TEAM, kill_mon_in_team).
%% 杀死的怪物可以作为任务计数怪
-define(KILL_MON_FOR_TASK, kill_mon_for_task).

%% 玩家受到伤害
-define(BE_DAMAGE, be_damage).
%% 杀死玩家
-define(KILL_PLAYER, kill_player).
%% 玩家受到退拽攻击
-define(BE_DRAG, be_drag).
%% 玩家或者怪物受到关注
-define(BE_MONITOR, 'be_monitor').
%% 玩家或者怪物被取消关注
-define(BE_MONITOR_CANCEL, 'be_monitor_cancel').
%% 玩家或者怪物的关注列表
-define(MONITOR_LIST, '$monitor_list').



%%-------------
%% 其它定义
%%-------------
%% 机器人在进程词典的key(用于屏蔽机器人log)
-define(I_AM_ROBOT, 'i_am_newbie_robot').
%% 不是机器人
-define(NOT_ROBOT, (not (erlang:get(?I_AM_ROBOT) =:= true))).


%% 存储在world_data中的表：开宝箱功能隐藏显示控制
-define(CTRL_BOX_VISIBLE, '$ctrl_box_visible').

-endif. % PLAYER_HRL
