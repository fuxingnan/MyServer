%%%----------------------------------------------------------------------
%%%
%%% @author 付星
%%% @date  2014.04.19
%%% @doc 数据库相关定义文件
%%%
%%%----------------------------------------------------------------------
-ifndef(DB_HRL).
-define(DB_HRL, true).

%% 取自mysql.erl Line 169
-define(MYSQL_SERVER, mysql_dispatcher).

%% mysql conn pool名称
-define(MYSQL_CENT_POOL, mysql_cent_pool).
-define(MYSQL_GAME_POOL, mysql_game_pool).

-define(DB_CENT, (db:new(?MYSQL_CENT_POOL))).
-define(DB_GAME, (db:new(?MYSQL_GAME_POOL))).

-define(ALL, ["*"]).
-define(TIMEOUT, 20000).

%% 数据库操作
-define(DB_OP_ADD, 'add').
-define(DB_OP_DELETE, 'delete').
-define(DB_OP_UPDATE, 'update').

%% 数据库操作merge模块(用来实现数据的定期写入)
-define(DB_OP_MERGE(Table), (db_op_merge:new(Table))).

-endif. % DB_HRL
