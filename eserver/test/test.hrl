-ifndef(TEST_HRL).
-define(TEST_HRL, true).
-include("wg.hrl").

-define(P(F), 
    fun() ->
        V = F,
        %?INFO("~n~80..-s\ncall\t:\t~s~nresult\t:\t~p~n~80..=s~n~n", ["-", ??F, V, "="]),
        ct:log(default, "~n~80..-s\ncall\t:\t~s~nresult\t:\t~p~n~80..=s~n~n", ["-", ??F, V, "="]),
        V
    end()).

-endif. % TEST_HRL
