%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%%
%%% @doc 提供玩家喇叭功能
%%%      玩家需排队使用，这个队列用进程状态来记录，状态为{List, Switch}
%%% 其中List为喇叭队列 每个喇叭消耗6秒,Switch 取值为?LOCK 或 ?USE 分
%%% 别表示锁定和可使用
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(world_horn).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").
-include("world.hrl").
-include("../src/proto/proto.hrl").
-include("const.hrl").

-behaviour(gen_server).

-ifdef(TEST).
-compile([export_all]).
-endif.

-export([i/0, start_link/0, add/1, get_len/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-import(procdict_list, [get_list/1, set_list/2]).

%% 名字
-define(START_NAME, {global, ?MODULE}).
-define(NAME, ?START_NAME).

%% 一个喇叭使用时间 (6秒)
-define(HORN_TIME,12000).
%% 立即使用时间
-define(IMMEDIATE, 0).
-define(LOCK, 1).
-define(USE, 0).
-define(OK, 0).

%%---------
%% 对外接口
%%---------

%% @doc 获取运行信息
%% @end
i() ->
    [?MODULE:get_len()].

start_link()->
    ?DEBUG(?_U("启动号角模块啦"),[]),
    gen_server:start_link(?START_NAME, ?MODULE, [], []).

%% 添加号角
%% 1.发送消息请求添加
%% 2.确保循环存在
add(#world_horn{} = Last) ->
    gen_server:cast(?NAME, {add, Last}),
    ok.

%% 获取号角队列长度
get_len() ->
    ?DEBUG(?_U("获取长度"),[]),
     gen_server:call(?NAME, len).

%%----------------------
%% gen_server callbacks
%%----------------------
init(_Type) ->
    {ok, {[], ?USE}}.

%% 获取长度
handle_call(len, _From, {List, _} = State) ->
    {reply, length(List), State};

handle_call(_Msg, _From, State) ->
    {noreply, State}.
%% 添加到队列的末尾
handle_cast({add, Last}, {List, Switch}) ->
    % ?DEBUG(?_U("添加号角~p,~p"),[List,Switch]),
    State1 =  {lists:append(List, [Last]), Switch},
    ?IF(length(List) =:= 0
        andalso Switch =:= ?USE,  start(), ok),
    {noreply, State1};

handle_cast(_Msg, State) ->
    {noreply, State}.

%% (注意：这里看起来是可以不用List2的，但反复实验多次发现，
%% 一旦节约这个变量，队列中的消息就会同时发送)
%% 同时判断Switch和号角列表
%% a.Switch为锁定状态，解锁，（循环）
%% b.Switch为可使用号角状态，但列表为空，保持可使用号角状态，循环停止
%% c.Switch为可使用号角状态，且列表不为空，使用号角，转为锁定状态，消耗cd（循环）
handle_info({timeout, _Ref, next}, {List, Switch}) ->
    % ?DEBUG(?_U("状态： ~p,~p"),[List, Switch]),
    IsCdLock = (Switch =:= ?LOCK),
    IsEmpty = (length(List) =:= 0),
    case {IsCdLock, IsEmpty} of
        % a
        {true, _} ->
            {List2, Switch1} = {List, ?USE},
            immediate();
        % b
        {false, true} ->
            {List2, Switch1} = {List, ?USE};
        % c
        {false, false} ->
            [Horn | List1] = List,
            ok = pub_horn(Horn),
            {List2, Switch1} = {List1, ?LOCK},
            cost_cd()
    end,
    {noreply, {List2, Switch1}};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ?DEBUG(?_U("进程停止:~p"), [_Reason]),
    ok.

code_change(_Old, State, _Extra) ->
    {ok, State}.

%%--------------
%% internal API
%%--------------

%% 开始询问是否有号角
start() ->
    immediate().

immediate() ->
    timer(?IMMEDIATE).

%% 消耗cd
cost_cd() ->
    timer(?HORN_TIME).

%% 发布广播消息
pub_horn(#world_horn{id = Id, name = Name, content = Content, vip = Vip, sex = Sex, career = Career}) ->
    MsgId = ?PROTO_CONVERT({mod_chat, use_horn}),
    Msg = { Id, Name, Content,Vip,Sex,Career, ?OK },
    %?DEBUG(?_U("使用号角~p"), [Horn]),
    ?S2C_SEND_MERGE:world(MsgId, Msg),
    ok.

%% 计时器
timer(Time)->
    erlang:start_timer(Time, self(), next).

%%------------
%% EUNIT test
%%------------

-ifdef(EUNIT).
-endif.
