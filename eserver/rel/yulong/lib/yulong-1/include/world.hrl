%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc world头文件 src/world/
%%%
%%%----------------------------------------------------------------------
-ifndef(WORLD_HRL).
-define(WORLD_HRL, true).

%% world_data记录
-record(world_data, {
        key,
        val
    }).
%% world_data_disk
-record(world_data_disk, {
        key,
        val     % 存json数据
    }).


%% 广播内容的记录
-record(world_horn, {
    id,             % 广播者ID，仅在pos为小喇叭广播位置时有意义，只会是玩家id
    name,           % 广播者名称
    content,        % 要广播的消息
    sex,            % 性别
    career,         % 职业
    vip             % vip等级
}).

-define(MSG_POS_TOP, 1).    % 上方滚动公告
-define(MSG_POS_RUMOR, 2).  % 江湖传闻
-define(MSG_POS_PLAYER, 3). % 小喇叭广播
-define(MSG_POS_GM, 4).     % GM公告
-define(MSG_POS_BOTTOM, 5). % 下方滚动公告


-endif. % WORLD_HRL
