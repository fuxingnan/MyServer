%%%-------------------------------------------------------------------
%%% @author fx
%%% @copyright (C) 2015, <COMPANY>
%%% @doc 邮件逻辑模块
%%%
%%% @end
%%% Created : 07. 七月 2015 下午2:18
%%%-------------------------------------------------------------------
-module(mod_gm).
-author("fx").
-include("wg.hrl").
-include("game.hrl").
-include("../src/proto/proto.hrl").
-include("pbmessage_pb.hrl").
-include("lang.hrl").
-include("room.hrl").
%% API
-behaviour(gen_mod).
-export([start/0]).
%% gen_mod回调函数
-export([i/1, p/1, init/1, terminate/0,
    init_player/2, gather_player/1, terminate_player/1,
    handle_c2s/3, handle_timeout/2, handle_s2s_call/2, handle_s2s_cast/2]).

%% @doc 启动模块
start() ->
    gen_mod:start_module(?MODULE, []).

init([]) ->
    ok.

i(_Player)->
   ok.

p(Info)->
    ok.

terminate() ->
    ok.

terminate_player(_Player) ->
    ok.

init_player(#player{id = PlayerId,giveTimes = Times, lastGiveTime = LastRegisterTime, money = Money} = Player, ?NEW) ->

    Player;
init_player(Player, {?MIGRATE, ?NONE}) ->
    %?DEBUG(?_U("初始化mod-playrattr: ~p"), ?MIGRATE),
    Player.

gather_player(_Player) ->
    ?NONE.

handle_timeout({alert, State}, Player) ->
    {ok, Player};
handle_timeout({enter, _NewState}, Player) ->
    {ok, Player};
handle_timeout(_Event, Player) ->
    ?DEBUG(?_U("收到未知time消息:~p"), [_Event]),
    {ok, Player}.

handle_s2s_call(_Req, Player) ->
    ?DEBUG(?_U("未知的s2s_call请求: ~p"), [_Req]),
    {unknown, Player}.


handle_s2s_cast({recv_mail, _}, #player{} = Player) ->

    %do_receive_mail(Player, SenderType, SenderGuid, MailUpdate),

    {ok, Player}.



handle_c2s(#cg_gm_commond{} = _,_MsgId, #player{} = Player) ->
    ?INFO(?_U("收到face:~p"), [1]),

    {ok, Player};

handle_c2s(#cg_gm_player_recharge{account = Account} = _,_MsgId, #player{} = Player) ->

    {ok, Player}.





