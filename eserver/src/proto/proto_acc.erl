%%%----------------------------------------------------------------------
%%%
%%% @author: auto generate
%%% @doc: 账户信息 (自动生成，请勿编辑!)
%%%
%%%----------------------------------------------------------------------
-module(proto_acc).
-compile([export_all]).
-include("wg.hrl").
-include("game.hrl").
-include("pbmessage_pb.hrl").

cg_login(Bin) ->
    {ok, pbmessage_pb:decode_cg_login(Bin)}.

cg_selectrole(Bin) ->
    {ok, pbmessage_pb:decode_cg_selectrole(Bin)}.

cg_createrole(Bin) ->
    {ok, pbmessage_pb:decode_cg_createrole(Bin)}.

cg_connected_heartbeat(Bin) ->
    {ok, pbmessage_pb:decode_cg_connected_heartbeat(Bin)}.


encode_s2c(#gc_login_ret{} = Record) ->
    pbmessage_pb:encode_gc_login_ret(Record);

encode_s2c(#gc_selectrole_ret{} = Record) ->
    pbmessage_pb:encode_gc_selectrole_ret(Record);

encode_s2c(#gc_createrole_ret{} = Record) ->
    pbmessage_pb:encode_gc_createrole_ret(Record);

encode_s2c(_) -> error({?MODULE, unknown_s2c}).

