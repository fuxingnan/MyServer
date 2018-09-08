%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 新手引导相关的数据,参考doc/新手-初始数据信息.docx
%%%     对于物品,如果仅仅指定id表示一个物品,如果为{Id, Count}
%%%     表示指定数目个物品(参看db_acc.erl)
%%%     *NOTE* 确保物品数目不超过堆叠数目!
%%%
%%%----------------------------------------------------------------------
-ifndef(NEWBIE_HRL).
-define(NEWBIE_HRL, true).
-include("player.hrl").

%% 是否使用正式数据
-define(USE_OFFICAL, true).

%%--------------
%% 新手任务相关
%%--------------
-define(NEWBIE_TASK_ID, 1).    % 新手任务id
-define(NEWBIE_TASK_STEP_MIN, 1).   % 新手任务最小步骤
-define(NEWBIE_TASK_STEP_MAX, 7).   % 新手任务最大步骤

-ifdef(USE_OFFICAL).
-define(NEWBIE_DOUJIAN_GOODS, []).
-define(NEWBIE_LIANDAN_GOODS, []).
-define(NEWBIE_SUIHUN_GOODS, []).
-define(NEWBIE_KONGSHOU_GOODS, []).

%% 经验等级
-define(NEWBIE_EXP, 0). % 新手经验
-define(NEWBIE_LVL, 1). % 新手等级
-define(NEWBIE_AGE, 10).% 新手年龄

%% 财富
-define(NEWBIE_SILVER, 10). % 新手银币
-define(NEWBIE_GOLD, 10).   % 新手金币

%% 快捷栏
-define(NEWBIE_SHORTCUT_GOODS, []).
-endif.

-endif. % NEWBIE_HRL
