%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 关于游戏中的文件路径
%%%
%%%----------------------------------------------------------------------
-module(game_path).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").

-export([root_path/0]).
-export([data_path/0, data_file/1]).
-export([conf_path/0, conf_file/1]).
-export([runtime_path/0]).

%% 关于data路径
-define(DATA_PATH, "data").
-define(DATA_EXT, ".data").

%% 关于conf路径
-define(CONF_PATH, "etc").
-define(CONF_EXT, ".conf").

%% 游戏部署的路径
root_path() ->
    case os:getenv("GAME_PATH_ROOT") of
        false ->
            Beam = code:which(?MODULE),
            filename:dirname(filename:dirname(Beam));
        Path ->
            Path
    end.

%% @doc 获取数据文件路径
data_path() ->
    case os:getenv("GAME_PATH_DATA") of
        false ->
            ?DATA_PATH;
        "undefined" ->
            ?DATA_PATH;
        Path ->
            Path
    end.

%% @doc 获取数据文件路径
data_file(FileName) ->
    FileName2 =
    case filename:extension(FileName) of
        "" ->
            FileName ++ ?DATA_EXT;
        _ ->
            FileName
    end,
    filename:join([data_path(), FileName2]).

%% @doc 获取配置文件路径
conf_path() ->
    case os:getenv("GAME_PATH_CONF") of
        false ->
            ?CONF_PATH;
        "undefined" ->
            ?CONF_PATH;
        Path ->
            Path
    end.

%% @doc 获取配置文件全路径
conf_file(FileName) ->
    FileName2 =
    case filename:extension(FileName) of
        "" ->
            FileName ++ ?CONF_EXT;
        _ ->
            FileName
    end,
    filename:join([conf_path(), FileName2]).

%% @doc 获取运行时数据存储路径(如副本计数)
runtime_path() ->
    Dir = ?CONF(runtime_dir, "/data/dhsj/runtime"),
    filelib:ensure_dir(Dir ++ "/"),
    Dir.

%%------------------
%% internal API
%%------------------

%%------------------
%% Eunit TEST
%%------------------
-ifdef(EUNIT).

basic_test_() ->
    OldGamePathData = os:getenv("GAME_PATH_DATA"),
    {inorder,
    [
        ?_assertEqual(true, os:putenv("GAME_PATH_DATA", "undefined")),
        ?_assertEqual("data", data_path()),
        ?_assertEqual("data/hello.data", data_file("hello")),
        ?_assertEqual("data/hello.data", data_file("hello.data")),
        ?_assertEqual("data/hello.erl", data_file("hello.erl")),

        ?_assertEqual(true, os:putenv("GAME_PATH_DATA", "/var/")),
        ?_assertEqual("/var/", data_path()),
        ?_assertEqual("/var/hello.data", data_file("hello")),
        ?_assertEqual("/var/hello.data", data_file("hello.data")),
        ?_assertEqual("/var/hello.erl", data_file("hello.erl")),

        % 恢复旧的数据
        ?_assertEqual(true, os:putenv("GAME_PATH_DATA", OldGamePathData))
    ]}.
    
-endif.
