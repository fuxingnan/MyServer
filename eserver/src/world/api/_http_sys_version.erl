%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 返回服务器版本
%%% @end
%%%----------------------------------------------------------------------
-module('_http_sys_version').
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg_httpd.hrl").
-include("wg_log.hrl").

-export([handle/2]).

-ifndef(VERSION).
-define(VERSION, 0).
-endif.

%% @doc 服务器运行状态
handle(_Req, _Method) ->
    Str = ejson:encode(?VERSION),
    {200, [], Str}.
