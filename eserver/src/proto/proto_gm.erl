%%%----------------------------------------------------------------------
%%%
%%% @author: auto generate
%%% @doc: 账户信息 (自动生成，请勿编辑!)
%%%
%%%----------------------------------------------------------------------
-module(proto_gm).
-compile([export_all]).
-include("wg.hrl").
-include("game.hrl").
-include("pbmessage_pb.hrl").

cg_gm_commond(Bin) ->
    {ok, pbmessage_pb:decode_cg_gm_commond(Bin)}.

cg_gm_player_recharge(Bin) ->
    {ok, pbmessage_pb:decode_cg_gm_player_recharge(Bin)}.


encode_s2c(#gc_gm_commond{} = Record) ->
    pbmessage_pb:encode_gc_gm_commond(Record);

encode_s2c(#gc_gm_player_recharge{} = Record) ->
    pbmessage_pb:encode_gc_gm_player_recharge(Record);

encode_s2c(_) -> error({?MODULE, unknown_s2c}).

