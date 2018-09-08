%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 事件定义
%%% @end
%%%
%%%----------------------------------------------------------------------
-ifndef(HOOKS_HRL).
-define(HOOKS_HRL, true).

-define(HOOK_NPC_TALK, 1).  % 任务事件发生
-define(HOOK_KILL_MON, 2). % 任务事件发生
-define(HOOK_OCCUR_EVENT, 3). % 任务事件发生
-define(HOOK_UPDATE_BAG, 4). % 任务事件发生
-define(HOOK_KILL_PLAYER, 5). % 任务事件发生

-endif. % HOOKS_HRL
