%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 计数器头文件定义
%%%
%%%----------------------------------------------------------------------
-ifndef(COUNTER_HRL).
-define(COUNTER_HRL, true).

%% 玩家个人counter 类型
-define(COUNTER_TYPE_DB, db).
-define(COUNTER_TYPE_DAILY, daily).

-define(COUNTER_DB, (player_counter:new(?COUNTER_TYPE_DB))).
-define(COUNTER_DAILY, (player_counter:new(?COUNTER_TYPE_DAILY))).

%% world daily中每个玩家一个counter list
-define(PLAYER_COUNTER_WORLD_DAILY_KEY(Id), {player_counter, Id}).
%% 副本计数key
-define(DUNGEON_COUNT_KEY(Id), {'$dungeon_n', Id}).

%% 玩家清除副本计数的次数(现在每天只能一次)
-define(DUNGEON_COUNT_DEC_KEY(Id), {'$dungeon_count_dec_day', Id}).

%%-----------------------------
%% db中需要记录的一些持久化key
%%-----------------------------
% 已经移到player中了
%-define(COUNTER_DB_KEY_CULTURE, 2).             % 文采值(答题相关)

-define(COUNTER_DB_KEY_TITLE_LEVEL, 8).   % 等级称号

-define(COUNTER_DB_KEY_PKMODE_CD, 21).          % 切换pk模式cd

-define(COUNTER_DB_KEY_TASK_FINISH, 30).        % 完成任务数
% 已经移到player中了
%-define(COUNTER_DB_KEY_KILL_PLAYER, 41).        % 杀死玩家数
-define(COUNTER_DB_KEY_KILLED_BY_PLAYER, 42).   % 被杀死数

-define(COUNTER_DB_KEY_LOGIN_DAYS, 50).   % 连续登录天数
-define(COUNTER_DB_KEY_AWARD_DAYS, 51).   % 领取奖励对应的天数

%% 关于师门
-define(COUNTER_DB_MASTER_JOIN_BAN, 53).		% 禁止加入师门标识


%% 关于引导
%% 计数返回1/0表示是/否
-define(COUNTER_DB_GUIDE_SUCCESS_REWARD, 60).   % 是否领取过成就奖励
-define(COUNTER_DB_GUIDE_LEARN_SKILL, 61).      % 是否学习过技能
-define(COUNTER_DB_GUIDE_GETON_MOUNT, 62).      % 是否骑乘过坐骑
-define(COUNTER_DB_GUIDE_FIGHT_PET, 63).        % 是否出战过魂兽
-define(COUNTER_DB_GUIDE_DO_EXERCISE, 64).      % 是否进行过修体
-define(COUNTER_DB_GUIDE_ENTER_DUNGEON, 65).    % 是否进入过副本
-define(COUNTER_DB_GUIDE_FRIEND_BLESS, 66).     % 是否完成好友祝福
-define(COUNTER_DB_GUIDE_CACHE_AWARD, 67).      % 是否领取过经验壶奖励
-define(COUNTER_DB_GUIDE_FIRST_DUNGEON, 68).    % 是否进入过新手副本


%% 关于斗魂岛战场积分(不用了)
-define(COUNTER_DB_HONOR, 80).                 % 玩家荣誉，可以多个途径获得(斗魂岛，单人竞技PK....)

%% 关于福利
-define(COUNTER_DB_WEAL_NOVICE, 90).
-define(COUNTER_DB_WEAL_MONEY, 91).
-define(COUNTER_DB_WEAL_VIP1, 92).
-define(COUNTER_DB_WEAL_VIP3, 93).
-define(COUNTER_DB_WEAL_VIP5, 94).
-define(COUNTER_DB_WEAL_VIP7, 95).
-define(COUNTER_DB_WEAL_VIP9, 96).

%% 宠物
-define(COUNTER_PET_GAIN_SILVER, 100).      % 银币(前端金币抽取计数)
-define(COUNTER_PET_GAIN_GOLD, 101).        % 金币(前端元宝抽取)
-define(COUNTER_PET_GAIN_FREE, 102).        % 免费抽取类型
-define(PET_COLUMN_COUNT, 103).             % 玩家宠物栏大小,初始为3

%% 关于护送任务
-define(COUNTER_CONVOY_REFRESH_VIP, 110).	% 已使用的vip赠送的刷新次数
-define(COUNTER_CONVOY_REFRESH, 111).		% 剩余的由道具产生的刷新次数
-define(COUNTER_CONVOY, 112).		% 已接受护送任务次数
-define(COUNTER_CONVOY_ROB, 113).	% 抢劫他人护送的次数
-define(COUNTER_CONVOY_GOLD_REFRESH, 114).	% 金币刷新次数
-define(COUNTER_DB_CONVOY_LVL, 115).		% 护送任务的当前等级(刷新任务等级的时候使用)
%% 副本相关，如神石的闯关层数
-define(COUNTER_DB_GUARD_STONE, 120).       % 守卫神石最大可选层数
% 竞技场相关
-define(COUNTER_ARENA_REWARD, 130).                  % 记录领取奖励的次数
-define(COUNTER_ARENA, 131).                         % 记录当天参加竞技场的次数
-define(COUNTER_ARENA_BATTLE_TODAY, 132).            % 记录玩家当天最佳数据
-define(COUNTER_ARENA_BATTLE_HISTORY, 133).          % 记录玩家历史最佳数据
% 单人竞技场(真人PK)
-define(COUNTER_ARENA_SINGLE_SUCCESSIVE, 134).       % 记录玩家在单人竞技场连胜的次数
-define(COUNTER_ARENA_SINGLE_WATCH_EXP, 135).        % 记录玩家在单人获得观看经验奖励值
-define(COUNTER_ARENA_SINGLE_HONOR, 136).            % 记录玩家在单人获得的荣誉
-define(COUNTER_ARENA_SINGLE_BATTLE_EXP, 137).       % 记录玩家在单人获得观看战斗经验奖励值
-define(COUNTER_DAILY_ARENA_SINGLE_ENTER_COUNT, 138).% 记录玩家当天进出竞技场的次数
% 坐骑
-define(COUNTER_DAILY_MOUNTS_PROB, 140).		% 坐骑的进阶祝福成功率
% 关于攻城战
-define(COUNTER_DAILY_SIEGE_SCORE, 141).        % 攻城战中获得的积分
% 关于离线经验
-define(COUNTER_OFFLINE_EXP_HOURS, 200).             % 当前累积的小时数
% 开服vip返还金币
-define(COUNTER_VIP_GOLD_GET, 210).                  % 是否领取过金币
%%-----------
%% 活跃度
%%-----------
-define(COUNTER_ONLINE_ACC, 220).                    % 玩家每日累积的在线时间
-define(COUNTER_LIVENESS, 221).                      % 每日的活跃度
-define(COUNTER_DAILY_LIVENESS_EXCHANGE, 222).       % 今日是否兑换过活跃度

%%-----------
%% 新手礼包(10级一次)
%%-----------
-define(COUNTER_LEVEL_GIFT_LVL, 224).                 % 新手礼包领取状态，记录已经领取过的最高等级

-define(COUNTER_DAILY_SPECIAL_TRAIN_DOUBLE, 225).     % 当天参加双倍特训的次数
-define(COUNTER_DB_TITLE_NEWBIE_KING, 230).           % 获得新人王称号标志


%%
%% -define(COUNTER_SUCCESS_WORSHIP, 83111).            % 玩家膜拜圣兽次数
%% -define(COUNTER_SUCCESS_REVIVE, 84131).             % 原地复活次数
%% -define(COUNTER_SUCCESS_KILL_MAP_BOSS, 84141).      % 杀死野外怪物数
%% -define(COUNTER_SUCCESS_KILL_MON, 84145).           % 杀死普通怪物数
%% -define(COUNTER_SUCCESS_MEDITATE, 83121).           % 单修时间
%% -define(COUNTER_SUCCESS_DOUBLE_MEDITATE, 83124).    % 双修时间
%%
%% -define(COUNTER_LIVENESS_ONLINE, 9001).         % 今日累积在线3小时
%% -define(COUNTER_LIVENESS_30_CIRCLE_TASK, 9002). % 完成30循环任务
%% -define(COUNTER_LIVENESS_40_CIRCLE_TASK, 9003). % 完成40循环任务
%% -define(COUNTER_LIVENESS_50_CIRCLE_TASK, 9004). % 完成50循环任务
%% -define(COUNTER_LIVENESS_60_CIRCLE_TASK, 9005). % 完成60循环任务
%% -define(COUNTER_LIVENESS_70_CIRCLE_TASK, 9006). % 完成70循环任务
%% -define(COUNTER_LIVENESS_DUNGEON_13001, 9007).  % 击杀猎兽林深处副本BOSS
%% -define(COUNTER_LIVENESS_DUNGEON_13012, 9008).  % 成功通过守卫神石副本10层
%% -define(COUNTER_LIVENESS_DUNGEON_13007, 9009).  % 击杀火之祭坛副本最终BOSS
%% -define(COUNTER_LIVENESS_DUNGEON_13006, 9010).  % 击杀惊魂地穴副本最终BOSS
%% -define(COUNTER_LIVENESS_DUNGEON_13011, 9011).  % 成功通过1波疯狂追击副本
%% -define(COUNTER_LIVENESS_DUNGEON_13004, 9012).  % 击杀飞斗浅滩副本最终BOSS
%% -define(COUNTER_LIVENESS_DUNGEON_13008, 9013).  % 成功通过百层魔窟副本30层
%% -define(COUNTER_LIVENESS_FISHING, 9014).        % 完成1次钓鱼
%% -define(COUNTER_LIVENESS_QUIZ, 9015).           % 参加1次答题
%% -define(COUNTER_LIVENESS_CONVOY, 9016).         % 完成3次运镖
%% -define(COUNTER_LIVENESS_TRAIN, 9017).          % 完成1次双倍特训
%% -define(COUNTER_LIVENESS_DUNGEON_13013, 9018).  % 完成2次单人试炼副本
%% -define(COUNTER_LIVENESS_DHD, 9019).            % 参加1次斗魂岛大战
%% -define(COUNTER_LIVENESS_REALM_BOSS, 9020).     % 参加2次国家BOSS战
%% -define(COUNTER_LIVENESS_DUNGEON_13005, 9021).  % 击杀魔晶谷副本最终BOSS
%%
%% -define(COUNTER_LIVENESS_MAP_BOSS, 9023).       % 野外boss
%% -define(COUNTER_LIVENESS_KILLPLAYER,9024).      % 杀死其他玩家计数器
%% -define(COUNTER_LIVENESS_10DUNGEON_13008, 9025).% 成功通过百层魔窟副本10层
%% -define(COUNTER_LIVENESS_50DUNGEON_13008, 9026).% 成功通过百层魔窟副本50层
%% -define(COUNTER_LIVENESS_ENTER_PK, 9027).       % 参加一次PK
%% -define(COUNTER_LIVENESS_CONVOY_ANYTIME, 9028). % 完成3次运镖

-define(COUNTER_PARTNER_4399_LOGIN_GIFT, 9029). % 4399平台验证通过领取礼包计数器
-endif. % COUNTER_HRL
