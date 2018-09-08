%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc the demo module handle the request path:
%%%  "http://host/sys/notice
%%%  通知系统有新公告
%%% @end
%%%----------------------------------------------------------------------
-module('_http_sys_notice').
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg_httpd.hrl").
-include("wg.hrl").
-include("wg_log.hrl").

-export([handle/2]).

%% @doc 通知服务器有新公告
handle(Req, Method) ->
    Qs = 
        case Method of
            'GET' ->
            Req:parse_qs();
            'POST' ->
            Req:parse_post()
        end,

    Action = ?QS_GET("action",Qs,"-100"),
    Id = ?QS_GET("id",Qs),
    case Action of
        "lock"->
            Lock = ?QS_GET("lock",Qs),
            world_notice:lock_switch(?S2N(Id), ?S2N(Lock)),
            Rt = 0;
        "add"->
            PostTime = ?QS_GET("post_time",Qs),
            PlanTime = ?QS_GET("plan_time",Qs),
            EndTime = ?QS_GET("end_time",Qs),
            Period = ?QS_GET("period",Qs),
            Status = ?QS_GET("status",Qs),
            Content = ?QS_GET("content",Qs),
            world_notice:add(
                ?S2N(Id),
                ?S2N(PostTime),
                ?S2N(PlanTime),
                ?S2N(EndTime),
                ?S2N(Period),
                ?S2N(Status),
                ?S2B(Content)),
            Rt = 0;
        "-100"->
            Rt = -100

    end,
    Rt1 = ejson:encode(Rt),
    {200, [], Rt1}.
