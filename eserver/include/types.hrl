%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.19
%%% @doc 自定义类型定义
%%%
%%%----------------------------------------------------------------------
-ifndef(TYPE_HRL).
-define(TYPE_HRL, true).

-type id() :: non_neg_integer().
-type guid() :: binary().
-type code() :: 0..16#ffff.
-type keypos() :: pos_integer().
-type count() :: pos_integer().
-type pos() :: pos_integer().
-type lvl() :: 0..300.
-type type() :: non_neg_integer().
-type player_val() :: non_neg_integer().
-type ele() :: 1..4.
-type xy() :: non_neg_integer().
-type str() :: non_neg_integer().
-type agi() :: non_neg_integer().
-type flex() :: non_neg_integer().
-type fury() :: non_neg_integer().
-type fsoul() :: non_neg_integer().
-type hp() :: non_neg_integer().
-type mp() :: non_neg_integer().
-type title() :: non_neg_integer().
-type vigor() :: non_neg_integer().
-type glory() :: non_neg_integer().
-type success_point() :: non_neg_integer().
-type culture() :: non_neg_integer().
-type sex() :: 0..2.
-type career() :: 0..4.
-type realm() :: 0..3.
-type vip() :: 0..10.

-type timestamp() :: pos_integer().
-type timems() :: pos_integer().
-type rand() :: 0..10000.
-type ordset(T) :: [T].


-endif. % TYPE_HRL
