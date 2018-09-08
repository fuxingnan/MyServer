%%%-------------------------------------------------------------------
%%% @author fx
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%     签到奖励
%%% @end
%%% Created : 15. 七月 2015 下午3:07
%%%-------------------------------------------------------------------
-author("fx").

-ifndef(DAILY_REWARD_HRL).
-define(DAILY_REWARD_HRL, true).

%% VIPSHOP基本信息
-record(sys_daily_reward, {
    id,             %% 签到天数id
    reward           %% 获得金钱

}).
-type sys_daily_reward() :: #sys_daily_reward{}.


-endif.