%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 返回节点列表
%%% @end
%%%----------------------------------------------------------------------
-module('_http_sys_nodes').
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg.hrl").
-include("wg_httpd.hrl").
-include("wg_log.hrl").

-export([handle/2]).

handle(_Req, _Method) ->
    List =
    [?S2B(?A2S(Node)) || Node <- [node() | nodes()]],
    Data = ejson:encode(List),
    {200, [], Data}.
