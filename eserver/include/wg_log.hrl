%%%----------------------------------------------------------------------
%%%
%%% @copyright wg
%%%
%%% @author songze.me@gmail.com
%%% @doc the log header
%%%
%%%----------------------------------------------------------------------
-ifndef(WG_LOG_HRL).
-define(WG_LOG_HRL, ok).

%% live方式启动在屏幕输出
-ifdef(LIVE).
-define(_U(Text), (Text)).
-else.
-define(_U(Text), Text). % 输出到文件
-endif.

    -ifdef(EUNIT).

        -define(EUNITFMT(T, F, D), (?debugFmt((T) ++ "(~p) " ++ (F), [self()] ++ (D)))).

        -define(DEBUG(F), ?EUNITFMT("D", F, [])).
        -define(DEBUG(F, D), ?EUNITFMT("D", F, D)).

        -define(INFO(F), ?EUNITFMT("I", F, [])).
        -define(INFO(F, D), ?EUNITFMT("I", F, D)).

        -define(WARN(F), ?EUNITFMT("*W", F, [])).
        -define(WARN(F, D), ?EUNITFMT("*W", F, D)).

        -define(ERROR(F), ?EUNITFMT("**E**", F, [])).
        -define(ERROR(F, D), ?EUNITFMT("**E**", F, D)).

        -define(CRITICAL(F), ?EUNITFMT("C", F, [])).
        -define(CRITICAL(F, D), ?EUNITFMT("C", F, D)).

    -else.
        -define(DEBUG(F), 
            wg_logger:debug_msg(?MODULE, ?LINE, F, [])).
        -define(DEBUG(F, D),
            wg_logger:debug_msg(?MODULE, ?LINE, F, D)).

        -define(INFO(F), 
            wg_logger:info_msg(?MODULE, ?LINE, F, [])).
        -define(INFO(F, D),
            wg_logger:info_msg(?MODULE, ?LINE, F, D)).

        -define(WARN(F),
            wg_logger:warning_msg(?MODULE, ?LINE, F, [])).
        -define(WARN(F, D), 
            wg_logger:warning_msg(?MODULE, ?LINE, F, D)).

        -define(ERROR(F),
            wg_logger:error_msg(?MODULE, ?LINE, F, [])).
        -define(ERROR(F, D),
            wg_logger:error_msg(?MODULE, ?LINE, F, D)).

        -define(CRITICAL(F), 
            wg_logger:critical_msg(?MODULE, ?LINE, F, [])).
        -define(CRITICAL(F, D), 
            wg_logger:critical_msg(?MODULE, ?LINE, (F, D)).

        -define(TEST(F),
            wg_logger:debug_msg(?MODULE, ?LINE, F, [])).
        -define(TEST(F, D),
            wg_logger:debug_msg(?MODULE, ?LINE, F, D)).

    -endif. %EUNIT

-endif. % WG_LOG_HRL
