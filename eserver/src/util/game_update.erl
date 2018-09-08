%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 负责每次游戏更新不停服的必要处理,随每次更新不一样，代码也会不一样
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(game_update).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").
-include("counter.hrl").
-include("gate.hrl").
-include("world_api.hrl").

-define(WORLD_SUP, world_sup).

-export([all/0, all/1]).
-export([area/0, area/1]).
-export([world/0, world/1]).

%% @doc world和area都更新
all() ->
    all(true).

all(IsLoadData) ->
    % 加载数据
    reload_all_data(IsLoadData),
    % 更新world
    %world(false),
    % 更新area
    %area(false),

    io:format("Update Success :)\n", []),
    ok.



%% @doc world app的更新
world() ->
    world(true).


world(IsLoadData) ->
    % 加载数据
    reload_all_data(IsLoadData),

    % *******以下为更新**********

    %1 在world中添加启动光荣事迹(已经过期2012.3.30)
    %world_app:start_brilliant_record(?WORLD_SUP),
    
    ok.

%% @doc area app的更新
area() ->
    area(true).

area(IsLoadData) ->
    % 加载数据
    reload_all_data(IsLoadData),

    % *******以下为更新**********

    %1 重启所有地图的分布怪物(在有怪物分布变化的情况下)
    %game_misc:restart_mon_in_map(),

    %2 玩家数据称号结构变化
    %notify_title_update(),
    ok.


%%-------------------
%% 更新操作函数
%%-------------------

%% 通知当前在线玩家，改变称号的结构
%% @date 2012.3.30
notify_title_update() ->
    Ids = world_online:id_list(),
    [player_server:s2s_cast(PlayerId, mod_title, {service_update, ?NONE}) || PlayerId <- Ids],
    ok.


%%-----------------
%% 常用函数
%%-----------------

%% 加载所有数据
reload_all_data(IsReload) ->
    if
        IsReload ->
            game_misc:reload_config(),
            game_misc:reload_sys_data(),
            ok;
        true ->
            ok
    end.
