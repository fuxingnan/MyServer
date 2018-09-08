%%%----------------------------------------------------------------------
%%%
%%% @author: auto generate
%%% @doc: 房间信息 (自动生成，请勿编辑!)
%%%
%%%----------------------------------------------------------------------
-module(proto_room).
-compile([export_all]).
-include("wg.hrl").
-include("game.hrl").
-include("pbmessage_pb.hrl").

cg_join_room(Bin) ->
    {ok, pbmessage_pb:decode_cg_join_room(Bin)}.

cg_add_money(Bin) ->
    {ok, pbmessage_pb:decode_cg_add_money(Bin)}.

cg_bet_money(Bin) ->
    {ok, pbmessage_pb:decode_cg_bet_money(Bin)}.

cg_get_rank(Bin) ->
    {ok, pbmessage_pb:decode_cg_get_rank(Bin)}.

cg_quit_room(Bin) ->
    {ok, pbmessage_pb:decode_cg_quit_room(Bin)}.

cg_force_join(Bin) ->
    {ok, pbmessage_pb:decode_cg_force_join(Bin)}.

cg_change_room(Bin) ->
    {ok, pbmessage_pb:decode_cg_change_room(Bin)}.

cg_deleteroom(Bin) ->
    {ok, pbmessage_pb:decode_cg_deleteroom(Bin)}.

cg_get_video(Bin) ->
    {ok, pbmessage_pb:decode_cg_get_video(Bin)}.

cg_give_room_card(Bin) ->
    {ok, pbmessage_pb:decode_cg_give_room_card(Bin)}.


encode_s2c(#gc_join_room{} = Record) ->
    pbmessage_pb:encode_gc_join_room(Record);

encode_s2c(#gc_add_member{} = Record) ->
    pbmessage_pb:encode_gc_add_member(Record);

encode_s2c(#gc_add_money{} = Record) ->
    pbmessage_pb:encode_gc_add_money(Record);

encode_s2c(#gc_player_turn{} = Record) ->
    pbmessage_pb:encode_gc_player_turn(Record);

encode_s2c(#gc_bet_money{} = Record) ->
    pbmessage_pb:encode_gc_bet_money(Record);

encode_s2c(#gc_ret_ready{} = Record) ->
    pbmessage_pb:encode_gc_ret_ready(Record);

encode_s2c(#gc_get_rank{} = Record) ->
    pbmessage_pb:encode_gc_get_rank(Record);

encode_s2c(#gc_quit_room{} = Record) ->
    pbmessage_pb:encode_gc_quit_room(Record);

encode_s2c(#gc_reconnect_failed{} = Record) ->
    pbmessage_pb:encode_gc_reconnect_failed(Record);

encode_s2c(#gc_force_join{} = Record) ->
    pbmessage_pb:encode_gc_force_join(Record);

encode_s2c(#gc_change_room{} = Record) ->
    pbmessage_pb:encode_gc_change_room(Record);

encode_s2c(#gc_deleteroom{} = Record) ->
    pbmessage_pb:encode_gc_deleteroom(Record);

encode_s2c(#gc_friend_result{} = Record) ->
    pbmessage_pb:encode_gc_friend_result(Record);

encode_s2c(#gc_friend_join_result{} = Record) ->
    pbmessage_pb:encode_gc_friend_join_result(Record);

encode_s2c(#gc_game_over{} = Record) ->
    pbmessage_pb:encode_gc_game_over(Record);

encode_s2c(#gc_hide_loading{} = Record) ->
    pbmessage_pb:encode_gc_hide_loading(Record);

encode_s2c(#gc_rank_win_money_video{} = Record) ->
    pbmessage_pb:encode_gc_rank_win_money_video(Record);

encode_s2c(#gc_give_room_card{} = Record) ->
    pbmessage_pb:encode_gc_give_room_card(Record);

encode_s2c(_) -> error({?MODULE, unknown_s2c}).

