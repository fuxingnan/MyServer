%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 是否显示箱子
%%% @end
%%%----------------------------------------------------------------------
-module('_http_sys_box').
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg.hrl").
-include("wg_httpd.hrl").
-include("wg_log.hrl").

-export([handle/2]).

handle(Req,Method)->
    Qs =
        case Method of
            'GET' ->
            Req:parse_qs();
            'POST' ->
            Req:parse_post()
        end,
    Ctrl = ?QS_GET("ctrl", Qs, "1"),
    ok = player_server:admin_ctrl_box(?S2N(Ctrl)),
    {200, [], "ok"}.
