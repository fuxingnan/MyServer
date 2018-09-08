%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 成就头文件
%%%
%%%----------------------------------------------------------------------
-ifndef(SUCCESS_HRL).
-define(SUCCESS_HRL, true).
-include("const.hrl").

%% 成就分类
-define(SUCCESS_TYPE_ANY, 0).       % 所有类型
-define(SUCCESS_TYPE_GROW, 1).      % 成长
-define(SUCCESS_TYPE_SEARCH, 2).     % 探索
-define(SUCCESS_TYPE_INTER, 3).    % 交互
-define(SUCCESS_TYPE_FIGHT, 4).     % 战斗
%% 子类型
-define(SUCCESS_FIRST,1).
-define(SUCCESS_WORLD,2).
-define(SUCCESS_MONEY,3).
-define(SUCCESS_BODY,4).
-define(SUCCESS_VIP,5).
-define(SUCCESS_EQUIP,6).
-define(SUCCESS_PET,7).
-define(SUCCESS_SKILL,8).
-define(SUCCESS_FISHING,9).
-define(SUCCESS_RELATIONSHIP,10).
-define(SUCCESS_COLLEAGE,11).
-define(SUCCESS_EXERCISE,12).
-define(SUCCESS_FIGHT,13).
-define(SUCCESS_KILL_MON,14).
-define(SUCCESS_BATTLE_STREN,15).

-define(SUCCESS_TYPE_LIST, [
        {1,1}, {2,1}, {3,1}, {4,1},
        {1,2}, {2,2}, {3,2}, {4,2},
        {1,3}, {2,3}, {3,3}, {4,3},
        {1,4}, {2,4}, {3,4}, {4,4},
        {1,5}, {2,5}, {3,5}, {4,5},
        {1,6}, {2,6}, {3,6}, {4,6},
        {1,7}, {2,7}, {3,7}, {4,7},
        {1,8}, {2,8}, {3,8}, {4,8},
        {1,9}, {2,9}, {3,9}, {4,9},
        {1,10}, {2,10}, {3,10}, {4,10},
        {1,11}, {2,11}, {3,11}, {4,11},
        {1,12}, {2,12}, {3,12}, {4,12},
        {1,13}, {2,13}, {3,13}, {4,13},
        {1,14}, {2,14}, {3,14}, {4,14},
        {1,15}, {2,15}, {3,15}, {4,15}
        ]).

%% 系统成就
-record(sys_success, {
        id,             % id
        type,           % 类型
        total,          % 进度总值
        point,          % 成就点
        reward,         % 奖励[[goods_id, count]]
        subtype         % 子类型
    }).

%% 成就状态
-define(SUCCESS_STATE_TODO, 0).   % 初始状态
-define(SUCCESS_STATE_DOING, 1).  % 进行中
-define(SUCCESS_STATE_DONE, 2).   % 完成

%% 玩家成就表
-define(SUCCESS_TABLE, "success").
-define(SUCCESS_DB_OP, ?DB_OP_MERGE(?SUCCESS_TABLE)).

%% 玩家成就
-record(success, {
        id,             % {玩家id, 成就id}
        player_id,      % 玩家id
        success_id,     % 成就id
        state,          % 状态
        can_reward = 1, % 是否可以奖励(0不可,1可以)
        progress = 0,   % 当前进度

        %% 非持久化数据
        type,           % 类型
        subtype         % 子类型
    }).

-endif. % SUCCESS_HRL
