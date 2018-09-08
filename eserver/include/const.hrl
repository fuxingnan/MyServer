%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 常量头文件
%%% @end
%%%
%%%----------------------------------------------------------------------
-ifndef(CONST_HRL).
-define(CONST_HRL, true).

%% 表示空
-define(NONE, none).
%% 零
-define(ZERO, 0).
%% 无限次
-define(INFINITY, 16#ffffffff).
%% 真气上限
-define(FSOUL_MAX, 999999999).

%%默认palyer数据默认数值
-define(PlayerRoomId, -1).
-define(PlayerMoney, 5000).
-define(useid, 0).
-define(unitid, 0).
-define(giveTimes, 0).
-define(lastGiveTime, 0).
-define(First_Max_Win, 0).
-define(CARD_ONE, -1).
-define(CARD_TWO, -1).
-define(GAME_NUM, -1).
-define(ROOM_TYPE, -1).
-define(ROOM_CARD, 0).
%% 应用对应的id,退出时作为状态码
-define(APP_WORLD, 11).
-define(APP_AREA, 12).
-define(APP_PLAYER, 13).
-define(APP_GATEWAY, 14).

%%----------------
%% 数据库操作标记
%%----------------
-define(DB_FLAG_NONE, 0).       % 数据库无变化(不用处理)
-define(DB_FLAG_INSERT, 1).     % 数据库插入操作
-define(DB_FLAG_UPDATE, 2).     % 数据库更新操作

%% 成功失败(随机相关)
-define(RAND_SUCCESS, 1).
-define(RAND_FAILED, 0).

%% 性别，0不限制
-define(SEX_MALE, 1).       % 男
-define(SEX_FEMALE, 2).     % 女

%% 职业
-define(CAREER_SHAOLING, 0). % 少林
-define(CAREER_TIANSHAN, 1). % 天山
-define(CAREER_DALI, 2).  % 大理
-define(CAREER_XIAOYAO, 3).% 逍遥
-define(CAREER_LIST, [0, 1, 2, 3]). % 职业列表
%% 职业流派系
-define(CAREER_SECT_PHY, [0, 1, 2]).    % 物理系
-define(CAREER_SECT_POI, [3]).          % 药系(魔法系)

-define(SECT_POI, 1). % 药系(魔法系)
-define(SECT_PHY, 2). % 物理系

%% 游戏中等级限制
-define(LVL_MIN, 1).
-define(LVL_MAX, 100).

%% 游戏中的年龄限制
-define(AGE_MIN, 10).
-define(AGE_MAX, 18).


%% VIP等级
-define(VIP_MIN, 1).
-define(VIP_MAX, 10).

%% 总经验上限
-define(EXP_MAX, 16#ffffffff).

%% 国家
-define(REALM_NEWBIE, 0).       % TODO
-define(REALM_LION, 1).         % TODO
-define(REALM_WHALE, 2).        % TODO
-define(REALM_EAGLE, 3).        % TODO
-define(REALM_LIST, [1,2,3]).


%% 游戏中阵营
-define(CAMP_HUMAN,   0).       % 玩家
-define(CAMP_FRIEND, 1).        % 友好
-define(CAMP_NEUTRAL, 2).       % 中立
-define(CAMP_ENEMY, 3).         % 敌对

%% 角色类型
-define(ROLE_TYPE_ANY, 0).      % 任意角色类型
-define(ROLE_TYPE_MON, 1).
-define(ROLE_TYPE_PLAYER, 2).
-define(ROLE_TYPE_PET, 3).
-define(ROLE_TYPE_MOUNT, 4).
-define(ROLE_TYPE_EMPLOYEE, 5).
-define(ROLE_TYPE_NPC, 6).
%% 角色id 和角色类型之间互转
-define(WORLD_ID_TO_ROLE_TYPE(Id), (Id rem 10)).
-define(WORLD_ID_TO_SYS_ID(RoleIdA), (RoleIdA div 10)).

%% 把服务端角色id 附加上角色类型给客户端构造新的对象id
-define(PLAYER_OBJ_ID(Id), (Id * 10 + ?ROLE_TYPE_PLAYER)).
-define(MON_OBJE_ID(Id), (Id * 10 + ?ROLE_TYPE_MON)).
-define(NPC_OBJ_ID(Id), (Id * 10 + ?ROLE_TYPE_NPC)).
-define(PET_OBJ_ID(Id), (Id * 10 + ?ROLE_TYPE_PET)).
-define(MOUNT_OBJ_ID(Id), (Id * 10 + ?ROLE_TYPE_MOUNT)).

%% 角色进入或离开
-define(ROLE_MAP_ENTER, 0).
-define(ROLE_MAP_LEAVE, 1).

%% 角色死亡或活着
-define(ROLE_DEAD, 0).
-define(ROLE_LIVE, 1).

%% 玩家死亡
-define(PLAYER_DEAD, player_die).

%% 在线或离线
-define(OFFLINE, 0).
-define(ONLINE, 1).

%% 初始玩家地图id
-define(MAPID_INIT, 1).
-define(X_INIT, 3076).
-define(Y_INIT, 11590).

%% 新手地图(修改新手地图时修改)
-define(MAP_NEWBIE_LIST, [1, 2]).

%% 初始魂怒
-define(FURY_INIT, 100).

%% 系统中货币种类
-define(MONEY_SILVER, 0).       % 银币
-define(MONEY_GOLD, 1).         % 金币
-define(MONEY_GOLD_BIND, 2).    % 绑定金币
-define(MONEY_SILVER_BIND, 3).  % 绑定银币
-define(MONEY_COUPON_1, 4).     % 代币1
-define(MONEY_COUPON_2, 5).     % 代币2
-define(MONEY_COUPON_3, 6).     % 代币3
-define(MONEY_TYPE_LIST, [0, 1, 2, 3, 4, 5, 6]).

%% 邮件中钱是否绑定
-define(MONEY_NOT_BIND, 1).   % 钱非绑定
-define(MONEY_BIND, 2).       % 钱是绑定

-define(MONEY_SILVER_MAX, 999999999).       % 银币上限
-define(MONEY_GOLD_BIND_MAX, 999999999).    % 绑定上限
-define(MONEY_GOLD_MAX,   999999999).       % 金币上限

%% 伤害类型

%% 1MISS，2普通 3暴击，4免疫
-define(DAMAGE_TYPE_MISS, 1).
-define(DAMAGE_TYPE_NORMAL, 2).
-define(DAMAGE_TYPE_CRIT, 3).
-define(DAMAGE_TYPE_DODGE, 4).
-type damage_type() :: 1 | 2 | 3 | 4.



%% 概率计算满值, 10000 等于 100%
-define(PROB_FULL, 10000).
%% 百分比增加(10000为基数)
-define(PERCENT_INC(Var, Percent), 
    (Var + Var * Percent  div ?PROB_FULL)).

%% 关于颜色定义:绿蓝紫橙（越来越高级）
-define(COLOR_WHITE,    1).
-define(COLOR_GREEN,    2).
-define(COLOR_BLUE,     3).
-define(COLOR_PURPLE,   4).
-define(COLOR_ORANGE,   5).

%% 系统中频道定义
-define(CHANNEL_HORN, 0).       % 喇叭
-define(CHANNEL_WORLD, 1).      % 世界
-define(CHANNEL_MAP, 2).        % 地图
-define(CHANNEL_GUILD, 3).   % 工会
-define(CHANNEL_TEAM, 4).       % 组队

%%----
%% 传闻
%%----
%% 系统中传闻类型
-define(RUMOR_BOX, 1).          % 宝箱
-define(RUMOR_STREN, 2).        % 强化
-define(RUMOR_STRONG, 3).       % 強体
-define(RUMOR_KILL_PLAYER, 4).  % pk杀死
-define(RUMOR_VIP, 8).          % VIP之旅


%% 传闻列表
-define(RUMOR_TYPE_LIST, 
    [
    ]).

%% 游戏方位定义
%% 顺时针旋转,由下开始为:0-7
-define(BOTTOM, 0).
-define(BOLEFT, 1).
-define(LEFT, 2).
-define(UPLEFT, 3).
-define(UP, 4).
-define(UPRIGHT, 5).
-define(RIGHT, 6).
-define(BORIGHT, 7).
-define(INTERNAL, 8).
-define(SAME, 9).

%% 调用server(gen_fsm, gen_server)超时
-define(GEN_TIMEOUT, 10000).

%% 每天对应的秒数
-define(DAY_SECONDS, 86400).
%% 星期列表
-define(WEEK_DAY_LIST, [1, 2, 3, 4, 5, 6, 7]).

%% 系统帐号(邮件,物品使用)
-define(SERVER_VERSION, 967). % 默认系统
-define(SYSTEM_ID_DEFAULT, 11). % 默认系统
-define(SYSTEM_ID_VIP, 12).     % vip系统
-define(SYSTEM_ID_BATTLE, 13).  % 战斗系统
-define(SYSTEM_ID_WEBAPI, 14).  % 管理后台
-define(SYSTEM_ID_DHD, 15).     % 斗魂岛系统id
-define(SYSTEM_ID_QUIZ, 16).    % 答题系统id
-define(SYSTEM_ID_MARKET, 17).  % 物品挂售时，在市场中的所有者为此id
-define(SYSTEM_ID_MAIL, 18).    % 邮件系统id
-define(SYSTEM_ID_GUILD, 19).% 学院系统id
-define(SYSTEM_ID_GM, 20).      % GM系统id
-define(SYSTEM_ID_HIRE, 21).      % 雇佣系统id
-define(PLAYER_ID_START, 0).  % 玩家帐号起始范围
-define(ACCOUNT_ID_START, 0).  % 玩家帐号起始范围
%% 没有任何攻击行为后，脱离战斗所需时间(3s)
-define(BATTLE_EXPIRE_TIME, 3).

%% 背包整理时间间隔(5s)
-define(BAG_TIDY_INTERVAL, 5000).
%% 仓库整理时间间隔(5s)
-define(STORE_TIDY_INTERVAL, 5000).

%%------------
%% 属性相关
%%------------

%%% *NOTE*
%%%  属性数字id(鉴定属性,被动技能,宝石属性, buff均使用):
%%%   1:hp 2:mp 3:xp 4:hit 5:dodge 6:crit 7:def_crit 8:ten 9:pene
%%%   10:crit_add 11:crit_mis
%%%   12:att_phy 13:def_phy 14:att_poi 15:def_poi 16:speed
-define(ATTR_ID_HP, 1).
-define(ATTR_ID_MP, 2).
-define(ATTR_ID_XP, 3).
-define(ATTR_ID_HIT, 4).
-define(ATTR_ID_DODGE, 5).
-define(ATTR_ID_CRIT, 6).
-define(ATTR_ID_DEF_CRIT, 7).
-define(ATTR_ID_TEN, 8).
-define(ATTR_ID_PENE, 9).
-define(ATTR_ID_CRIT_ADD, 10).
-define(ATTR_ID_CRIT_MIS, 11).
-define(ATTR_ID_PHY, 12).
-define(ATTR_ID_DEF_PHY, 13).
-define(ATTR_ID_ATT_POI, 14).
-define(ATTR_ID_DEF_POI, 15).
-define(ATTR_ID_SPEED, 16).

-define(ATTR_ID_EXP, 30).               % 表示经验(sys_buff中使用)
-define(ATTR_ID_STREN_PROB, 31).        % 表示强化加成(sys_buff中使用)

%% 控制技能相关(buff)
-define(ATTR_BUFF_UNBEATABLE, 60).      % 无敌状态
-define(ATTR_BUFF_DAMAGE_ENHANCE, 61).  % 所有技能伤害输出加强
-define(ATTR_BUFF_DIZZY, 62).           % 眩晕(无法移动,无法使用技能)
-define(ATTR_BUFF_DAMAGED_ADD, 63).     % 所有受到技能伤害附加
-define(ATTR_BUFF_DAMAGED_BACK, 64).    % 反伤
-define(ATTR_BUFF_DAMAGED_DEC, 66).     % 伤害减免
-define(ATTR_BUFF_SUCCESSIVE_KILL , 67).% 连斩状态
% vip体验buff
-define(ATTR_BUFF_VIP_TRIAL, 68).       % VIP体验状态
%% 伤害相关buff
-define(ATTR_BUFF_DAMAGED_PHY, 69).     % 物理伤害
-define(ATTR_BUFF_DAMAGED_MAGIC, 70).   % 魔法伤害
%% 控制技能相关_扩充(buff) 78，瞬移79，致盲81
-define(ATTR_BUFF_FIXED_BODY, 71).      % 定身(无法移动)
-define(ATTR_BUFF_FREEZE, 72).          % 冻结
-define(ATTR_BUFF_CONK, 73).            % 昏迷
-define(ATTR_BUFF_STEALTH, 74).         % 隐身
-define(ATTR_BUFF_FEND, 75).            % 击退
-define(ATTR_BUFF_MAGIC_DEC, 76).       % 魔法免疫
-define(ATTR_BUFF_PHY_DEC, 77).         % 物理免疫
-define(ATTR_BUFF_TAUNT, 78).           % 嘲讽
-define(ATTR_BUFF_TELEPORT, 79).        % 瞬移
-define(ATTR_BUFF_LETHARGY, 80).        % 昏睡[不能使用技能，可移动]lethargy
-define(ATTR_BUFF_BLIND, 81).           % 致盲


%%------------
%% 聊天相关
%%-----------

%% todo 调整顺序
%% 附近聊天
-define(CHAT_MAP, 1).
%% 组队聊天
-define(CHAT_TEAM, 2).
%% 世界聊天
-define(CHAT_WORLD, 3).
%% 小喇叭喊话
-define(CHAT_HORN, 4).
%% 工会聊天
-define(CHAT_GUILD, 5).
%% 私聊
-define(CHAT_P2P, 6).

-define(CHAT_MAP_INTERVAL, 500).    % 附近聊天时间间隔
-define(CHAT_TEAM_INTERVAL, 100).   % 组队聊天时间间隔
-define(CHAT_GUILD_INTERVAL, 3000).   % 学院聊天时间间隔
-define(CHAT_WORLD_INTERVAL, 10000). % 世界聊天时间间隔
-define(CHAT_HORN_INTERVAL, 15000). % 小喇叭喊话时间间隔
-define(CHAT_WORLD_LEVEL, 10).      % 世界聊天等级限制
-define(CHAT_HORN_LEVEL, 30).       % 小喇叭喊话等级限制

%%-----------
%% 宠物相关
%%-----------
-define(PET_NAME_MAX, 8).           % 宠物名最大长度
-define(PET_FIGHT_LIMIT, 300).      % 宠物出战最小时间 ms
-define(PET_REST_LIMIT, 300).       % 宠物休息最小时间 ms
-define(PET_COUNT_MAX, 10).         % 宠物最大数目

%%-----------
%% 任务相关
%%------------
%% 可接任务最大数
-define(TASK_ACCEPT_MAX, 30).

%%--------------------------
%%列表性东西的更新模式(范围)
%%--------------------------

-define(UPDATE_PART, 1).  % 局部更新
-define(UPDATE_FULL, 0).  % 全部更新

%%------------
%% 关系
%%------------

%% 好友最大数量
-define(RELATION_FRIEND_MAX, 99).

%% 黑名单最大数量
-define(RELATION_BLACKLIST_MAX, 99).

%% 仇人名单最大长度
-define(RELATION_HATE_MAX, 99).

%%--------------
%% 关于地图
%%--------------
-define(POS_CM_TO_M, map_misc:pos_cm_to_m).
-define(POS_M_TO_CM, map_misc:pos_m_to_cm).

%% 功能开启,对应客户端 USER_COMMONFLAG
-define(CF_FELLOW_OPEN_FLAG,10).        %% 宠物
-define(CF_BELLE_OPEN_FLAG,11).         %% 美人
-define(CF_STRENGTHEN_OPEN_FLAG,13).    %% 强化./gam

-endif. % CONST_HRL
