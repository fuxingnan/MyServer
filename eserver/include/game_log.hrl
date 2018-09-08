%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc  关于游戏需要记录的日志
%%%     参考 doc/server/斗魂世界日志.txt
%%% @end
%%%
%%%----------------------------------------------------------------------
-ifndef(GAME_LOG_HRL).
-define(GAME_LOG_HRL, true).

%%----------
%% 银币相关
%%----------

%% 支出
-define(SILVER_GM, 1001).        % GM后台扣除银两
-define(SILVER_SHOP, 1002).      % 系统商店购买道具
-define(SILVER_TRADE, 1003).     % 通过交易失去银两，属于流通
-define(SILVER_COLLEAGE, 1004).  % 创建学院手续费

%% 收入

%%----------
%% 金币相关
%%----------
%% 消耗
-define(GOLD_OUT_GM, 5001).         % =>'GM后台扣除金币',
-define(GOLD_OUT_MARKET, 5002).     % =>'拍卖行购买商品，属于流通',
-define(GOLD_OUT_SHOP, 5003).       % =>'商店购买道具'
-define(GOLD_OUT_PET_TRAIN, 5004).  % =>'魂兽训练扣金币',
-define(GOLD_OUT_REVIVE, 5005).     % =>'复活失去金币',
-define(GOLD_OUT_COLLEAGE_CREATE, 5006). % =>'创建学院扣金币',
-define(GOLD_OUT_OTHER, 5007).      % =>'特殊功能开启扣金币',
            
%% 获得
-define(GOLD_IN_GM, 6001).          % =>'GM后台赠送金币（绑非）',
-define(GOLD_IN_PAY, 6002).         % =>'通过充值获得金币（非）',
-define(GOLD_IN_MARKET, 6003).      % =>'拍卖行出售商品获得金币（非）',
-define(GOLD_IN_USE, 6004).         % =>'道具使用获得（绑）',

%%----------
%% 道具相关
%%----------

-endif. % GAME_LOG_HRL
