%%%----------------------------------------------------------------------
%%%
%%% @author: auto generate
%%% @doc: 账户信息 (自动生成，请勿编辑!)
%%%
%%%----------------------------------------------------------------------
-module(proto_notice).
-compile([export_all]).
-include("wg.hrl").
-include("game.hrl").
-include("pbmessage_pb.hrl").


encode_s2c(#gc_give_money{} = Record) ->
    pbmessage_pb:encode_gc_give_money(Record);

encode_s2c(_) -> error({?MODULE, unknown_s2c}).

