%%%-------------------------------------------------------------------
%%% Module  : lib_words_ver
%%% Author  : 
%%% Description : 敏感词处理
%%%-------------------------------------------------------------------
-module(words_verify).
-include("wg_log.hrl").

%%--------------------------------------------------------------------
%% Include files
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% External exports
-export([words_verify/1, words_filter/1]).
%%====================================================================
%% External functions
%%====================================================================
%% 敏感词处理
words_filter(Words_for_filter) -> 
	Words_List = data_words:get_words_verlist(),
	binary:bin_to_list(
        lists:foldl(fun(Kword, Word)->
                           re:replace(Word, Kword, "*", [global, caseless, {return, binary}])
                   end, Words_for_filter, Words_List)).

%% 是否含有敏感词
words_verify(Words_for_ver) ->
	Words_List = data_words:get_words_verlist(),
    try
        lists:foldl(
        fun(Word,Acc) ->
            %?DEBUG(?_U("fuck: ~p,~p, ~p~n"), [Words_for_ver, Word, Acc+1]),
            case re:run(Words_for_ver, Word, [unicode]) of
                nomatch -> 
                    Acc+1;
                _-> 
                    throw(false)
            end
        end, 0,Words_List),
        true
    catch
        throw:false ->
            false
    end.
