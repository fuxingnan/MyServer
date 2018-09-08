%%%----------------------------------------------------------------------
%%%
%%% @author: auto generate
%%% @doc: 错误码 (自动生成，请勿编辑！)
%%%
%%%----------------------------------------------------------------------
-ifndef(ERRNO_HRL).
-define(ERRNO_HRL, true).
-define(E_OK                                ,        0).    % 成功
-define(E_FAILED                            ,        1).    % 失败
-define(E_OK_LOGIN                          ,        1).    % 登陆成功
-define(E_UNKNOWN                           ,        2).    % 未知错误
-define(E_NEXIST                            ,        3).    % 对象不存在
-define(E_DB                                ,        3).    % 数据库错误
-define(E_CREATEROLE_SUCCESS                ,        0).    % 创建角色成功
-define(E_CREATEROLE_FAIL                   ,        1).    % 创建角色失败
-define(E_CREATEROLE_FAIL_NAMEEXIST         ,        2).    % 创建角色名字存在
-define(E_CREATEROLE_FAIL_NAMESCREENING     ,        3).    % 创建角色名字包含屏蔽字
-define(E_BIND_ACCOUNT_SUCCESS              ,        2).    % 绑定facebook帐号成功
-define(E_LOGIN_SUCESS                      ,        3).    % 登录facebook帐号成功
-define(E_ALREADY_LOGIN                     ,        4).    % 当前帐号已经登录
-define(E_ACCOUNT_ALREADY_BIND              ,        5).    % 帐号已经绑定
-endif. % ERRNO_HRL