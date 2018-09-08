%%%----------------------------------------------------------------------
%%%
%%% @copyright wg
%%%
%%% @author songze.me@gmail.com
%%% @doc httpd types define file
%%% @end
%%%
%%%----------------------------------------------------------------------
-ifndef(WG_HTTPD_HRL).
-define(WG_HTTPD_HRL, true).

-type http_code() :: pos_integer().                                                             
-type header_list() :: [{binary() | string(), binary() | string()}].   

%% macros for get query string
-define(QS_GET(K, QS), proplists:get_value(K, QS)).
-define(QS_GET(K, QS, D), proplists:get_value(K, QS, D)).

-define(HTTP_BADARG, http_badarg).
-define(RETURN_HTTP_BADARG, exit(http_badarg)).

-define(HTTP_CONTENT_TYPE, <<"Content-Type">>).

-endif. % WG_HTTPD_HRL
