-module(util).
-compile([export_all]).
-include("test.hrl").
-include("wg.hrl").
-include("db.hrl").

%% 建立db连接
setup_db() ->
    DBServer = ct:get_config(db_server),
    DBPort = ct:get_config(db_port),
    DBUser = ct:get_config(db_user),
    DBPass = ct:get_config(db_pass),
    DBName = ct:get_config(db_name),
    mysql:start(?MYSQL_GAME_POOL, DBServer, DBPort, DBUser, DBPass, DBName),
    {updated, _} = mysql:fetch(?MYSQL_GAME_POOL, "set names utf8;"),
    {ok, mysql_pool}.

%% 获取mysql连接对应进程
mysql_pid() ->
    whereis(mysql_dispatcher).

%% 停止数据库连接
stop_db() ->
    erlang:exit(mysql_pid(), kill).
