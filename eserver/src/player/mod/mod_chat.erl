%%%-------------------------------------------------------------------
%%% @author fx
%%% @copyright (C) 2015, <COMPANY>
%%% @doc 邮件逻辑模块
%%%
%%% @end
%%% Created : 07. 七月 2015 下午2:18
%%%-------------------------------------------------------------------
-module(mod_chat).
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



handle_c2s(#cg_face{id = FaceId} = _ReqMoney,_MsgId, #player{} = Player) ->
    %?INFO(?_U("收到face:~p"), [1]),
    #player{room_id = RoomId,roomtype = RoomType} = Player,

    case catch mod_room:get_room(RoomType,RoomId) of
        #room{member = Member}=_Room ->
            send_face_msg(Member,FaceId,Player);
        #room_ken{member = Member}=_Room ->
            send_face_msg(Member,FaceId,Player);
        _->
            ok
    end,

    {ok, Player};

handle_c2s(#cg_sound{id = SoundId} = _ReqMoney,_MsgId, #player{} = Player) ->
    %?INFO(?_U("收到sound:~p"), [1]),
    #player{room_id = RoomId,roomtype = RoomType} = Player,

    case catch mod_room:get_room(RoomType,RoomId) of
        #room{member = Member}=_Room ->
            send_sound_msg(Member,SoundId,Player);
        #room_ken{member = Member}=_Room ->
            send_sound_msg(Member,SoundId,Player);
        _->
            ok
    end,

    {ok, Player};

handle_c2s(#cg_voice{usr_id = BeginCode,id = SoundId,unit_id = EndCode} = _ReqMoney,_MsgId, #player{} = Player) ->
    %?INFO(?_U("收到voice:~p"), [1]),
    #player{user_id = UserId, room_id = RoomId,roomtype = RoomType,unit_id = UnitId} = Player,
    case BeginCode == UserId andalso EndCode == UnitId of
        true ->
            case catch mod_room:get_room(RoomType,RoomId) of
                #room{member = Member}=_Room ->
                    Player2 = send_voice_msg(Member,SoundId,Player);
                _->
                    Player2 = Player
            end,
            Player2;
        _ ->
            Player2 = Player,
            ?INFO(?_U("聊天服务器验证码错误:~p"), [1]),
            Player2
    end,
    {ok, Player2};

handle_c2s(#cg_chat_on_phone{type = Type} = _ReqMoney,_MsgId, #player{} = Player) ->

    #player{room_id = RoomId,roomtype = RoomType} = Player,

    case catch mod_room:get_room(RoomType,RoomId) of
        #room{member = Member}=_Room ->

            Msg = #gc_chat_on_phone
            {
                type = Type
            },
            MsgId = ?PROTO_CONVERT({?MODULE, gc_chat_on_phone}),
            send_msg_broadcast(Member,MsgId, Msg);
        _->
           ok
    end,
    {ok, Player};


handle_c2s(#cg_chat{usr_id = BeginCode,content = ChatMsg,unit_id = EndCode} = _ReqMoney,_MsgId, #player{} = Player) ->
    #player{user_id = UserId, room_id = RoomId,roomtype = RoomType,unit_id = UnitId} = Player,
    case BeginCode == UserId andalso EndCode == UnitId of
        true ->
            case catch mod_room:get_room(RoomType,RoomId) of
                #room{member = Member}=_Room ->

                    Player2 = send_chat_msg(Member,ChatMsg,Player);
                _->
                    Player2 = Player
            end,
            Player2;
        _ ->
            Player2 = Player,
            ?INFO(?_U("聊天服务器验证码错误:~p"), [1]),
            Player2
    end,
    {ok, Player2}.



send_voice_msg(Member,SoundId,Player)->
    case catch do_voice_sound(Member,SoundId,Player) of
        #player{}=Player2->
            Player2;
        _->
            Player
    end.
do_voice_sound(Member,SoundId,Player)->
    #player{id =PlayerId} = Player,
    Code1 = wg_util:rand(1000,10000000),
    Code2 = wg_util:rand(1000,10000000),
    TempList = [X|| #room_member{id = MemberId} = X <-Member,MemberId =:= PlayerId],
    ?IF(length(TempList) =:= 0,?C2SERR(?Player_Pos_Not_Find),ok),
    [#room_member{pos = MyPos}=_MyMember] = TempList,
    Msg = #gc_voice
    {
        usr_id                      = Code1,
        pos                         = MyPos,
        id                          = SoundId,
        unit_id                     = Code2
    },
    MsgId = ?PROTO_CONVERT({?MODULE, gc_voice}),
    send_msg_broadcast(Member,MsgId, Msg),
    Player2 = Player#player{unit_id = Code2,user_id = Code1},
    Player2.



send_sound_msg(Member,SoundId,Player)->
    case catch do_send_sound(Member,SoundId,Player) of
        #player{}=Player2->
            Player2;
        _->
            Player
    end.
do_send_sound(Member,SoundId,Player)->
    #player{id =PlayerId} = Player,
    Code1 = wg_util:rand(1000,10000000),
    Code2 = wg_util:rand(1000,10000000),
    TempList = [X|| #room_member{id = MemberId} = X <-Member,MemberId =:= PlayerId],
    ?IF(length(TempList) =:= 0,?C2SERR(?Player_Pos_Not_Find),ok),
    [#room_member{pos = MyPos}=_MyMember] = TempList,
    Msg = #gc_sound
    {
        usr_id                      = Code1,
        pos                         = MyPos,
        id                          = SoundId,
        unit_id                     = Code2
    },
    MsgId = ?PROTO_CONVERT({?MODULE, gc_sound}),
    send_msg_broadcast(Member,MsgId, Msg),
    Player2 = Player#player{unit_id = Code2,user_id = Code1},
    Player2.



send_face_msg(Member,FaceId,Player)->
    case catch do_send_face(Member,FaceId,Player) of
        #player{}=Player2->
            Player2;
        _->
            Player
    end.
do_send_face(Member,FaceId,Player)->
    #player{id =PlayerId} = Player,
    Code1 = wg_util:rand(1000,10000000),
    Code2 = wg_util:rand(1000,10000000),
    TempList = [X|| #room_member{id = MemberId} = X <-Member,MemberId =:= PlayerId],
    ?IF(length(TempList) =:= 0,?C2SERR(?Player_Pos_Not_Find),ok),
    [#room_member{pos = MyPos}=_MyMember] = TempList,
    Msg = #gc_face
    {
        usr_id                      = Code1,
        pos                         = MyPos,
        id                          = FaceId,
        unit_id                     = Code2
    },
    MsgId = ?PROTO_CONVERT({?MODULE, gc_face}),
    send_msg_broadcast(Member,MsgId, Msg),
    Player2 = Player#player{unit_id = Code2,user_id = Code1},
    Player2.



send_chat_msg(Member,ChatMsg,Player)->
    case catch do_send_chat(Member,ChatMsg,Player) of
        #player{}=Player2->
            Player2;
        _->
            Player
    end.
do_send_chat(Member,ChatMsg,Player)->
    #player{id =PlayerId} = Player,
    Code1 = wg_util:rand(1000,10000000),
    Code2 = wg_util:rand(1000,10000000),
    TempList = [X|| #room_member{id = MemberId} = X <-Member,MemberId =:= PlayerId],
    ?IF(length(TempList) =:= 0,?C2SERR(?Player_Pos_Not_Find),ok),
    [#room_member{pos = MyPos}=_MyMember] = TempList,
    Msg = #gc_chat
    {
        usr_id                      = Code1,
        pos                         = MyPos,
        content                     = ChatMsg,
        unit_id                     = Code2
    },
    MsgId = ?PROTO_CONVERT({?MODULE, gc_chat}),
    send_msg_broadcast(Member,MsgId, Msg),

    Player2 = Player#player{unit_id = Code2,user_id = Code1},
    Player2.

send_msg_broadcast([], _MsgId, _Msg )->
    ok;
send_msg_broadcast(MemberList, MsgId, Msg) ->
    [begin

         ?IF(Member#room_member.state =:= ?PLAYER_OFFlINE,ok,ok = ?S2C_SEND_MERGE:player(Member#room_member.id, MsgId, Msg))

     end || Member <- MemberList],
    ok.