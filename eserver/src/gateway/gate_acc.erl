%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 关于帐号的处理(由gateway调用)
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(gate_acc).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("game.hrl").
-include("account.hrl").
-include("gate_internal.hrl").
-include("../src/proto/proto.hrl").
-include("pbmessage_pb.hrl").


-export([handle/2, make_random_user/1,random_name/0]).



handle(#cg_createrole{type = Version} = Req, #client_state{accname = AccName} = _State) ->
    MsgId = ?PROTO_CONVERT({mod_acc, gc_createrole_ret}),
    % 创建role(player)
    case catch do_create(AccName) of
        {ok, Id} ->
            Code = ?E_CREATEROLE_SUCCESS;
        {error, Code} ->
            Id = 0
    end,

    {ok, MsgId, #gc_createrole_ret{
        result = Code,
        playerguid = Id
    }};

handle(#cg_connected_heartbeat{} = Req, #client_state{accname = AccName} = _State) ->
    ok;

handle(#cg_selectrole{roleguid = PlayerId}, #client_state{accname = AccName}) ->

    case db_player:is_exist(PlayerId) of
        true->
            MsgId = ?PROTO_CONVERT({mod_acc, gc_selectrole_ret}),
            {ok, MsgId, #gc_selectrole_ret{
                result = ?E_OK,
                playerguid = PlayerId
            }};
        false->
            case catch do_create(AccName) of
                {ok, Id} ->
                    Id;
                {error, _Code} ->
                    Id = 0
            end,

            MsgId = ?PROTO_CONVERT({mod_acc, gc_selectrole_ret}),
            {ok, MsgId, #gc_selectrole_ret{
                result = ?E_OK,
                playerguid = Id
            }}
    end.

%% @doc 生成一个随机用户
-define(CREATE_GUEST_RETRY, 'create_guest_retry').
make_random_user(#client_state{ip = _Ip} = _State) ->
    % 不做重名检查，名称空间1400万，重了也无所谓
    Name = random_name(),
    {ok, Name}.

%% 随机一个字符串序列
random_name() ->
    LastName1 = wg_lists:rand_pick(?LAST_NAME_1),
    % LastName2 = wg_lists:rand_pick(?LAST_NANE_2),
    FirstName = wg_lists:rand_pick(?FIRST_NAME_LIST),
    ?U2B(lists:append([FirstName, LastName1])).




%%----------------
%% internal API
%%----------------

%% 创建玩家
do_create(AccName) ->
    Id = world_id:player(),
   % ?DEBUG(?_U("创建player对应id:~p"), [Id]),
    {ok, CreateId} = db_player:create(Id),
    ok = db_account:set_player_id(AccName,CreateId),
    {ok, CreateId}.


