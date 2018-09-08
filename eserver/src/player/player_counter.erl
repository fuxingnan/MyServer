%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.05.17
%%% @doc 玩家的各种计数器,基于进程辞典,持久化通过world_daily或db_counter完成
%%%  增加模块化参数SaveType: db表示数据库,world表示运行时数据(重启会丢失)
%%% 
%%% 注意：此处一定不能存元组，将编号存在counter.hrl中
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(player_counter).
-include("wg.hrl").
-include("game.hrl").
-include("counter.hrl").
-include("player_internal.hrl").

-export([new/1]).

-export([get/2, set/3, set_if_not_exist/2, inc/2, inc/3, dec/2, dec/3,
	list/1, clear/2, clear/1]).
-export([load/2, save/2]).

-define(COUNTER_KEY(Id), {ckey, SaveType, Id}).

%% tuple module
new(SaveType) ->
	{?MODULE, SaveType}.

%% @doc 获取某个counter
get(Id, {?MODULE, SaveType} = _This) ->
	case erlang:get(?COUNTER_KEY(Id)) of
		undefined ->
			0;
		Val when is_integer(Val) ->
			Val
	end.

%% @doc 设置某个counter
set(Id, Count, {?MODULE, SaveType} = _This) when is_integer(Count) ->
	erlang:put(?COUNTER_KEY(Id), Count),
	ok.

%% @doc 设置某个counter,仅当这个counter不存在时
%% 如记录某件事情是否做过,如果已经做过则不会再更新
set_if_not_exist(Id, {?MODULE, SaveType} = _This) ->
	case erlang:get(?COUNTER_KEY(Id)) of
		undefined ->
			set(Id, 1, _This);
		_ ->
			ok
	end.

%% @doc 某个计数器+1
inc(Id, {?MODULE, _SaveType} = _This) ->
	inc(Id, 1, _This).

%% @doc 某个计数器增加
inc(Id, N, {?MODULE, SaveType} = _This) ->
	Old = (?MODULE:new(SaveType)):get(Id),
	%?DEBUG(?_U("计数器:~p 原值:~p"), [Id, Old]),
	%?DEBUG(?_U("计数器:~p +1"), [Id]),
	New = Old + N,
	set(Id, New, _This),
	New.

%% @doc 某个计数器减1
dec(Id, {?MODULE, _SaveType} = _This) ->
	dec(Id, 1, _This).

%% @doc 某个计数器减少
dec(Id, N, {?MODULE, SaveType} = _This) ->
	Old = (?MODULE:new(SaveType)):get(Id),
	%?DEBUG(?_U("计数器:~p 原值:~p"), [Id, Old]),
	%?DEBUG(?_U("计数器:~p -1"), [Id]),
	New = Old - N,
	New2 = ?IF(New < 0, 0, New),
	set(Id, New2, _This),
	New2.

%% @doc 获取玩家的计数器列表
list({?MODULE, SaveType} = _This) ->
	[{K, V} || {{ckey, Type, K}, V} <- erlang:get(), Type =:= SaveType].

%% @doc 清除某个计数
clear(Key, {?MODULE, SaveType} = _This) ->
	erlang:erase(?COUNTER_KEY(Key)),
	ok.

%% @doc 清理玩家的所有计数
clear({?MODULE, SaveType} = _This) ->
	?DEBUG(?_U("**清除计数器"), []),
	[begin
		 erlang:erase(?COUNTER_KEY(K))
	 end || {K, _V} <- list(_This)],
	ok.

%% @doc 加载玩家计数器
load(#player{id = PlayerId}, {?MODULE, SaveType} = _This) ->
	case SaveType of
		?COUNTER_TYPE_DB ->
			List = db_counter:load(PlayerId),
			[set(K, V, _This) || {K, V} <- List],
			ok;
		?COUNTER_TYPE_DAILY ->
			case world_daily:get(?PLAYER_COUNTER_WORLD_DAILY_KEY(PlayerId)) of
				?NONE ->
					ok;
				List ->
					[set(K, V, _This) || {K, V} <- List],
					ok
			end
	end.

%% @doc 存储玩家计数器(玩家离线时)
save(#player{id = PlayerId}, {?MODULE, SaveType} = _This) ->
	?DEBUG(?_U("玩家:~p计数器:~p持久化"), [PlayerId, SaveType]),
	case SaveType of
		?COUNTER_TYPE_DB ->
			List = list(_This),
			?DEBUG(?_U("DB:~p"), [List]),
			%ok = db_counter:save(PlayerId, List);
			ok;
		?COUNTER_TYPE_DAILY ->
			List = list(_This)
			%ok = world_daily:set(?PLAYER_COUNTER_WORLD_DAILY_KEY(PlayerId), List)
	end.

%%----------------
%% internal API
%%----------------

%%------------
%% EUNIT Test
%%------------
-ifdef(EUNIT).

basic_test_() ->
	{inorder,
		[
		]}.

-endif.