%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc the demo module handle the request path:
%%%  "http://host/sys/stats
%%%  返回服务器现在状态
%%% @end
%%%----------------------------------------------------------------------
-module('_http_sys_stats').
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg_httpd.hrl").
-include("wg_log.hrl").

-export([handle/2]).

%% @doc 服务器运行状态
handle(Req, _Method) ->
    _Qs = Req:parse_qs(),
    _Post = Req:parse_post(),
    _Nodes = [node() | nodes()],

    List = wg_stats:i(),
    Object = {List},
    Str = ejson:encode(Object),
    {200, [], Str}.
