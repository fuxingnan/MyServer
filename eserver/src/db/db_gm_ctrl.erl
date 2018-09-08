%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 后台控制，包括禁ip，禁登录，禁言
%%% @end
%%%
%%%----------------------------------------------------------------------

-module(db_gm_ctrl).
-author("huang.kebo@gmail.com").

-include("wg.hrl").
-include("db.hrl").
-include("common.hrl").
-include("errno.hrl").

-export([list/0]).

%% 数据表名称
-define(TABLE, "gm_ctrl").

%% @doc 获取被禁列表
list() ->
    case ?DB_GAME:select(?TABLE, ["*"], where()) of
        {error, _Reason} ->
            ?ERROR(?_U("获取被禁列表失败:~p"), [_Reason]),
            ?C2SERR(?E_DB);
        {selected, _Fields, Rows} ->
            [[CtrlType, StartTime, EndTime, Target] || [_Id, CtrlType, StartTime, EndTime, Target] <- Rows]
    end.

%%-------------------
%% Internal API
%%-------------------

%% 查询条件
where()->
    Now = wg_util:now_sec(),
    [" begin_time < ",db_util:encode(Now)," and end_time >",db_util:encode(Now)].
