%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 世界排名刷新
%%% @end
%%%----------------------------------------------------------------------
-module('_http_world_rank').
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg.hrl").
-include("wg_httpd.hrl").
-include("wg_log.hrl").

-export([handle/2]).

% 刷新排行
handle(_Req,_Method)->
    ok = world_rank:calc_rank(),
    {200, [], "ok"}.
