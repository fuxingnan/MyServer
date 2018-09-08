%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 暂存的cd处理模块(非持久化),基于进程辞典
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(temp_cd).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").

-export([check/2, valid/2, set/1, set/2, get_diff/2]).
-compile([{inline, [get_last_time/1]}]).

%% @doc 检测cd是否合法,时间为ms
check(Type, Time) when Time > 0 ->
    %?DEBUG(?_U("检测cd:~p 时间间隔:~p"), [Type, Time]),
    wg_util:now_ms() - get_last_time(Type) > Time.

%% @doc 检测cd是否合法,不合法抛出异常
valid(Type, Time) ->
    ?IF(check(Type, Time), ok, ?C2SERR(?E_UNKNOWN)).

%% @doc 设置cd时间
set(Type) ->
    set(Type, wg_util:now_ms()).

%% @doc 设置cd时间
set(Type, Time) ->
    put(Type, Time),
    ok.

%% @doc 获取与上次时间之间的差距
get_diff(Type, Now) ->
    Now - get_last_time(Type).

%%----------------
%% internal API
%%----------------

%% 获取上次cd时间
get_last_time(Type) ->
    case get(Type) of
        undefined ->
            0;
        T when is_integer(T) ->
            T
    end.

%%------------
%% EUNIT Test
%%------------
-ifdef(EUNIT).

basic_test_() ->
    {inorder, 
    [
        ?_assertEqual(true, check("test_cd_1", 1)),
        ?_assertEqual(true, check("test_cd_1", 100000)),

        ?_assertEqual(ok, set("test_cd_1")),
        ?_assertEqual(false, check("test_cd_1", 1000)),

        ?_assertEqual(ok, set("test_cd_1", 10000)),
        ?_assertEqual(true, check("test_cd_1", 1))
    ]}.

-endif.
