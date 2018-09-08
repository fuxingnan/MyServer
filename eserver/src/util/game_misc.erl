%%%----------------------------------------------------------------------
%%%
%%% @copyright (C) 2012, kebo
%%% @author kebo <>
%%% Created : 25 Apr 2012 by kebo <>
%%% @doc 游戏逻辑相关的一些辅助函数
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(game_misc).
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg.hrl").
-include("game.hrl").

-export([map_server_name/1, mon_name/1, 
         player_name/1,robot_name/1,client_name/1,
         map_box_mgr_name/1, mon_ai_mod_name/1, map_ai_mod_name/1,
         is_map_ai_exist/1,
         logic_log_filename/1, chat_log_filename/0, flash_log_filename/0, peer_log_filename/0,
         prefix_n/2,
         whereis_name/1
     ]).

%% 随机数
-export([rand/0, rand/1, rand/2, pick_by_prob/1, pick_by_prob/2, pick_by_time/2]).

%% 计算附加
-export([calc_add/2, calc_dec/2]).

%% 方位相关
-export([point_round/4, point_distance/4, distance/4, distance2/4, judge_aspect/4, in_range/5,
        round_pos_list/4, judge_pos_in_grid/3,
        path_xy_to_aspect/1, path_aspect_to_xy/3, next_pos_by_aspect/2
    ]).

%% 向上取整
-export([ceil/1]).

%% 启动某个子服务
-export([
        handle_start_app/1,
        start_child/2,
        start_game_hooks/1, 
        start_config_server/1,
        start_cron_server/2,
        start_reloader_server/1,
        start_time_cache/1,
        start_wg_alarm/1
    ]).
-export([connect_world_node/0]).

%% 初始化某些系统数据
-export([all_sys_data_mod/0, init_sys_data/0,
        init_sys_data/1, reload_sys_data/0, reload_sys_data/1]).
-export([reload_config/0]).

%% 战斗,调试相关
-export([gen_damage_type_str/1, gen_role_type_str/1, gen_damage_info/3, role_type_from_id/1]).

%% term binary之间转化
-export([encode_term/1, decode_term/1]).

%% 检测时间是否合法
-export([check_time/5, validate_prob/2]).

%% 用户输入的内容是否符合长度并且没有违禁词
-export([ugc_valid/3, ugc_valid/4]).
-export([set_terminate_reason/1, get_terminate_reason/0]).

%% 报警
-export([alarm_mail/1, alarm_mail/2]).

%% 开服相关
-export([service_start_in_days/0]).


-export([restart_mon_in_map/0, restart_mon_in_map/1]).

%% @doc 获取map服务名称
map_server_name({MapId, Id}) ->
    prefix_n("mapi", MapId, Id).

%% @doc 获取怪物fsm的名称
mon_name(Id) ->
    prefix_n("mon", Id).

%% @doc player_server名称
player_name(Id) ->
    prefix_n("play", Id).

%% @doc player_server名称
robot_name(Id) ->
    prefix_n("robot", Id).

%% @doc gate_client名称
client_name(Uid) ->
    prefix_n("gate", Uid).

%% @doc box mgr名称
map_box_mgr_name({MapId, Id}) ->
    prefix_n("box", MapId, Id).

%% @doc 怪物ai模块名称
mon_ai_mod_name(Str) when is_list(Str) ->
    ?S2A("mon_ai_" ++ Str).

%% @doc 地图ai模块名称
map_ai_mod_name(Str) when is_list(Str) ->
    ?S2A("map_ai_" ++ Str).

%% @doc 判断地图ai模块是否存在
is_map_ai_exist(AI) ->
    Path = filename:join([game_path:root_path(), "ebin"]),
    All =
    [begin
        Mod = filename:basename(File, ".beam"),
        ?S2A(Mod)
    end || File <- filelib:wildcard("map_ai_*.beam", Path)],
    lists:member(AI, All).

%% @doc 逻辑日志文件名
logic_log_filename(Id) ->
    lists:concat([node(), "_", Id, ?LOG_EXT]).

%% @doc 聊天日志文件名
chat_log_filename() ->
    ?A2S(node()) ++ "_chat" ++ ?LOG_EXT.

%% @doc flash debug日志文件名
flash_log_filename() ->
    ?A2S(node()) ++ "_flash" ++ ?LOG_EXT.

%% @doc 聊天日志文件名
peer_log_filename() ->
    ?A2S(node()) ++ "_peer" ++ ?LOG_EXT.

%% @doc 组合某个前缀和数字，返回值为atom
prefix_n(Prefix, N) when is_list(Prefix), is_integer(N) ->
    list_to_atom(Prefix ++ ?N2S(N)).

prefix_n(Prefix, N1, N2) when is_list(Prefix), is_integer(N1), is_integer(N2) ->
    list_to_atom(Prefix ++ [$_ | ?N2S(N1)] ++ [$_ | ?N2S(N2)]).

%% @doc 获取名字对应的pid,从local,后global查询
whereis_name(Name) ->
    case catch erlang:whereis(Name) of
        undefined ->
            global:whereis_name(Name);
        Pid ->
            Pid
    end.

%% @doc 返回1-10000之间的一个数字
rand() ->
    rand(?PROB_FULL).

%% @doc 返回一个随机数(结果为1-N)
rand(0) -> 0;
rand(N) when N < 65535, N > 0 ->
    random:uniform(N).

%% @doc 返回两个数之间的随机数
rand(Min, Min)->
    Min;
rand(Min, Max) when Min < 65535, Max < 65535 ->
    rand(Max - Min + 1) + Min - 1.

%% @doc 依据概率选择
%% 列表格式:[{对象,概率}]
%% 返回{对象,位置}
pick_by_prob(List) ->
    Point = game_misc:rand(),
    do_pick_by_prob(List, 0, Point, 1).

pick_by_prob(List, Point) ->
    do_pick_by_prob(List, 0, Point, 1).

do_pick_by_prob([], _Cur, _Point, _Index)->
    ?NONE;
do_pick_by_prob([E | Rest], Cur, Point, Index) ->
    case E of
        {Obj, Range} ->
            ok;
        [Obj, Range] ->
            ok
    end,
    if
        Cur < Point andalso Point =< (Range + Cur) ->
            {Obj, Index};
        true ->
            do_pick_by_prob(Rest, Range + Cur, Point, Index + 1)
    end.

%% @doc 依据时间选择数值
%% List: [{Time, Value}],Time从大到小
pick_by_time(List, Cur) ->
    do_pick_by_time(List, Cur).
do_pick_by_time([], _Cur) ->
    0;
do_pick_by_time([{Time, Value} | _T], Cur) when Cur >= Time ->
    Value;
do_pick_by_time([{_Time, _Value} | T], Cur) ->
    do_pick_by_time(T, Cur).

%% 根据var计算附加值
calc_add(Base, {VarNum, 0}) ->
    Base + VarNum;
calc_add(Base, {VarNum, VarPercent}) ->
    Total = Base + VarNum,
    Total + round(Total * VarPercent / 100);
calc_add(Base, Var) when is_integer(Var) ->
    Base + Var.

%% 根据var计算附加值
calc_dec(Base, {VarNum, 0}) ->
    Var = Base - VarNum,
    ?IF(Var < 0, 0, Var);
calc_dec(Base, {VarNum, VarPercent}) ->
    Var = round((Base - VarNum) * (100 - VarPercent) / 100),
    ?IF(Var < 0, 0, Var);
calc_dec(Base, VarNum) when is_integer(VarNum) ->
    Var = Base + VarNum,
    ?IF(Var < 0, 0, Var).

%% @doc 判断X，Y是否位于X0，Y0的四周，九宫格
%%    |    |
%% ------------
%%    | x0 |
%%    | y0 |
%% ------------
%%    |    |
point_round(X0, Y0, X, Y) 
    when X0 > 0, Y0 > 0, X > 0, Y > 0 ->
    DX = abs(X - X0),
    DY = abs(Y - Y0),
    DX =< 50 andalso DY =< 50.

%% @doc 计算X1, Y1和X0,Y0在坐标轴上的直线最大差距
point_distance(X0, Y0, X, Y)
      when X0 > 0, Y0 > 0, X > 0, Y > 0 ->
    DX = abs(X - X0),
    DY = abs(Y - Y0),
    erlang:max(DX, DY).

%% @doc 计算两点之间距离
distance(X0, Y0, X, Y) ->
    trunc(distance2(X0, Y0, X, Y)).

%% @doc 计算两点之间距离(返回小数)
distance2(X0, Y0, X, Y)
      when X0 > 0, Y0 > 0, X > 0, Y > 0 ->
    DX = abs(X - X0),
    DY = abs(Y - Y0),
    math:sqrt(DX * DX + DY * DY).

%% @doc 判断X，Y相对于X0，Y0的方位
%% -------------> x坐标
%% |
%% |    (x0,y0)
%% |
%% v
%% y坐标
judge_aspect(X0, Y0, X, Y) ->
    if 
        X =:= X0 ->
            if 
                Y > Y0 ->
                    ?BOTTOM;
                Y < Y0 ->
                    ?UP;
                true ->
                    ?SAME
            end;
        Y =:= Y0 ->
            if 
                X < X0 ->
                    ?LEFT;
                X > X0 ->
                    ?RIGHT
            end;
        X < X0 ->
            if 
                Y < Y0 ->
                    ?UPLEFT;
                Y > Y0 ->
                    ?BOLEFT
            end;
        X > X0 ->
            if 
                Y < Y0 ->
                    ?UPRIGHT;
                Y > Y0 ->
                    ?BORIGHT
            end
    end.

%% @doc 判断X，Y是否位于以X0,Y0为中心的Range范围内
in_range(X0, Y0, X, Y, Range) ->
    DX = abs(X0 - X),
    DY = abs(Y0 - Y),
    Range >= DX andalso Range >= DY.

%% 获取某个位置周围有效节点列表
round_pos_list(X, Y, Xn, Yn) ->
    InitPosList = 
    [{X-1, Y-1}, {X, Y-1}, {X+1, Y-1},
    {X-1, Y},              {X+1, Y},
    {X-1, Y+1},  {X, Y+1}, {X+1, Y+1}],
    [{X0, Y0} 
        || {X0, Y0} <- InitPosList, X0 >= 0, X0 < Xn, Y0 >= 0, Y0 < Yn].

%% @doc 判断在九宫格中的位置
judge_pos_in_grid(Pos, Xn, Yn) ->
    if Pos rem Xn =:= 0 -> % 最左侧
            if Pos div Xn =:= 0 -> % 最左上角
                    ?UPLEFT;
                Pos div Xn =:= (Yn-1) -> % 最左下角
                    ?BOLEFT;
                true -> % 一般左侧
                    ?LEFT
            end;
        Pos rem Xn =:= (Xn-1) -> % 最右侧
            if Pos div Xn =:= 0 -> % 最右上角
                    ?UPRIGHT;
                Pos div Xn =:= (Yn-1) -> % 最右下角
                    ?BORIGHT;
                true -> % 一般右侧
                    ?RIGHT
            end;
        Pos div Xn =:= 0 -> % 最顶部
            ?UP;
        Pos div Xn =:= (Yn-1) -> % 最底部
            ?BOTTOM;
        true -> % 内部数据
            ?INTERNAL
    end.

%% @doc xy路径转化成方位路径
path_xy_to_aspect([]) ->
    [];
path_xy_to_aspect([{StartX, StartY} | Path]) ->
    {PathAspect, _} =
    lists:foldl(
    fun({X, Y}, {Acc, {PrevX, PrevY}}) ->
        Aspect = calc_path_aspect(PrevX, PrevY, X, Y),
        {[Aspect | Acc], {X, Y}}
    end, {[], {StartX, StartY}}, Path),
    lists:reverse(PathAspect).

%% @doc 方位路径转化为xy路径
path_aspect_to_xy(StartX, StartY, Path) ->
    PathXY =
    lists:foldl(
    fun(P, [XY | _Rest] = Acc) ->
        {X2, Y2} = next_pos_by_aspect(XY, P),
        [{X2, Y2} | Acc]
    end,
    [{StartX, StartY}], Path),
    lists:reverse(PathXY).

%% @doc 根据方向获取下一个位置
next_pos_by_aspect({X, Y}, P) ->
    case P of
        ?BOTTOM ->
            {X, Y+1};
        ?BOLEFT ->
            {X-1, Y+1};
        ?LEFT ->
            {X-1, Y};
        ?UPLEFT ->
            {X-1, Y-1};
        ?UP ->
            {X, Y-1};
        ?UPRIGHT ->
            {X+1, Y-1};
        ?RIGHT ->
            {X+1, Y};
        ?BORIGHT ->
            {X+1, Y+1}
    end.


%% 计算路径方位
calc_path_aspect(X0, Y0, X1, Y1) ->
    X = X1 - X0,
    Y = Y1 - Y0,
    if
        X =:= 0 andalso Y =:= 1 ->
            ?BOTTOM;
        X =:= -1 andalso Y =:= 1 ->
            ?BOLEFT;
        X =:= -1 andalso Y =:= 0 ->
            ?LEFT;
        X =:= -1 andalso Y =:= -1 ->
            ?UPLEFT;
        X =:= 0 andalso Y =:= -1 ->
            ?UP;
        X =:= 1 andalso Y =:= -1 ->
            ?UPRIGHT;
        X =:= 1 andalso Y =:= 0 ->
            ?RIGHT;
        X =:= 1 andalso Y =:= 1 ->
            ?BORIGHT
    end.

%% @doc 用户输入的内容是否有效
ugc_valid(Content, MinLen, MaxLen)->
    CList = unicode:characters_to_list(Content),
    CLen = erlang:length(string:strip(CList, both)),
    CLen >= MinLen andalso CLen =< MaxLen.
    %CLen >= MinLen andalso CLen =< MaxLen andalso words_verify:words_verify(Content).

%% @doc 用户输入的内容是否合法,验证敏感词
ugc_valid(Content, MinLen, MaxLen, true)->
    CList = unicode:characters_to_list(Content),
    CLen = erlang:length(string:strip(CList, both)),
    %CLen >= MinLen andalso CLen =< MaxLen.
    CLen >= MinLen andalso CLen =< MaxLen andalso words_verify:words_verify(Content);
%% @doc 用户输入的内容是否有效,不验证敏感词
ugc_valid(Content, MinLen, MaxLen, false)->
    ugc_valid(Content, MinLen, MaxLen).
    
%% 保存进程退出原因,为了抑制sasl警告
-define(TERMINATE_REASON, '^terminate_reason').
%% @doc 设置结束原因
set_terminate_reason(Reason) ->
    erlang:put(?TERMINATE_REASON, Reason),
    ok.

%% @doc 获取结束原因
get_terminate_reason() ->
    erlang:get(?TERMINATE_REASON).

%% @doc 发送报警邮件
-define(FROM_MAIL, "1532804476@.com").
-define(FROM_PASSWD, "gh_yunwei").
alarm_mail(Body) ->
    alarm_mail(Body, none).
alarm_mail(Body, Callback) ->
    Mail = wg_mail:new(?FROM_MAIL, ?FROM_PASSWD),
    Platform = ?CONF(platform, "dev"),
    ServerId = ?CONF(server_id, "0"),
    case wg_util:get_ip_wan() of
        [Ip|_] ->
            Ip;
        [] ->
            Ip = hd(wg_util:get_ip())
    end,
    IpStr = wg_util:ip_ntoa(Ip),
    Title = lists:concat(["yulong[", Platform, "-", ServerId, "]", IpStr, "-", node()]),
    [Mail:send(?FROM_MAIL, To, Title, Body, Callback)
        || To <- ?CONF(alarm_mail, [])],
    ok.

%% @doc 开服的天数,计数从1开始
service_start_in_days() ->
    % 默认值取系统上线成立的日子
    StartDate = ?CONF(new_server_date, {2015, 11, 1}),
    NowDays = calendar:date_to_gregorian_days(date()),
    StartDays = calendar:date_to_gregorian_days(StartDate),
    NowDays - StartDays + 1.

%%---------------
%% 启动一些子服务
%%---------------

%% @doc 启动application,对返回值进行处理
handle_start_app(ok) -> ok;
handle_start_app({error, {already_started, _}}) -> ok;
handle_start_app(Other) -> throw(Other).

%% @doc 启动某个子服务
start_child(Sup, Child) ->
    case catch supervisor:start_child(Sup, Child) of
        {ok, _} ->
            ok;
        {error, {{already_started, _Pid}, _}} ->
            ok;
        Other ->
            ?ERROR(?_U("启动服务:~p失败:~p"), [Child, Other]),
            throw(Other)
    end.

%% @doc 启动game hooks in sup
start_game_hooks(Sup) ->
    Child =
    {game_hooks, {game_hooks, start_link, []},
        permanent, brutal_kill, worker, [game_hooks]},
    case catch supervisor:start_child(Sup, Child) of
        {ok, _} ->
            ok;
        {error, {{already_started, _Pid}, _}} ->
            ?DEBUG("game hooks already started:~w", [_Pid]),
            ok
    end.

%% @doc 启动wg config in sup
start_config_server(Sup) ->
    File =
    case os:getenv("GAME_CONF_FILE") of
        false ->
            ?CONF_FILE;
        "undefined" ->
            ?CONF_FILE;
        Val ->
            Val
    end,
    FilePath = game_path:conf_file(File),
    ?INFO(?_U("启动wg_config服务:~ts"), [FilePath]),

    Child =
    {wg_config, {wg_config, start_link, [?CONF_SERVER, FilePath]},
        permanent, brutal_kill, worker, [wg_config]},
    case catch supervisor:start_child(Sup, Child) of
        {ok, _} ->
            ok;
        {error, {{already_started, _Pid}, _}} ->
            ?DEBUG("已经开启了"),
            ok
    end.

%% @doc 启动wg crontab server
start_cron_server(Sup, ConfFile) ->
    ?INFO(?_U("启动wg_crontab服务，文件:~s"), [ConfFile]),
    Child =
    {wg_crontab_server, {wg_crontab_server, start_link, [ConfFile]},
        permanent, brutal_kill, worker, [wg_crontab_server]},
    case catch supervisor:start_child(Sup, Child) of
        {ok, _} ->
            ok;
        {error, {{already_started, _Pid}, _}} ->
            ok
    end.

%% @doc 启动reloader server
-ifdef(PRODUCT).
-define(RELOAD_INTERNAL, 0).
-else.
-define(RELOAD_INTERNAL, 5).    % 5秒
-endif.
start_reloader_server(Sup) ->
    ?INFO(?_U("启动reloader服务"), []),
    Child =
    {reloader, {wg_reloader, start_link, [?RELOAD_INTERNAL]},
        permanent, brutal_kill, worker, [wg_reloader]},
    case catch supervisor:start_child(Sup, Child) of
        {ok, _} ->
            ok;
        {error, {{already_started, _Pid}, _}} ->
            ok
    end.

%% @doc 启动time cache server
start_time_cache(Sup) ->
    ?INFO(?_U("启动time cache服务"), []),
    Child =
    {wg_time_cache, {wg_time_cache, start_link, []},
        permanent, brutal_kill, worker, [wg_time_cache]},
    start_child(Sup, Child).

%% @doc 启动wg alarm服务(依赖sasl, os_mon)
start_wg_alarm(_Sup) ->
    wg_alarm:start().

%% @doc 连接world节点
connect_world_node() ->
    case application:get_env(world) of
        {ok, World} ->
            ?INFO(?_U("查询world节点 ~p"), World),
            case net_kernel:connect_node(World) of
                true ->
                    ok;
                false ->
                    ?ERROR(?_U("连接world节点:~p失败!"), [World]),
                    ?EXIT(1)
            end;
        undefined ->
            ok
    end.

%% @doc 获取所有的系统数据模块
all_sys_data_mod() ->
    Path = filename:join([game_path:root_path(), "ebin"]),
    [begin
        Mod = filename:basename(File, ".beam"),
        ?S2A(Mod)
    end || File <- filelib:wildcard("sys_*.beam", Path)] -- [sys_map_mask].

%% @doc 初始化所有系统数据
init_sys_data() ->
    init_sys_data(all_sys_data_mod()).

%% @doc 初始化系统数据 sys_xxx:init/0
init_sys_data(List) ->
    [begin 
        case catch Mod:init() of
            ok ->
                ok;
            {'EXIT', {badarg, _}} ->
                ?INFO(?_U("系统数据:~p已经初始化"), [Mod]),
                ok;
            Error ->
                ?ERROR(?_U("系统数据:~p初始化失败:~p"), [Mod, Error]),
                error(Error)
        end
    end || Mod <- List],
    ok.

%% 重新加载所有数据
reload_sys_data() ->
    [begin
         case atom_to_list(Mod) of
             "sys_" ++ _ ->
                    case catch Mod:reload() of
                        ok->
                            ?INFO(?_U("重新加载模块:~p"), [Mod]),
                            erlang:yield(),
                            ok;
                        Reason ->
                            ?ERROR(?_U("重新加载数据错误，错误原因：~p"), [Reason]),
                            throw({error, {reload, Mod}})
                    end;
             _ ->
                    ok
         end
    end || {Mod, Load} <- code:all_loaded(),
    is_list(Load),
    wg_util:is_exported({Mod, reload, 0})],
    ok.

%% 重新加载单独模块数据
reload_sys_data(Mod) ->
    ?INFO(?_U("重新加载模块:~p"), [Mod]),
    case wg_util:is_exported({Mod, reload, 0}) of
        true ->
            Mod:reload();
        false ->
            ?ERROR(?_U("模块:~p没有reload函数"), [Mod]),
            {error, no_reload_export}
    end.

%% @doc 重新加载配置文件
reload_config() ->
    wg_config:reload(?CONF_SERVER).


%% @doc 重启地图内的分布怪
restart_mon_in_map() ->
    Ids = sys_map:get_normal_id_list(),
    restart_mon_in_map(Ids).

restart_mon_in_map(Id) when is_integer(Id) ->
    restart_mon_in_map([Id]);
restart_mon_in_map(Ids) when is_list(Ids) ->
    MapKeys =
    lists:foldl(
    fun
        (11001, Acc) ->
            [{11001, 1}, {11001, 2}, {11001, 3}, {11001, 4} |Acc];
        (MapId, Acc) ->
            [{MapId, 1} |Acc]
    end, [], Ids),
    [map_server:restart_mon_in_map(MapKey) || MapKey <- MapKeys],
    ok.


%% @doc 获取伤害类型字符串(调试)
gen_damage_type_str(?DAMAGE_TYPE_MISS) ->
    ?_U("Miss");
gen_damage_type_str(?DAMAGE_TYPE_DODGE) ->
    ?_U("闪避");
gen_damage_type_str(?DAMAGE_TYPE_CRIT) ->
    ?_U("暴击");
gen_damage_type_str(?DAMAGE_TYPE_NORMAL) ->
    ?_U("普通").

%% @doc 生成角色类型字符串(调试)
role_type_from_id(-1) ->
    ?ROLE_TYPE_ANY;
role_type_from_id(Id) when id > 10 ->
    Id rem 10.

gen_role_type_str(0) -> ?_U("无");
gen_role_type_str(?ROLE_TYPE_PLAYER) -> ?_U("玩家");
gen_role_type_str(?ROLE_TYPE_MON) -> ?_U("怪物");
gen_role_type_str(?ROLE_TYPE_PET) -> ?_U("宠物");
gen_role_type_str(?ROLE_TYPE_EMPLOYEE) -> ?_U("雇佣");
gen_role_type_str(_) -> ?_U("未知").

%% @doc 生成伤害结果信息

gen_damage_info(#player{} = Der, Damage, DamageType) ->
    #{
        dmg_type => DamageType,
        id => Der#player.id,
        dmg => Damage
    }.
%% binary为term
%-ifdef(TEST).
decode_term(Bin) when is_binary(Bin) ->
    {ok, Term} = wg_util:string_to_term(?B2S(Bin)),
    Term.
%-else.
%decode_term(Bin) when is_binary(Bin) ->
%    binary_to_term(Bin).
%-endif.

%% term为binary
%-ifdef(TEST).
encode_term(Term) ->
    ?S2B(wg_util:term_to_string(Term)).
%-else.
%encode_term(Term) ->
%    term_to_binary(Term).
%-endif.

%% @doc 检测时间是否合法
%% Month, Dom, Dow为0表示无限制
check_time(Month, Day, Dow, TimeStart, TimeEnd) ->
    {{_, MonthNow, DayNow} = Date, Time} = calendar:local_time(),
    ?IF(Month =:= 0 orelse Month =:= MonthNow, ok,
        ?C2SERR(?E_UNKNOWN)),
    ?IF(Day =:= 0 orelse Day =:= DayNow, ok,
        ?C2SERR(?E_UNKNOWN)),
    DowNow = calendar:day_of_the_week(Date),
    ?IF(Dow =:= 0 orelse Dow =:= DowNow, ok,
        ?C2SERR(?E_UNKNOWN)),
    SecondNow = calendar:time_to_seconds(Time),
    ?IF(SecondNow >= TimeStart andalso SecondNow =< TimeEnd, ok,
        ?C2SERR(?E_UNKNOWN)),
    ok.

validate_prob(List, Max) ->
    List2 = [
        case Item of
            [A, B] ->
                {A, B};
            {A, B} ->
                {A, B}
        end || Item <- List],
    {_, ProbList} = lists:unzip(List2),
    Max =:= lists:sum(ProbList).

%% 对数字向上取整
ceil(Num) ->
    Num2 = round(Num),
    case Num2 >= Num of
        true ->
            Num2;
        false ->
            Num2 + 1
    end.

%%------------------
%% internal API
%%------------------

-ifdef(EUNIT).

rand_test() ->
    ?assertEqual(1, rand(1)),
    ?assertEqual(true, lists:member(rand(2), [1, 2])),
    ?assertEqual(true, lists:member(rand(3), [1, 2, 3])),
    ?assertEqual(true, lists:member(rand(4), [1, 2, 3, 4])),
    ?assertEqual(0, rand(0)),
    ?assertError(function_clause, rand(65536)),

    ?assertEqual(true, lists:member(rand(3, 4), [3, 4])),
    ?assertEqual(3, rand(3, 3)),
    ok.

judge_aspect_test() ->
    ?assertEqual(?SAME, judge_aspect(0, 0, 0, 0)),
    ?assertEqual(?SAME, judge_aspect(1, 1, 1, 1)),
    ?assertEqual(?BOTTOM, judge_aspect(0, 0, 0, 1)),
    ?assertEqual(?UPLEFT, judge_aspect(0, 0, -1, -1)),
    ?assertEqual(?LEFT, judge_aspect(0, 0, -1, 0)),
    ?assertEqual(?BOLEFT, judge_aspect(0, 0, -1, 1)),
    ?assertEqual(?UP, judge_aspect(0, 0, 0, -1)),
    ?assertEqual(?UPRIGHT, judge_aspect(0, 0, 1, -1)),
    ?assertEqual(?RIGHT, judge_aspect(0, 0, 1, 0)),
    ?assertEqual(?BORIGHT, judge_aspect(0, 0, 1, 1)),
    ok.

in_range_test() ->
    ?assertEqual(true, in_range(0, 0, 1, 1, 1)),
    ?assertEqual(true, in_range(0, 0, 1, 1, 2)),

    ?assertEqual(false, in_range(0, 0, 1, 1, 0)),
    ?assertEqual(false, in_range(0, 0, 0, 1, 0)),
    ?assertEqual(true, in_range(0, 0, 0, 0, 0)),

    ?assertEqual(true, in_range(0, 0, 4, -4, 4)),
    ?assertEqual(true, in_range(0, 0, 4, -4, 5)),
    ok.

%% 0 | 1 | 2
%% ----------
%% 3 | 4 | 5
%% ----------
%% 6 | 7 | 8
rand_pos_list_test_() ->
    [
        % 第一行
        ?_assertEqual([{0, 1}, {1, 0}, {1, 1}], 
            lists:sort(round_pos_list(0, 0, 3, 3))),
        ?_assertEqual([{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}], 
            lists:sort(round_pos_list(1, 0, 3, 3))),
        ?_assertEqual([{1, 0}, {1, 1}, {2, 1}], 
            lists:sort(round_pos_list(2, 0, 3, 3))),

        % 第二行
        ?_assertEqual([{0, 0}, {0, 2}, {1, 0}, {1, 1}, {1, 2}], 
            lists:sort(round_pos_list(0, 1, 3, 3))),
        ?_assertEqual([{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 2}, {2, 0}, {2, 1}, {2, 2}], 
            lists:sort(round_pos_list(1, 1, 3, 3))),
        ?_assertEqual([{1, 0}, {1, 1}, {1, 2}, {2, 0}, {2, 2}], 
            lists:sort(round_pos_list(2, 1, 3, 3))),

        % 第三行
        ?_assertEqual([{0, 1}, {1, 1}, {1, 2}], 
            lists:sort(round_pos_list(0, 2, 3, 3))),
        ?_assertEqual([{0, 1}, {0, 2}, {1, 1}, {2, 1}, {2, 2}], 
            lists:sort(round_pos_list(1, 2, 3, 3))),
        ?_assertEqual([{1, 1}, {1, 2}, {2, 1}], 
            lists:sort(round_pos_list(2, 2, 3, 3)))
    ].


encode_decode_test_() ->
    [
        ?_assertEqual(hello, decode_term(encode_term(hello))),
        ?_assertEqual({}, decode_term(encode_term({}))),
        ?_assertEqual([], decode_term(encode_term([])))
    ].

pick_by_time_test_() ->
    [
        ?_assertEqual(0, pick_by_time([], 0)),
        ?_assertEqual(0, pick_by_time([{5, 5}], 0)),
        ?_assertEqual(500, pick_by_time([{50, 500}, {40, 400}], 400)),
        ?_assertEqual(500, pick_by_time([{50, 500}, {40, 400}], 50)),
        ?_assertEqual(400, pick_by_time([{50, 500}, {40, 400}], 49)),
        ?_assertEqual(400, pick_by_time([{50, 500}, {40, 400}], 40)),
        ?_assertEqual(0, pick_by_time([{50, 500}, {40, 400}], 39))
    ].

-endif.
