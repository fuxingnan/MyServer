%%%----------------------------------------------------------------------
%%%
%%% @author: auto generate
%%% @doc: 房间信息 (自动生成，请勿编辑!)
%%%
%%%----------------------------------------------------------------------
-module(proto_team).
-compile([export_all]).
-include("wg.hrl").
-include("game.hrl").
-include("pbmessage_pb.hrl").

cg_join_room(Bin) ->
    {ok, pbmessage_pb:decode_cg_join_room(Bin)}.


encode_s2c(_) -> error({?MODULE, unknown_s2c}).

