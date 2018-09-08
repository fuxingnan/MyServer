%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 进行数据的加密解密
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(gate_crypt).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").

-export([encrypt/1]).
-export([decrypt/1]).

%% @doc 数据加密 FIXME
encrypt(Bin) ->
    Bin.

%% @doc 数据解密 FIXME
decrypt(Bin) ->
    Bin.


%%
%% EUNIT test
%%
-ifdef(EUNIT).


-endif.
