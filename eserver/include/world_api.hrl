%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 后台world API相关的接口
%%%
%%%----------------------------------------------------------------------
-ifndef(WORLD_API_HRL).
-define(WORLD_API_HRL, true).

%% 错误码定义
-define(API_SUCCESS, 0).        % 成功
-define(API_UNKNOWN, 1).        % 未知的消息
-define(API_BADARG, 101).       % 消息格式不对
-define(API_PAYMENT, 102).      % 充值失败(写DB错误）
-define(API_GOLD_LIMIT, 103).   % 充值元宝个数超出上限
-define(API_OFFLINE, 104).      % 玩家不在线
-define(API_NEWBIE_CARD, 110).  % 无可用的新手卡

-endif. % WORLD_API_HRL
