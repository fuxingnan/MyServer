%%%----------------------------------------------------------------------
%%%
%%% @author: auto generate
%%% @doc: 账户信息 (自动生成，请勿编辑!)
%%%
%%%----------------------------------------------------------------------
-module(proto_chat).
-compile([export_all]).
-include("wg.hrl").
-include("game.hrl").
-include("pbmessage_pb.hrl").

cg_chat(Bin) ->
    {ok, pbmessage_pb:decode_cg_chat(Bin)}.

cg_face(Bin) ->
    {ok, pbmessage_pb:decode_cg_face(Bin)}.

cg_sound(Bin) ->
    {ok, pbmessage_pb:decode_cg_sound(Bin)}.

cg_voice(Bin) ->
    {ok, pbmessage_pb:decode_cg_voice(Bin)}.


encode_s2c(#gc_chat{} = Record) ->
    pbmessage_pb:encode_gc_chat(Record);

encode_s2c(#gc_face{} = Record) ->
    pbmessage_pb:encode_gc_face(Record);

encode_s2c(#gc_sound{} = Record) ->
    pbmessage_pb:encode_gc_sound(Record);

encode_s2c(#gc_voice{} = Record) ->
    pbmessage_pb:encode_gc_voice(Record);

encode_s2c(_) -> error({?MODULE, unknown_s2c}).

