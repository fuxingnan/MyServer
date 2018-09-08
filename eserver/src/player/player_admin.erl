%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% 针对玩家的后台及定时任务对应的函数
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(player_admin).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").
-include("counter.hrl").
-include("gate.hrl").
-include("player_internal.hrl").
-include("world_api.hrl").
-include("../src/proto/proto.hrl").

%% 后台使用及定时任务使用
-export([admin_ban_chat/2, admin_enable_chat/1, admin_ban_acc/2, admin_enable_acc/1,
        admin_inc_exp/2, admin_clear_dungeon_count/2, admin_del_goods/2, 
        admin_ctrl_box/1, admin_payment/2, admin_set_vip_lvl/2
        ]).

%% @doc 充值
%% 1,记录一条充值日志
%% 2,玩家是否在线?
%%  2a,在线,直接调用进行充值
%%  2b,离线,从数据库获取玩家原金币,增加金币,计算vip等级,计算单次充值奖励
%%   2b-1,判断玩家是否在线?
%%     2b-1-1,在线,判断金币是否合法
%%     2b-1-2,离线,充值成功
%% 3,以上操作未发生异常,则充值成功,否则失败
admin_payment(Id, Gold) when is_integer(Gold), Gold > 0 ->
    % 1
    %ok = game_log:payment(Id, Gold),
    % 2
    try
        case player_server:is_online(Id) of
            true ->
                % 2a
                ok = player_server:s2s_call(Id, mod_player, {payment, Gold}),
                ok = player_server:s2s_call(Id, mod_rebate, {payment, Gold});
            false ->
                % 2b
                {GoldOld, TotalPayment} = db_player:get_gold_payment(Id),
                TotalPayment2 = TotalPayment + Gold,
                GoldNew = GoldOld + Gold,
                VipLvl = player_vip:calc_vip_lvl(TotalPayment2),
                ok = db_player:set_gold_vip_payment(Id, GoldNew, VipLvl, TotalPayment2),
                % 计算单次充值奖励对应的counter号
                Counter = mod_rebate:calc_gold_counter(Gold),
                ok = db_counter:inc_counter_x(Id, Counter),                
                % 2b-1
                case player_server:is_online(Id) of
                    true ->
                        % 2b-1-1
                        Player = player_server:get_state(Id),
                        #player_priv{gold = PlayerGold} = player_internal:get_priv(Player),
                        ?ASSERT(PlayerGold =:= GoldNew),
                        ok;
                    false ->
                        % 2b-1-2
                        ok
                end
        end
    catch
        _Type:_Reason ->
            % 3b
            ?ERROR(?_U("玩家:~p充值失败!gold:~p ~p:~p"), [Id, Gold, _Type, _Reason]),
            ?C2SERR(?E_UNKNOWN)
    end,
    ok.

%% 设置玩家vip等级(玩家必须在线)
admin_set_vip_lvl(Id, VipLvl) ->
    ?IF(player_server:is_online(Id),
            player_server:s2s_call(Id, mod_player, {set_vip_lvl, VipLvl}),
            ?C2SERR(?E_UNKNOWN)).

%% @doc 禁言
%% 1,通知玩家
%% 2,mnesia中添加数据
admin_ban_chat(Id, EndTime) when is_integer(Id) ->
    ok = gm_ctrl:add_chat_ban(EndTime, Id),
    ok = player_server:s2s_cast(Id, mod_chat, ban_chat),
    ok.

%% @doc 解除禁言
admin_enable_chat(Id) ->
    ok = player_server:s2s_cast(Id, mod_chat, {ban_chat, false}),
    gm_ctrl:delete_chat_ban(Id),
    ok.

%% @doc 帐号封禁
admin_ban_acc(Id, EndTime) ->
    % 先踢出玩家
    ok = player_server:stop(Id, kick),
    ok = gm_ctrl:add_login_ban(EndTime, Id),
    ok.

%% @doc 帐号解禁
admin_enable_acc(Id) ->
    gm_ctrl:delete_login_ban(Id),
    ok.

%% @doc 增加玩家经验
admin_inc_exp(Id, Exp) ->
    ?IF(player_server:is_online(Id),
        player_server:s2s_call(Id, mod_player, {add_exp, Exp}),
        ?C2SERR(?E_UNKNOWN)).

%% @doc 玩家副本计数清零
admin_clear_dungeon_count(Id, MapId) ->
    case player_server:is_online(Id) of
        true ->
            player_server:s2s_call(Id, mod_dungeon, {clear_count, MapId});
        false ->
            player_counter_util:clear_from_world_daily(Id, ?DUNGEON_COUNT_KEY(MapId)),
            % 确保玩家没有在线
            ?ASSERT(not player_server:is_online(Id)),
            ok
    end.

%% @doc 删除玩家背包某个位子物品
admin_del_goods(Id, PosId) ->
    ?IF(player_server:is_online(Id),
        player_server:s2s_call(Id, mod_goods, {del_goods, PosId}),
        ?C2SERR(?E_UNKNOWN)).

%% 开宝箱功能控制
admin_ctrl_box(Ctrl) when is_integer(Ctrl) ->
    world_data:set(?CTRL_BOX_VISIBLE, Ctrl),
    Ids = world_online:id_list(),
    [ok = player_server:s2s_call(Id, mod_player, {ctrl_box, Ctrl}) || Id <- Ids],
    ok.
