%%%----------------------------------------------------------------------
%%%
%%% @author fuxing
%%% @date  2015.04.18
%%% @doc 后台控制，包括禁ip，禁登录，禁言
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(gm_ctrl).

-include("wg.hrl").
-include("game.hrl").

-export([add_ip_ban/2, add_login_ban/2, add_chat_ban/2,
         delete_ip_ban/1, delete_login_ban/1, delete_chat_ban/1,
        is_ip_ban_timein_exists/1, is_chat_ban_timein_exists/1, is_login_ban_timein_exists/1, 
        is_tracked/1, get_chat_ban/1]).

-export([i/0, list/0]).

-export([init/0,add/4, get/2, clear/0, delete/2, is_timein_exists/2]).

-record(gm_ctrl,{
        id,                    % {ctrl_type, target}
        ctrl_type,             % 控制类型:1.禁IP,2.禁登录,3.禁言
        begin_time,            % 开始时间,
        end_time,              % 结束时间,
        target                 % 禁IP存IP,禁角色存ID,
    }).

-define(TABLE, gm_ctrl).

%% 控制类型定义
-define(IP_BAN, 1).
-define(LOGIN_BAN, 2).
-define(CHAT_BAN, 3).
-define(PLAYER_TRACKED, 9).

%%---------
%% 对外接口
%%---------

%% 添加一条禁ip记录
add_ip_ban(Time, Target) ->
    IpTuple = to_ip_tuple(Target),
    StartTime = wg_util:now_sec(),
    ok = add(?IP_BAN, StartTime, StartTime + Time, IpTuple),
    ok.

%% 添加一条禁登录记录
add_login_ban(Time, Target) ->
    StartTime = wg_util:now_sec(),
   ok = add(?LOGIN_BAN, StartTime, StartTime + Time, Target),
   ok.

%% 添加一条禁言记录
add_chat_ban(Time, Target) ->
    StartTime = wg_util:now_sec(),
    ok = add(?CHAT_BAN, StartTime, StartTime + Time, Target),
    ok.

%% 删除一条禁ip记录
delete_ip_ban(Target) ->
    IpTuple = to_ip_tuple(Target),
    delete(?IP_BAN, IpTuple).

%% 删除一条禁登录记录
delete_login_ban(Target) ->
    delete(?LOGIN_BAN, Target).

%% 删除一条禁言记录
delete_chat_ban(Target) ->
    delete(?CHAT_BAN, Target).

%% 初始化
init() ->
    %?INFO(?_U("初始化禁封列表"),[]),
    wg_mnesia:ensure_mnesia_is_running(),
    %创建表
    case wg_mnesia:is_table_exists(?TABLE) of
        true ->
            ok;
        false ->
            {atomic, ok} = mnesia:create_table(?TABLE,
                                               [{type, set},
                                                {ram_copies, [node()]},
                                                {attributes, record_info(fields, gm_ctrl)}]),

            ok
    end,
    ok = do_load_data(),
    ok.

%% 被禁聊天记录是否已经存在
is_chat_ban_timein_exists(Id) ->
    is_timein_exists(?CHAT_BAN, Id).

%% 被禁ip记录是否已经存在
is_ip_ban_timein_exists(Target) ->
    IpTuple = to_ip_tuple(Target),
    is_timein_exists(?IP_BAN, IpTuple).

%% 被禁登录记录是否已经存在
is_login_ban_timein_exists(Id) ->
    is_timein_exists(?LOGIN_BAN, Id).

%% 是否追踪玩家
is_tracked(Id) ->
    ?MODULE:get(?PLAYER_TRACKED, Id) =/= [].

get_chat_ban(Target) ->
    ?MODULE:get(?CHAT_BAN, Target).

%% 获取被禁记录
get(CtrlType, Target) ->
    %?DEBUG(?_U("获取被禁记录，CtrlType:~p, Target:~p"),[CtrlType, Target]),
    case catch mnesia:dirty_read(?TABLE, {CtrlType, Target}) of
        [] ->
           [];
        [GmCtrl] ->
            GmCtrl;
        {'EXIT', _Reason} ->
            ?ERROR(?_U("获取被禁记录数据失败:~p,控制类型:~p"), [_Reason, ban_type_cn(CtrlType)]),
            []
    end.

%% 被禁记录是否已经存在且在有效时间内
is_timein_exists(CtrlType, Target) ->
    case catch mnesia:dirty_read(?TABLE, {CtrlType, Target}) of
        [] ->
            false;
        [GmCtrl] ->
            case GmCtrl#gm_ctrl.end_time > wg_util:now_sec() of
                true ->
                    true;
               false ->
                   delete(CtrlType, Target),
                   false
            end;
        {'EXIT', _Reason} ->
            ?ERROR(?_U("获取被禁记录数据失败:~p,控制类型:~p"), [_Reason, ban_type_cn(CtrlType)]),
            false
    end.

%% @doc 清除
clear() ->
    {atomic, ok} = mnesia:delete_table(?TABLE),
    ok.

%% @doc 当前状态
i() ->
    [{count, length(list())}].

%% @doc 所有的数据id
list() ->
    All = mnesia:dirty_match_object(wg_mnesia:wild_pattern(?TABLE)),
    [Id || #gm_ctrl{id = Id} <- All].

%% 添加一条禁止
add(CtrlType, StartTime, EndTime, Target) ->
    Fun =
        fun() ->
            mnesia:write(#gm_ctrl{
                id = {CtrlType, Target},
                ctrl_type = CtrlType,
                begin_time = StartTime,
                end_time = EndTime,
                target = Target
                                 })
        end,
    case mnesia:transaction(Fun) of
        {atomic, ok} ->
            ?DEBUG(?_U("添加一条禁止数据成功,控制类型：~p"),[ban_type_cn(CtrlType)]),
            ok;
        {aborted, _Reason} ->
            ?ERROR(?_U("添加一条禁止数据失败:~p,控制类型:~p"), [_Reason, ban_type_cn(CtrlType)]),
            ?C2SERR(?E_UNKNOWN)
    end.

%% 删除一条禁止数据
delete(CtrlType, Target) ->
    Fun =
        fun() ->
            mnesia:delete({?TABLE, {CtrlType, Target}})
        end,
    case mnesia:transaction(Fun) of
        {atomic, ok} ->
            ?DEBUG(?_U("删除一条禁止数据成功,控制类型：~p"),[ban_type_cn(CtrlType)]),
            ok;
        {aborted, _Reason} ->
            ?ERROR(?_U("删除一条禁止数据失败:~p,控制类型:~p"), [_Reason, ban_type_cn(CtrlType)]),
            ?C2SERR(?E_UNKNOWN)
    end.

%%--------------
%% internal API
%%--------------

%% 禁止类型说明
ban_type_cn(Type) ->
    case Type of
        ?IP_BAN ->
            ?_U("ban ip");
        ?LOGIN_BAN ->
            ?_U("ban login");
        ?CHAT_BAN ->
            ?_U("ban chat")
    end.

%% 加载数据
do_load_data() ->
    List = [],
    do_insert(List).

%% 加载数据
do_insert(List) ->
    ?INFO(?_U("加载被禁记录条数:~b"), [length(List)]),
    Fun =
        fun() ->
            [begin
                GmCtrl = gen_gm_ctrl(Row),
                ok = mnesia:write(GmCtrl)
            end || Row <- List],
            ok
        end,
    case mnesia:transaction(Fun) of
        {atomic, ok} ->
            ok;
        {aborted, _Reason} ->
            ?ERROR(?_U("加载gm_ctrl数据失败:~p"), [_Reason]),
            ?C2SERR(?E_UNKNOWN)
    end.

%% 转化为ip tuple
to_ip_tuple(Ip) when is_list(Ip) ->
    {ok, IpTuple} = inet_parse:address(Ip),
    IpTuple;
to_ip_tuple(Ip) when is_tuple(Ip) ->
    Ip.

%% 生成gm_ctrl结构
gen_gm_ctrl([CtrlType, StartTime, EndTime, Target0]) ->
    Target =
    case CtrlType of
        ?IP_BAN ->
            Ip = ?B2S(Target0),
            wg_util:ip_aton(Ip);
        ?LOGIN_BAN ->
            ?B2N(Target0);
        ?CHAT_BAN ->
            ?B2N(Target0)
    end,
    #gm_ctrl{
        id = {CtrlType, Target},
        ctrl_type = CtrlType,
        begin_time = StartTime,
        end_time = EndTime,
        target = Target
    }.
