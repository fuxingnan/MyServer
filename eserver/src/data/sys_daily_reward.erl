%%%-------------------------------------------------------------------
%%% @author fx
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%     元宝物品相关操作
%%% @end
%%% Created : 15. 七月 2015 下午3:23
%%%-------------------------------------------------------------------
-module(sys_daily_reward).
-author("fx").
-include("wg.hrl").
-include("game.hrl").
-include("sys_daily_reward.hrl").
-include("../src/player/player_internal.hrl").

%% API
-export([init/0, reload/0]).
-export([get/1,list/0]).

-define(TAB_Daily_Reward, 'daily_reward').
-define(DATA_FILE, "sys_daily_reward.data").

%% @doc 系统yuanbaoshop初始化
init() ->
    ?INFO(?_U("系统daily_reward初始化")),
    ok = create_table(),
    ok = load(),
    ok.

%% 重新加载数据
reload() ->
    ?INFO(?_U("重新加载系统daily_reward表")),
    load().


%% @doc 获取数据
list() ->
    ets:tab2list(?TAB_Daily_Reward).

%% @doc 获取某个物品信息
get(Id) ->
    case ets:lookup(?TAB_Daily_Reward, Id) of
        [] ->
            ?ERROR(?_U("daily:~p不存在"), [Id]),
            ?C2SERR("签到数据不存在");
        [E] ->
            E
    end.
%%---------------
%% internal API
%%---------------

%% 创建yuanbaoshop相关表
create_table()  ->
    ?TAB_Daily_Reward = ets:new(?TAB_Daily_Reward, [
        set, public, named_table,
        {keypos, #sys_daily_reward.id},
        ?ETS_CONCURRENCY
    ]),
    ok.

%% 加载数据
load()  ->
    {ok, List} = file:consult(game_path:data_file(?DATA_FILE)),
    true = ets:insert(?TAB_Daily_Reward, List),
    ok.
