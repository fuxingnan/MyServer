%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 玩家设置信息
%%%
%%%----------------------------------------------------------------------
-ifndef(SETTING_HRL).
-define(SETTING_HRL, true).

%%-------
%% 设置
%%-------
%% 设置类型列表
-define(SETTING_TYPE_LIST, [0, 1, 2, 3, 4, 5]).
%% 设置的最大长度(1k)
-define(SETTING_MAX_SIZE, 1024).

%% 类型1对应的record(其会影响服务器逻辑)
-record(setting, {
        chat_auto_response,             % 自动回复
        chat_auto_response_msg          % 自动回复信息
    }).

%% 类型2-5对应的数据为一个字符串(客户端解析)

-endif. % SETTING_HRL
