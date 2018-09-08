-ifndef(GEN_BASE_HRL).
-define(GEN_BASE_HRL, true).

-include("wg.hrl").
-include("db.hrl").
-include("const.hrl").

-define(NL, "\n").
-define(P(D), io:format(D++"\n")).
-define(PNL(D), io:format(D)).
-define(P(F, D), io:format(F++"\n", D)).
-define(PNL(F, D), io:format(F, D)).

-endif. % GEN_BASE_HRL
