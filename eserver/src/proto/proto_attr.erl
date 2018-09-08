%%%----------------------------------------------------------------------
%%%
%%% @author: auto generate
%%% @doc: 玩家属性处理模块 (自动生成，请勿编辑!)
%%%
%%%----------------------------------------------------------------------
-module(proto_attr).
-compile([export_all]).
-include("wg.hrl").
-include("game.hrl").
-include("pbmessage_pb.hrl").

cg_get_register(Bin) ->
    {ok, pbmessage_pb:decode_cg_get_register(Bin)}.

cg_register(Bin) ->
    {ok, pbmessage_pb:decode_cg_register(Bin)}.

cg_change_attr(Bin) ->
    {ok, pbmessage_pb:decode_cg_change_attr(Bin)}.

cg_bind_account(Bin) ->
    {ok, pbmessage_pb:decode_cg_bind_account(Bin)}.

cg_req_money(Bin) ->
    {ok, pbmessage_pb:decode_cg_req_money(Bin)}.


encode_s2c(#gc_ret_register{} = Record) ->
    pbmessage_pb:encode_gc_ret_register(Record);

encode_s2c(#gc_register_ret{} = Record) ->
    pbmessage_pb:encode_gc_register_ret(Record);

encode_s2c(#gc_change_ret{} = Record) ->
    pbmessage_pb:encode_gc_change_ret(Record);

encode_s2c(#gc_player_kickoff{} = Record) ->
    pbmessage_pb:encode_gc_player_kickoff(Record);

encode_s2c(#gc_bind_account_ret{} = Record) ->
    pbmessage_pb:encode_gc_bind_account_ret(Record);

encode_s2c(#gc_give_money{} = Record) ->
    pbmessage_pb:encode_gc_give_money(Record);

encode_s2c(_) -> error({?MODULE, unknown_s2c}).

