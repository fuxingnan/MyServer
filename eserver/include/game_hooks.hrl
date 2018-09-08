%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 游戏中定义的HOOKS，与game_hooks.erl结合使用
%%%
%%%----------------------------------------------------------------------
-ifndef(GAME_HOOKS_HRL).
-define(GAME_HOOKS_HRL, true).

%% 玩家登录
-define(HOOK_LOGIN, hook_login).
%% 玩家进程(player_server初始化)
-define(HOOK_INIT_PLAYER, "hook_init_player").
-define(HOOK_TERMINATE_PLAYER, "hook_terminate_player").

%% 玩家进入地图
-define(HOOK_ENTER_MAP, hook_enter_map).
%% 玩家离开地图
-define(HOOK_LEAVE_MAP, hook_leave_map).
%% 玩家退出
-define(HOOK_LOGOUT, hook_logout).

%% 玩家主动攻击
-define(HOOK_PLAYER_ATTACK, hook_player_attack).

%% 玩家升级
-define(HOOK_PLAYER_UPGRADE, 'hook_upgrade').

-endif. % MON_HRL
