%%%----------------------------------------------------------------------
%%%
%%% @author: auto generate
%%% @doc: 账户信息 (自动生成，请勿编辑!)
%%%
%%%----------------------------------------------------------------------
-module(proto_kenroom).
-compile([export_all]).
-include("wg.hrl").
-include("game.hrl").
-include("pbmessage_pb.hrl").

cg_join_ken_room(Bin) ->
    {ok, pbmessage_pb:decode_cg_join_ken_room(Bin)}.

cg_ken_add_money(Bin) ->
    {ok, pbmessage_pb:decode_cg_ken_add_money(Bin)}.

cg_ken_bet_money(Bin) ->
    {ok, pbmessage_pb:decode_cg_ken_bet_money(Bin)}.

cg_ken_open_card(Bin) ->
    {ok, pbmessage_pb:decode_cg_ken_open_card(Bin)}.


encode_s2c(#gc_join_ken_room{} = Record) ->
    pbmessage_pb:encode_gc_join_ken_room(Record);

encode_s2c(#gc_add_ken_member{} = Record) ->
    pbmessage_pb:encode_gc_add_ken_member(Record);

encode_s2c(#gc_ken_add_money{} = Record) ->
    pbmessage_pb:encode_gc_ken_add_money(Record);

encode_s2c(#gc_ken_player_turn{} = Record) ->
    pbmessage_pb:encode_gc_ken_player_turn(Record);

encode_s2c(#gc_ken_bet_money{} = Record) ->
    pbmessage_pb:encode_gc_ken_bet_money(Record);

encode_s2c(#gc_ken_open_card{} = Record) ->
    pbmessage_pb:encode_gc_ken_open_card(Record);

encode_s2c(_) -> error({?MODULE, unknown_s2c}).

