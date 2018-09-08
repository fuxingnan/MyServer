%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc the demo module handle the request path:
%%%  "http://host/user/online
%%%  返回在线人数列表
%%% @end
%%%----------------------------------------------------------------------
-module('_http_user_online').
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg_httpd.hrl").
-include("wg_log.hrl").

-export([handle/2]).

%% @doc 在线人数列表
handle(Req, Method) ->
    Qs = 
    case Method of
        'GET' ->
            Req:parse_qs();
        'POST' ->
            Req:parse_post()
    end,
    Type = ?QS_GET("type", Qs, "list"),
    Json =
    case Type of
        "list" ->
            world_online:id_list();
        "count" ->
            % 使用gate_node
            gate_node:online_count();
        "count2" ->
            world_online:count()
    end,
    Str = ejson:encode(Json),
    {200, [], Str}.
