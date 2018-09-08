%%%----------------------------------------------------------------------
%%%
%%% @author huang.kebo@gmail.com
%%% @date  2015.08.02
%%% @doc 帐号相关的逻辑
%%% 与player_server
%%% *注意*确保此模块的执行与player_server在同一进程！
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(mod_acc).
-author("kebo").
-include("wg.hrl").
-include("game.hrl").
-include("game_log.hrl").
-include("../src/proto/proto.hrl").
-include("pbmessage_pb.hrl").

-behaviour(gen_mod).


-export([start/0]).

%% gen_mod回调函数
-export([i/1, p/1, init/1, terminate/0,
    init_player/2, gather_player/1, terminate_player/1,
    handle_c2s/3, handle_timeout/2, handle_s2s_call/2, handle_s2s_cast/2]).

%% 消息相关

%%
start() ->
    gen_mod:start_module(?MODULE, []).

%% @doc 运行信息
i(Player) ->
    ok.

%% @doc 运行信息字符
p(Info) ->
   ok.

%% 初始化
init([]) ->
    ok.

%% 结束
terminate() ->
    ok.

%% @doc 玩家进程初始化
init_player(#player{} = Player, ?NEW) ->
    Player;
init_player(#player{} = Player, {?MIGRATE, ?NONE}) ->
    Player.


%% @doc 玩家数据收集(迁移使用)
gather_player(_Player) ->
    ?NONE.

%% @doc 玩家结束
terminate_player(_Player) ->
    ok.
%% @doc 玩家退出游戏

%%handle_c2s(#cg_req_changename{nametype = Type} = Msg, _MsgId, #player{id = Id} = Player) ->
%%    Name = Msg#cg_req_changename.changename,
%%    ?DEBUG("玩家:~p 修改名称:~p 类型为:", [Id, Name, Type]),
%%    {Code, Player2} = change_name(Player, Type, Name),
%%    MsgId = ?PROTO_CONVERT({?MODULE, gc_ret_changename}),
%%    Msg = #gc_ret_changename{
%%        nametype = Type,
%%        retcode = Code
%%    },
%%    ?S2C_SEND_MERGE:player(Id, MsgId, Msg),
%%    {ok, Player2};
handle_c2s(_Msg, _MsgId, Player) ->
    {ok, Player}.

handle_timeout(_Event, Player) ->
    ?DEBUG(?_U("收到未知time消息:~p"), [_Event]),
    {ok, Player}.

handle_s2s_call(_Req, Player) ->
    ?ERROR(?_U("未知的s2s_call请求: ~p"), [_Req]),
    {unknown, Player}.

%% @doc 处理s2s cast请求
handle_s2s_cast(_Req, Player) ->
    ?DEBUG(?_U("未知的s2s_cast请求: ~p"), [_Req]),
    {ok, Player}.




