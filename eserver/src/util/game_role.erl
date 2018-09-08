%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 关于游戏中角色,如玩家,宠物,怪物相关的一些函数
%%%
%%%----------------------------------------------------------------------
-module(game_role).
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg.hrl").
-include("const.hrl").
-include("player.hrl").


-export([get/2, get_pos/1, get_pos/2,
    id/1, type/1]).

%% @doc 获取角色信息
get(?ROLE_TYPE_MON, Id) ->
    map_mon:get(Id);
get(?ROLE_TYPE_PLAYER, Id) ->
    player_server:get_not_dead(Id);
get(?ROLE_TYPE_PET, Id) ->
    player_server:get_fight_pet(Id).


%% @doc 获取角色位置信息
get_pos(#player{}) ->
    {todo}.


%% @doc 获取角色位置信息
get_pos(Type, Id) ->
    Role = ?MODULE:get(Type, Id),
    get_pos(Role).

%% @doc 获取角色id
id(#player{id = Id}) -> Id.

%% @doc 获取角色类型
type(#player{}) -> ?ROLE_TYPE_PLAYER.
