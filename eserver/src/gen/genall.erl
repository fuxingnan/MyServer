%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 调用所有的gen_*.erl模块，生成代码
%%%
%%%----------------------------------------------------------------------
-module(genall).
-include("genbase.hrl").
-include("wg.hrl").
-include("db.hrl").
-include("common.hrl").

-export([gen/1, gen/3, gen_filter_word/1, gen_card/2]).

%% 生成协议
gen(proto) ->
    gen_proto:gen().

%% 生成指定的数据
gen(data, all, LogLevel) ->
    do_gen_data(all, LogLevel);
gen(data, Table, LogLevel) ->
    do_gen_data(Table, LogLevel).

%% 生成敏感词过滤
gen_filter_word(LogLevel) ->
    wg_loglevel:set(LogLevel),
    case catch gen_filter_word:gen() of
        ok ->
            ?WARN(?_U("敏感词数据生成成功! ^_^\n")),
            ?EXIT(0);
        false ->
            ?ERROR(?_U("敏感词数据生成失败! -_-!\n")),
            ?EXIT(1)
    end.

%% 生成各种卡
gen_card(Type, N) when is_integer(Type), is_integer(N), N > 0 ->
    wg_loglevel:set(5),
    % 启动配置文件
    ok = start_config_server(),
    % 启动数据库连接
    ok = setup_db_conn_game(),
    N2 = erlang:min(200000, N),
    {ok, Cards} = do_gen_card(Type, N2),
    CardsStr = string:join(Cards, "\r"),    % 为了windows
    {{Y, M, D}, _} = erlang:localtime(),
    FileName = lists:concat(["card-", Type, "-", Y, "-", M, "-", D, ".txt"]),
    ok = file:write_file(FileName, CardsStr).

%%--------------
%% Internal API
%%--------------

%% 生成数据
do_gen_data(Type, LogLevel) when LogLevel >= 1 andalso LogLevel =< 5 ->
    % 设置log等级
    wg_loglevel:set(LogLevel),
    % 启动配置文件
    ok = start_config_server(),
    % 启动数据库连接
    ok = setup_db_conn_cent(),
    % 启动http
    ok = inets:start(),

    Mods = get_data_mod_by_type(Type),
    Ret =
        lists:all(
        fun(Mod) ->
                case catch Mod:gen() of
                    ok ->
                        ?DEBUG(?_U("生成数据模块:~p"), [Mod]),
                        true;
                    _Reason ->
                        ?ERROR(?_U("~p 生成数据错误:~p"), [Mod, _Reason]),
                        false
                end
        end, Mods),
    case Ret of
        true ->
            ?WARN(?_U("生成数据成功! ^_^\n")),
            ?EXIT(0);
        false ->
            ?ERROR(?_U("生成数据失败! -_-!\n")),
            ?EXIT(1)
    end.

%% 根据要生成的数据,获取对应的模块
get_data_mod_by_type(all) ->
    % 获取所有的gen_*.erl模块
    All = [list_to_atom(filename:basename(File, ".erl"))
        || File <- filelib:wildcard("src/gen/gen_*.erl")] -- [gen_filter_word],
    lists:sort(All);
get_data_mod_by_type(Type) ->
    File = "src/gen/gen_" ++ ?A2S(Type) ++ ".erl",
    case filelib:is_file(File) of
        true ->
            ok;
        false ->
            io:format("数据:~s对应的生成文件不存在!\n", [Type]),
            ?EXIT(1)
    end,
    [list_to_atom(filename:basename(File, ".erl"))].

%%---------
%% 关于卡
%%---------

-define(CARD_TABLE, "card").

%% 生成卡
do_gen_card(Type, N) ->
    do_gen_card(Type, N, []).

do_gen_card(_Type, 0, Acc) ->
    {ok, Acc};
do_gen_card(Type, N, Acc) ->
    Id = wg_util:guid_str(wg_util:guid()),
    case ?DB_GAME:insert(?CARD_TABLE, [Id, Type, 0, 0]) of
        {updated, 1} ->
            do_gen_card(Type, N - 1, [Id | Acc]);
        {error, _Reason} ->
            ?WARN(?_U("卡号:~p已经存在"), [Id]),
            do_gen_card(Type, N, Acc)
    end.
    
%%----------
%% 其它函数
%%----------

%% 启动配置文件服务
start_config_server() ->
    FilePath = game_path:conf_file("gh.conf"),
    ?INFO(?_U("启动wg_config服务:~ts"), [FilePath]),
    {ok, _} = wg_config:start_link(?CONF_SERVER, FilePath),
    % 设置sql_statis为false
    wg_config:set(?CONF_SERVER, sql_statis, false),
    ok.

%% 建立数据库连接
setup_db_conn_cent() ->
    % 中心数据库
    Conf = 
    [{db_user, "fxgame"},
    {db_pass, "fuxing"},
    {db_name, "Fx_Db"},
    {db_server, "192.168.1.116"},
%    {db_server, "127.0.0.1"}, % 临时修改！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
    {db_port, 3306}],
    setup_db_conn(Conf, ?MYSQL_CENT_POOL).

setup_db_conn_game() ->
    Conf = ?CONF(db_game),
    setup_db_conn(Conf, ?MYSQL_GAME_POOL).

setup_db_conn(Conf, PoolName) ->
    % 与中心数据库建立一个连接
    User = proplists:get_value(db_user, Conf),
    Pass = proplists:get_value(db_pass, Conf),
    Name = proplists:get_value(db_name, Conf),
    Server = proplists:get_value(db_server, Conf),
    Port = proplists:get_value(db_port, Conf),
    io:format("~p ~p ~p ~p ~p", [User, Pass, Name, Server, Port]),
    case mysql:start_link(PoolName, Server, Port, User, Pass, 
            Name, fun log/4, utf8) of
        {ok, _} ->
            ?INFO(?_U("与~p数据库连接成功"), [PoolName]),
            ok;
        {error, {already_started, _}} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("连接数据库失败:~p!"), [_Reason]),
            ?EXIT(1)
    end.

%% 定义mysql使用的log fun
log(_Module, _Line, _Level, _FormatFun) ->
    ok.
