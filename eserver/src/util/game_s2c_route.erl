%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 负责完成消息从服务器到客户端的路由，map, world中均可调用
%%% *NOTE* 只有进入游戏后（而不是角色界面）才可以使用此模块发送消息
%%% SendType选项: send_push(立即发送), send_merge(合并发送)
%%%
%%%----------------------------------------------------------------------
-module(game_s2c_route).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("gate.hrl").
-include("player.hrl").
-include("../src/proto/proto.hrl").

%% 适配以前的参数化接口模块,参照mocheweb改动
-export([new/1]).

-export([world/3, sight/5, sight/6, sight_exclude/7, sight_include/7,
         team/4, player/4, players/4, master/4]).



%% tuple module
new(SendType) ->
    {?MODULE, SendType}.

%% @doc 发送消息到整个世界（所有玩家）
world(MsgId, Req, {?MODULE, SendType} = _This) ->
    %?DEBUG(?_U("发送消息~p:~p给所有玩家"), [?PROTO_CONVERT(MsgId), MsgId]),
    % 不经map server，直接获取所有的gateway，随后发布消息
    gate_node:send_all(SendType, MsgId, Req).

%% @doc 发送消息到视野内玩家
%% Map 类型为MapKey
sight(Map, X, Y, MsgList, {?MODULE, SendType} = _This) ->
    Uids = map_server:sight_user(Map, X, Y),
    [begin
        [ok = gate_client:SendType(Id, MsgId, Msg) 
            || {MsgId, Msg} <- MsgList]
    end  || Id <- Uids],
    ok.
sight(Map, X, Y, MsgId, Req, {?MODULE, SendType} = _This) ->
    Uids = map_server:sight_user(Map, X, Y),
    %?DEBUG(?_U("发送消息~p:~p给视野内玩家(map:~p, x:~p, y:~p) 玩家id列表:~p"),
    %    [?PROTO_CONVERT(MsgId), MsgId, Map, X, Y, Uids]),
    [ok = gate_client:SendType(Id, MsgId, Req) || Id <- Uids],
    ok.

%% @doc 发送消息到视野内的在Include列表内的玩家，Include(为id列表或单个id)
sight_include(Map, X, Y, MsgId, Req, Include, {?MODULE, SendType} = _This) ->
    Uids = map_server:sight_user(Map, X, Y),
    %?DEBUG(?_U("发送消息~p:~p给视野内玩家(map:~p, x:~p, y:~p) 玩家id列表:~p 只包含:~p"),
    %    [?PROTO_CONVERT(MsgId), MsgId, Map, X, Y, Uids, Include]),
    if
        is_integer(Include) ->
            [ok = gate_client:SendType(Id, MsgId, Req)
                || Id <- Uids, Id =:= Include];
        is_list(Include) ->
            [begin
                case lists:member(Id, Include) of
                    true ->
                        ok = gate_client:SendType(Id, MsgId, Req);
                    false ->
                        ok
                end
            end || Id <- Uids]
    end,
    ok.

%% @doc 发送消息到视野内玩家，除却Exclude(为id列表或单个id)
sight_exclude(Map, X, Y, MsgId, Req, Exclude, {?MODULE, SendType} = _This) ->
    Uids = map_server:sight_user(Map, X, Y),
    %?DEBUG(?_U("发送消息~p:~p给视野内玩家(map:~p, x:~p, y:~p) 玩家id列表:~p 不包含:~p"),
    %    [?PROTO_CONVERT(MsgId), MsgId, Map, X, Y, Uids, Exclude]),
    if
        is_integer(Exclude) ->
            [ok = gate_client:SendType(Id, MsgId, Req) 
                || Id <- Uids, Id =/= Exclude];
        is_list(Exclude) ->
            [begin
                case lists:member(Id, Exclude) of
                    true ->
                        ok;
                    false ->
                        ok = gate_client:SendType(Id, MsgId, Req) 
                end
            end || Id <- Uids]
    end,
    ok.

%% @doc 发送消息给队伍成员
team(0, _MsgId, _Msg, {?MODULE, _SendType} = _This) ->
    ok;
team(TeamId, MsgId, Msg, {?MODULE, _SendType} = _This) when is_integer(TeamId) ->
    MemberList = team_mgr:member_id_list(TeamId),
    [ok = player(PlayerId, MsgId, Msg, _This) || PlayerId <- MemberList],
    ok.

%% @doc 发送消息给某个玩家
player(Player, MsgId, Req, {?MODULE, SendType} = _This) when is_integer(Player) ->
    %?DEBUG("send msg ~p:~p to the player:~p",
       %[?PROTO_CONVERT(MsgId), MsgId, Player]),
    NewPlayer = player_mgr:get_by_id(Player),
    case NewPlayer of
        #player{robot = Robot} = _NewPlayer ->
            #robot{is_robot = IsRobot} = Robot,
            case IsRobot of
                true->
                    %?INFO(?_U("发送给机器人消息:~p,"), [1]),
                    ok = player_server:s2s_cast(Player, mod_robot, Req);
                _->
                    gate_client:SendType(Player, MsgId, Req)
            end;
        _->
            gate_client:SendType(Player, MsgId, Req)

    end;

player(Player, MsgId, Req, {?MODULE, SendType} = _This) when is_pid(Player) ->
    %?DEBUG("send msg ~p:~p to the player:~p",
        %[?PROTO_CONVERT(MsgId), MsgId, Player]),
    gate_client:SendType(Player, MsgId, Req);
player(#player{client = Client}, MsgId, Req, {?MODULE, SendType} = _This) when is_pid(Client) ->
    %?DEBUG("send msg ~p:~p to the player:~p", 
    %    [?PROTO_CONVERT(MsgId), MsgId, Player#player.id]),
    gate_client:SendType(Client, MsgId, Req);
player(#player{id = Id,robot = Robot}, MsgId, Req, {?MODULE, SendType} = _This) ->
    #robot{is_robot = IsRobot} = Robot,
    case IsRobot of
        true->
            %?INFO(?_U("发送给机器人消息:~p,"), [1]),
            ok = player_server:s2s_cast(Id, mod_robot, Req);
        _->
            gate_client:SendType(Id, MsgId, Req)
    end.

%% @doc 发送消息给多个玩家
players(Players, MsgId, Req, {?MODULE, _SendType} = _This) when is_list(Players) ->
    [ok = player(P, MsgId, Req, _This) || P <- Players],
    ok.

%% @doc 发送消息给师门成员
master(0, _MsgId, _Msg, {?MODULE, _SendType} = _This) ->
    ok;
master(MasterId, MsgId, Msg, {?MODULE, _SendType} = _This) when is_integer(MasterId) ->
    PlayerIdS = master_mgr:member_id_list(MasterId),
    %% ?DEBUG("send msg ~p  to ~p", [Msg, PlayerIdS]),
    [ok = player(PlayerId, MsgId, Msg, _This) || PlayerId <- PlayerIdS],
    ok.

%%---------------
%% internal API
%%---------------

-ifdef(EUNIT).
    
-endif.
