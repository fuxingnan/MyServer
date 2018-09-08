%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc   gen_mod behaviour
%%%     所有的mod都运行于player_server进程，用来完成游戏各种子系统
%%% 流程如下:
%%%     gen_mod:start()
%%%     gen_mod:start_module(Module, Opts, Seq)
%%%     Module:init()
%%%     Module:handle_c2s
%%%     gen_mod:stop_module(Module)
%%%     Module:terminate()
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(gen_mod).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").
-include("player_internal.hrl").

%% 外部接口
-export([start/0, i/0, i/1, p/1, stop/0]).
-export([module_list/0]).

-export([start_module/2, stop_module/1]).

%% 关于timer
-export([timer_list/0, 
        is_timer_exist/2, is_timer_exist/3,
        start_timer/3, start_timer/4, 
        cancel_timer/2,  cancel_timer/3,
        is_absolute_timer_exist/2, start_absolute_timer/3, cancel_absolute_timer/2
        ]).
%% player_server内部使用
-export([on_mod_timeout/2]).
-export([gather_player/1]).

%% 关于数据同步
-export([start_data_sync/3, handle_timeout/2, get_last_data_sync_time/1]).

-export([behaviour_info/1]).
    
-define(TABLE, gen_modules).

%% 关于timer
-define(TIMER_REF(T, Loop), {'!gen_mod_timer_ref', T, Loop}).
-define(TIMER_HANDLER(T, Loop), {'!gen_mod_timer_handler', T, Loop}).
-define(ABSOLUTE_TIME_REF(T, Mod), {'!gen_mod_absolute_timer_ref', T, Mod}).

-ifdef(TEST).
-compile([export_all]).
-endif.

behaviour_info(callbacks) ->
    [
    {i, 1},                 % 获取相关信息
    {p, 1},                 % 相关信息字符串描述
    {init, 1},              % 初始化mod
    {terminate, 0},         % 停止mod
    {init_player, 2},       % 某个玩家初始化,返回#player
    {gather_player, 1},     % 玩家数据收集(迁移使用)
    {terminate_player, 1},  % 某个玩家结束
    {handle_c2s, 3},        % 处理c2s请求
    {handle_timeout, 2},    % 处理timer
    {handle_s2s_call, 2},   % 处理s2s call请求
    {handle_s2s_cast, 2}    % 处理s2s cast请求
    ];
behaviour_info(_Other) ->
    undefined.

%% @doc 启动gen_mod
start() ->
    ?TABLE = ets:new(?TABLE,
        [public, set, named_table, {keypos, 1}]),

    ok.

%% @doc gen_mon本身信息
i() ->
    ets:tab2list(?TABLE).

%% @doc info
i(Player) ->
    All = ets:tab2list(?TABLE),
    [begin
        case catch Mod:i(Player) of
            {'EXIT', _} ->
                {Mod, []};
            Val ->
                %?DEBUG(?_U("模块:~p i信息:~p"), [Mod, Val]),
                {Mod, Val}
        end
    end || {Mod, _Opts} <- All].

%% @doc 信息字符串
p(Info) ->
    All = ets:tab2list(?TABLE),
    [begin
        Val = ?PLIST_VAL(Mod, Info),
        ?ASSERT(Val =/= undefined),
        Ret = Mod:p(Val),
        case is_list(Ret) of
            true ->
                Ret;
            false ->
                ?ERROR(?_U("~w:p/1返回的数据不是字符串!"), [Mod]),
                ""
        end
    end || {Mod, _Opts} <- All].

%% @doc 停止gen_mod,同时停止所有mod
stop() ->
    L = ets:tab2list(?TABLE),
    [stop_module(Module) || {Module, _Opts} <- L],
    true = ets:delete(?TABLE),
    ok.

%% @doc 获取module list
module_list() ->
    [Module || {Module, _} <- ets:tab2list(?TABLE)].

%% @doc 启动module
start_module(Module, Opts) ->
    ?DEBUG(?_U("启动模块:~p 参数:~p"), [Module, Opts]),
    ok = game_hooks:add(?HOOK_INIT_PLAYER, Module, init_player),  
    ok = game_hooks:add(?HOOK_TERMINATE_PLAYER, Module, terminate_player),  
    try 
        Reply = Module:init(Opts),
        true = ets:insert_new(?TABLE, {Module, Opts}),
        Reply
    catch Class:Reason ->
        ?ERROR(?_U("启动模块失败:~p 参数:~p~n原因:~p:~p"),
            [Module, Opts, Class, Reason]),
        ok = game_hooks:delete(?HOOK_INIT_PLAYER, Module, init_player),
        ok = game_hooks:delete(?HOOK_TERMINATE_PLAYER, Module, terminate_player),  
        erlang:raise(Class, Reason, erlang:get_stacktrace())
    end.

%% @doc 停止module
stop_module(Module) ->
   % ?DEBUG(?_U("停止模块:~p"), [Module]),
    try 
        Module:terminate(),
        ets:delete(?TABLE, Module),
        ok
    catch Class:Reason ->
        ?ERROR(?_U("停止模块:~p错误~n ~p:~p"), [Module, Class, Reason]),
        erlang:raise(Class, Reason, erlang:get_stacktrace())
    end.

%% @doc 获取timer列表
timer_list() ->
    [{Time, Loop, List} || {?TIMER_HANDLER(Time, Loop), List} <- erlang:get()].

%% @doc 判断某个timer是否存在
is_timer_exist(Mod, Time) ->
    is_timer_exist(Mod, Time, false).
is_timer_exist(Mod, Time, Loop) ->
    case get_timer_ref(Time, Loop) of
       undefined ->
            false;
        _ ->
            L = get_timer_handler(Time, Loop),
            lists:keyfind(Mod, 1, L) =/= false
    end.

%% @doc 启动timer
start_timer(Mod, Time, Msg) ->
    start_timer(Mod, Time, Msg, false).

%% @doc 启动timer,Loop是否循环
start_timer(Mod, Time, Msg, Loop) ->
    case is_timer_exist_internal(Time, Loop) of
        true ->
            L = get_timer_handler(Time, Loop),
            set_timer_handler(Time, Loop, [{Mod, Msg} | L]);
        false ->
            Ref = erlang:send_after(Time, self(), {mod_timeout, Time, Loop}),
            set_timer_ref(Time, Loop, Ref),
            set_timer_handler(Time, Loop, [{Mod, Msg}])
    end.   

%% @doc 取消timer
cancel_timer(Mod, Time) ->
    cancel_timer(Mod, Time, false).

%% @doc 取消timer
cancel_timer(Mod, Time, Loop) ->
    case get_timer_ref(Time, Loop) of
        undefined ->
            %?ERROR(?_U("对应的timer:~p不存在"), [Time]),
            ok;
        Ref when is_reference(Ref) ->
            case get_timer_handler(Time, Loop) of
                [{Mod, _Msg}] ->
                    %?DEBUG(?_U("******* cancel timer, mod:~p timer:~p"), [Mod, Time]),
                    erlang:cancel_timer(Ref),
                    clear_timer_context(Time, Loop);
                L ->
                    % 删除对应的Mod
                    L2 = lists:keydelete(Mod, 1, L),
                    set_timer_handler(Time, Loop, L2)
            end
    end.
%% @doc 当player_server timeout时
on_mod_timeout(Time, Loop) ->
    ModMsgs = get_timer_handler(Time, Loop),
    case Loop of
        true ->
            Ref = erlang:send_after(Time, self(), {mod_timeout, Time, Loop}),
            set_timer_ref(Time, Loop, Ref);
        false ->
            ok = clear_timer_context(Time, Loop)
    end,
    ModMsgs.

%%-----------
%% 准时timer
%%-----------

%% @doc 判断timer是否存在
is_absolute_timer_exist(Mod, Time) ->
    erlang:get(?ABSOLUTE_TIME_REF(Time, Mod)) =/= undefined.

%% @doc 启动准时timer
start_absolute_timer(Mod, Time, Msg) ->
    Ref = erlang:send_after(Time, self(), {mod_timeout, Mod, Msg}),
    erlang:put(?ABSOLUTE_TIME_REF(Time, Mod), Ref),
    ok.

%% @doc 取消准时timer
cancel_absolute_timer(Mod, Time) ->
    case erlang:get(?ABSOLUTE_TIME_REF(Time, Mod)) of
        undefined ->
            ok;
        Ref ->
            erlang:cancel_timer(Ref)
    end,
    erlang:erase(?ABSOLUTE_TIME_REF(Time, Mod)),
    ok.

%%------------------------
%% internal API
%%------------------------

%%----------
%% Timer相关
%%----------

%% timer是否存在
is_timer_exist_internal(Time, Loop) ->
    get(?TIMER_REF(Time, Loop)) =/= undefined.

%% 设置timer的handler 列表
set_timer_handler(Time, Loop, L) ->
    put(?TIMER_HANDLER(Time, Loop), L),
    ok.

%% 获取对应Time对应的Handler
get_timer_handler(Time, Loop) ->
    case get(?TIMER_HANDLER(Time, Loop)) of
        undefined ->
            [];
        L ->
            L
    end.

%% 设置timer的ref
set_timer_ref(Time, Loop, Ref) ->
    erlang:put(?TIMER_REF(Time, Loop), Ref),
    ok.

%% 获取timer的ref
get_timer_ref(Time, Loop) ->
    erlang:get(?TIMER_REF(Time, Loop)).

%% 清理Timer对应的上下文
clear_timer_context(Time, Loop) ->
    erase(?TIMER_REF(Time, Loop)),
    erase(?TIMER_HANDLER(Time, Loop)),
    ok.

%%------------------
%% 关于数据定期同步
%%------------------

%% @doc 启动数据同步
%% FunData:可以为一个函数,或者函数列表
start_data_sync(Type, Time, FunData) ->
    ?ASSERT(is_list(FunData) or is_function(FunData)),
    Ref = make_ref(),
    ?MODULE:start_timer(?MODULE, Time, {?DATA_SYNC_EVENT, Ref}),
    erlang:put({'$data_sync_fun', Type}, FunData),
    erlang:put(Ref, {Type, Time}),
    ok.

%% @doc 处理timeout
%% 1,执行同步函数
%% 2,设置更新时间
%% 3,重启sync timer
handle_timeout({?DATA_SYNC_EVENT, Ref}, State) ->
    {Type, Time} = erlang:get(Ref),
    %?DEBUG(?_U("收到数据:~p同步,time:~p"), [Type, Time]),
    % 1
    case get_data_sync_fun(Type) of
        ?NONE ->
            ok;
        List when is_list(List) ->
            [do_call_sync_fun(Fun, State) || Fun <- List],
            ok;
        Fun ->
            do_call_sync_fun(Fun, State)
    end,
    % 2
    set_last_data_sync_time(Type),
    % 3
    ?MODULE:start_timer(?MODULE, Time, {?DATA_SYNC_EVENT, Ref}),
    {ok, State}.

%% @doc 获取上一次同步时间
get_last_data_sync_time(Type) ->
    case erlang:get({'$last_data_sync_time', Type}) of
        undefined ->
            0;
        Time ->
            Time
    end.

%% 设置上一次同步时间
set_last_data_sync_time(Type) ->
    erlang:put({'$last_data_sync_time', Type}, wg_util:now_sec()),
    ok.

%% 获取同步函数
get_data_sync_fun(Type) ->
    case erlang:get({'$data_sync_fun', Type}) of
        undefined ->
            ?NONE;
        [] ->
            ?NONE;
        Fun ->
            Fun
    end.

%% 调用同步函数
do_call_sync_fun(Fun, _State) when is_function(Fun, 0) ->
    Fun();
do_call_sync_fun(Fun, State) when is_function(Fun, 1) ->
    Fun(State).

%%--------------
%% 关于数据收集
%%--------------

%% @doc 收集数据
gather_player(Player) ->
    Mods = module_list(),
    [begin
        case catch Mod:gather_player(Player) of
            {'EXIT', _Reason} ->
                ?ERROR(?_U("玩家:~p模块:~p收集数据失败:~p"), 
                    [Player#player.id, Mod, _Reason]),
                error(gather_player);
            Data ->
                {Mod, Data}
        end
    end || Mod <- Mods].

%%-----------
%% EUNIT TEST
%%-----------
-ifdef(EUNIT).

basic_test() ->
    ?assertEqual(ok, start()),
    ?assertEqual(ok, stop()),
    ok.

init([]) ->
    put(k1, "hello"),
    {ok, test}.

terminate() ->
    erase(k1),
    ok.

mod_test_() ->
    {spawn, 
    {inorder,
    {setup,
        fun() -> 
                gen_mod:start(),
                game_hooks:start_link()
        end,
        fun({ok, Pid}) ->
                gen_mod:stop(),
                erlang:exit(Pid, kill)
        end,
        [
            ?_assertEqual({ok, test}, gen_mod:start_module(?MODULE, [])),
            ?_assertEqual("hello", erlang:get(k1)),
            ?_assertEqual(ok, gen_mod:stop_module(?MODULE)),
            ?_assertEqual(undefined, erlang:get(k1))
        ]
    }}}.

timer_test() ->
    ?assertEqual(false, is_timer_exist_internal(100, true)),
    ?assertEqual([], get_timer_handler(100, true)),
    ?assertEqual(ok, set_timer_handler(100, true, [?MODULE])),
    ?assertEqual([?MODULE], get_timer_handler(100, true)),
    ?assertEqual(ok, clear_timer_context(100, true)),
    ?assertEqual([], get_timer_handler(100, true)),
    ?assertEqual([], get_timer_handler(1000, true)),
    ok.

-endif.
