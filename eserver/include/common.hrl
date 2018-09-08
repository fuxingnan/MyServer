%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 游戏需要的共有的一些定义
%%%
%%%----------------------------------------------------------------------
-ifndef(COMMON_HRL).
-define(COMMON_HRL, true).

-ifdef(TEST).
-define(LOG_LEVEL, 5).
-else.
-define(LOG_LEVEL, 3).
-endif.

%% 日志后缀
-define(LOG_EXT, ".log").

%% 逻辑日志服务的数目
-define(LOGIC_LOG_SERVER_LIST, [logic_log_1, logic_log_2, logic_log_3, logic_log_4]).

%% 聊天日志服务名称
-define(CHAT_LOG_SERVER, chat_log_name).

%% flash 日志服务名称
-define(FLASH_LOG_SERVER, flash_log_name).

%% peer 日志服务名称
-define(PEER_LOG_SERVER, peer_log_name).


%%
%% 关于配置文件
%%
-define(CONF_SERVER, gh_conf_server).
-define(CONF_FILE, "gh.conf").

-define(CONF(K), wg_config:get(?CONF_SERVER, K)).
-define(CONF(K,D), wg_config:get(?CONF_SERVER, K, D)).

%%
%% 当进行Eunit分析时用来屏蔽数据库操作代码
%%
-ifdef(EUNIT).
-define(DB_OP(Exp), ok).
-else.
-define(DB_OP(Exp), Exp).
-endif.

%% 返回错误码
-define(C2SERR(Code), throw({error, Code})).

%% 攻击者信息
-record(aer_info, {
        type,       % 角色类型
        id,         % 角色id
        pid,        % 角色对应的进程
        data        % 其它数据#{} map结构
    }).
-type aer_info() :: #aer_info{}.

%% 受攻击者信息
-record(der_info, {
        type,               % 角色类型
        id,                 % 角色id
        name,               % 角色名称
        realm,              % 角色国家id
        battle_stren = 0,   % 战斗力
        data                % 其它数据#{} map结构
    }).
-type der_info() :: #der_info{}.

%% 定义系统的cd，用于内部数据表达
-record(p_cd, {
        type ::non_neg_integer(),  % cd类型
        subtype ::integer(),       % cd自类型
        expire ::integer()         % 过期时间
    }).

-type p_cd() :: #p_cd{}.
%%---------------                           
%% 消息发送宏定义     
%%---------------         
%% 立刻发送                                   
-define(S2C_SEND_PUSH, (game_s2c_route:new(send_push))).    
%% 合并发送     
-define(S2C_SEND_MERGE, (game_s2c_route:new(send_merge))).    

%% Unicode
-define(U2B(Text), (unicode:characters_to_binary(Text))).


-endif. % COMMON_HRL
