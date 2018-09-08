%%%----------------------------------------------------------------------
%%%
%%% @copyright wg
%%%
%%% @author songze.me@gmail.com
%%% @doc wg header file used by user
%%%
%%%----------------------------------------------------------------------
-ifndef(WG_HRL).
-define(WG_HRL, true).

-ifdef(EUNIT).
-include_lib("eunit/include/eunit.hrl").
-endif.

-include("wg_log.hrl").

%% define the user token 
-record(wg_token, {
        user = <<>> :: binary(),        % user
        pwd = <<>> :: binary(),         % pwd 
        data :: any(),                  % user define data
        time :: any()                   % request time
    }).
-type wg_token() :: #wg_token{}.

%% Print in standard output
-define(PRINT(Format, Args),
    io:format(Format, Args)).

%% syntax similar with ?: in c
-ifndef(IF).
-define(IF(C, T, F), (case (C) of true -> (T); false -> (F) end)).
-endif.

%% 如果条件为true就执行，否则返回false
-ifndef(IF2).
-define(IF2(C, T), ((C) andalso (T))).
-endif.


%% some convert macros
-define(B2S(B), (binary_to_list(B))).
-define(S2B(S), (list_to_binary(S))).
-define(N2S(N), integer_to_list(N)).
-define(S2N(S), list_to_integer(S)).
-define(N2B(N), ?S2B(integer_to_list(N))).
-define(B2N(B), list_to_integer(?B2S(B))).

-define(A2S(A), atom_to_list(A)).
-define(S2A(S), list_to_atom(S)).
-define(S2EA(S), list_to_existing_atom(S)).

%% 断言
%%-ifdef(TEST).
-define(ASSERT(Con), (
        case Con of
            true ->
                ok;
            false ->
                error({assert, ??Con})
        end)).
%%-else.
%%-define(ASSERT(Con), ok).
%%-endif.

%%
%% 当进行dialyzer时用来屏蔽ets concurrency_read属性
%%
%%-ifdef(DIALYZER).
%-define(ETS_CONCURRENCY, {write_concurrency, true}).
-define(ETS_CONCURRENCY, {read_concurrency, true}).
%-else.
%-define(ETS_CONCURRENCY, {read_concurrency, true}, {write_concurrency, true}).
%-endif.

%% 退出
-define(EXIT(C), timer:sleep(100), init:stop(C)).

%% 当前时间
-ifndef(TEST).
-define(NOW_SEC, (wg_util:now_sec())).
-define(NOW_MS, (wg_util:now_ms())).
-else.
-define(NOW_SEC, 1000000).
-define(NOW_MS, 1000000).
-endif.

%% proplists中获取某个key对应value
-define(PLIST_VAL(Key, List), proplists:get_value(Key, List)).
-define(PLIST_VAL(Key, List, Default), proplists:get_value(Key, List, Default)).

-endif. % WG_HRL
