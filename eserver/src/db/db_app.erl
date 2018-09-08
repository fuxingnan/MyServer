%%%----------------------------------------------------------------------
%%%
%%% @author 付星
%%% @date  2014.04.18
%%% @doc 独立的数据库连接管理app，比较好的控制连接的建立和中断。
%%%     因为在同一个app中同一个sup下，当app停止时无法判断数据是否
%%%     全部flush到db
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(db_app).
-author("276300120@qq.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").
-include("db.hrl").

-behaviour(application).
-behaviour(supervisor).

-export([start/0, stop/0]).
-export([start/2, stop/1]).
-export([init/1]).
-export([i/0]).

%% 内部使用!
-export([mysql_start_llink/0]).

%% @doc start the application from the erl shell
start() ->
    wg_loglevel:set(?LOG_LEVEL),
    ensure_apps(),
    application:start(db_app).

%% @doc 结束db app
stop() ->
    application:stop(db_app).

%% @doc the application start callback
-spec start(Type :: any(), Args :: any()) ->
    {ok, pid()}.
start(_Type, _Args) ->
    ?DEBUG("start the supervisor sup ~n", []),
    {ok, Sup} = supervisor:start_link({local, db_sup}, ?MODULE, []),

    ?INFO(?_U("启动config server")),
    ok = game_misc:start_config_server(Sup),
    ok = game_misc:start_time_cache(Sup),

    ?INFO(?_U("连接mysql数据库")),
    ok = start_mysql_conn(Sup),

    ?INFO(?_U("初始化系统数据"), []),
    ok = game_misc:init_sys_data(),
    {ok, Sup}.
    
%% @doc the application  stop callback
stop(_State) ->
    ok.

%% @doc supervisor callback
init(_Args) ->
    ?DEBUG("init supervisor~n", []),
    Stragegy = {one_for_one, 10, 10},
    {ok, {Stragegy, []}}.

%% @doc sql统计信息
i() ->
    ?DB_GAME:i().

%%---------------
%% internal API
%%---------------

ensure_apps() ->
    ok = game_misc:handle_start_app(application:start(sasl)),
    ok.

%% 与msyql建立连接
start_mysql_conn(Sup) ->
    Spec = 
    {?MYSQL_SERVER, {?MODULE, mysql_start_llink, []},
        permanent, 100, worker, []},
    case catch supervisor:start_child(Sup, Spec) of
        {error, {already_started, _}} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("连接数据库失败:~p!"), [_Reason]),
            {error, _Reason};
        {ok, _} ->
            ?INFO(?_U("与中心数据库连接成功")),
            ok
    end.

%% 获取数据库配置信息
db_conf(Conf) ->
    User = proplists:get_value(db_user, Conf),
    Pass = proplists:get_value(db_pass, Conf),
    Name = proplists:get_value(db_name, Conf),
    Server = proplists:get_value(db_server, Conf),
    Port = proplists:get_value(db_port, Conf),
    Pool = proplists:get_value(db_pool, Conf),
    {User, Pass, Name, Server, Port, Pool}.

%% 用来启动mysql的start_link
mysql_start_llink() ->
    % 获取数据库连接信息
    Conf = ?CONF(db_game),
    Pool = ?MYSQL_GAME_POOL,
    {User, Pass, Name, Server, Port, PoolCount} = db_conf(Conf),

    ?INFO(?_U("启动与游戏数据库连接 user:~p name:~p pwd:~p server:~p port:~p"),
        [User, Name, Pass, Server, Port]),
    case mysql:start_link(Pool, Server, Port, User, Pass, Name,  fun log/4, utf8) of
        {ok, Pid} ->
            LTemp =
            case PoolCount > 1 of
                true ->
                    lists:duplicate(PoolCount, dummy);
                false ->
                    [dummy]
            end,

            % 启动conn pool
            [begin
                {ok, _ConnPid} = mysql:connect(Pool, Server, Port, User, Pass, Name, utf8, true)
            end || _ <- LTemp],
            ?INFO(?_U("与游戏数据库连接成功")),
            {ok, Pid};
        {error, {already_started, _}} ->
            ignore;
        {error, _Reason} ->
            ?ERROR(?_U("连接数据库失败:~p!"), [_Reason]),
            {error, _Reason}
    end.

%% 定义mysql使用的log fun
-ifdef(TEST).
log(_Module, _Line, debug, _FormatFun) ->
    ok;
log(Module, Line, _Level, FormatFun) ->
    {Format, Arguments} = FormatFun(),
    wg_logger:info_msg(Module, Line, Format, Arguments).
-else.
log(_Module, _Line, _Level, _FormatFun) ->
    ok.
-endif.
