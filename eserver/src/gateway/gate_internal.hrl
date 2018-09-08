%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc gateway内部使用的头文件
%%%
%%%----------------------------------------------------------------------
-ifndef(GATE_INTERNAL_HRL).
-define(GATE_INTERNAL_HRL, true).
-include("types.hrl").
-include("gate.hrl").

%% gateway tcp server 名称
-define(GATEWAY_TCP_SERVER, "gateway_tcp_server").

%% 消息头字节数
-define(PACKET_LEN, 0). 
%% 消息最大长度
-define(PACKET_SIZE_MAX, 4380).  
%% 消息缓存时间(200ms)
-define(PACKET_MERGE_TIME, 200).


%% gate_client state
-record(client_state, {
        sock,           % 对应的sock
        ip,             % ip信息，冗余，但可以对外暴露
        part = <<>>,    % 部分数据

        id,             % 角色id
        player_pid,     % player_server进程pid
        accname = <<>>, % 平台名称
        sid,            % 服务器id
        cm,             % 用户防沉迷状态
        first_enter = false,    
                        % 是否为第一次进入游戏
        switch_node = false,
                        % 是否处于切换节点状态
                       
        track = false,   % 是否需要监控该玩家
                       
        heart_n = 0,    % 心跳使用的计数器
        heart_t = 0,     % 心跳超时次数
        anti_fps = 0    % 帧频检测标志
    }).

%% 角色状态(获取角色信息时使用)
-define(ROLE_STATE_NULL, 0).      % 未创建角色
-define(ROLE_STATE_NEWBIE, 1).    % 新手
-define(ROLE_STATE_NORMAL, 2).    % 正常

-endif. % GATE_INTERNAL_HRL
