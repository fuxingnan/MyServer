%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc the game ctl module
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(game_ctl).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("common.hrl").

-export([start/0, init/0, process/1]).

-define(STATUS_SUCCESS, 0).     % 成功
-define(STATUS_AGAIN,   1).     % 进行中,请重试
-define(STATUS_USAGE,   2).     % 使用错误
-define(STATUS_BADRPC,  3).     % rpc调用错误
-define(STATUS_ERROR,  4).      % 其它错误

start() ->
    %%noinspection ErlangIncludeDirectories
    case init:get_plain_arguments() of
    [SNode | Args]->
        %?PRINT("plain arguments is(~p):~n~p~n", [length(Args), Args]),
        SNode1 = case string:tokens(SNode, "@") of
        [_Node, _Server] ->
            SNode;
        _ ->
            case net_kernel:longnames() of
             true ->
                 SNode ++ "@" ++ inet_db:gethostname() ++
                      "." ++ inet_db:res_option(domain);
             false ->
                 SNode ++ "@" ++ inet_db:gethostname();
             _ ->
                 SNode
             end
        end,
        Node = list_to_atom(SNode1),
        Status = case rpc:call(Node, ?MODULE, process, [Args]) of
             {badrpc, _Reason} ->
                 %?PRINT("RPC failed on the node ~p: ~p~n", [Node, _Reason]),
                 ?STATUS_BADRPC;
             S ->
                 %?PRINT("RPC return :~p~n", [S]),
                 S
             end,
        halt(Status);
    _ ->
        halt(?STATUS_USAGE)
    end.

init() ->
    ok.

process(["status"]) ->
    do_status([gate_app, world_app]);
process(["status", App]) ->
    do_status([?S2A(App)]);
process(["stop"]) ->
    gate_node:stop_server(),
    init:stop(),
    ?STATUS_SUCCESS;

process(["restart"]) ->
    init:restart(),
    ?STATUS_SUCCESS;
% 重新加载数据
process(["reload", Type]) ->
    case Type of
        "config" ->
            ok = wg_config:reload(?CONF_SERVER),
            ?STATUS_SUCCESS;
        "code" ->
            case wg_reloader:reload() of
                [] ->
                    ?STATUS_SUCCESS;
                L ->
                    ?PRINT("modules:~p reload failed\n", [L]),
                    ?STATUS_ERROR
            end;
        "all_data" ->
            ?IF(catch game_misc:reload_sys_data() =:= ok,
                ?STATUS_SUCCESS, ?STATUS_ERROR);
        _ ->
            Mod = 
            case Type of
                "sys_" ++ _ ->
                    ?S2A(Type);
                _ ->
                    ?S2A("sys_" ++ Type)
            end,
            ?IF(game_misc:reload_sys_data(Mod) =:= ok,
                ?STATUS_SUCCESS, ?STATUS_ERROR)
    end;
process([_|_]) ->
    ?STATUS_USAGE.

%%-------------------
%% internal API
%%-------------------

%% 获取对应app的状态
do_status(Apps) ->
    %{InternalStatus, _ProvidedStatus} = init:get_status(),
    %?PRINT("Node ~p is ~p. Status: ~p~n",
    %          [node(), InternalStatus, _ProvidedStatus]),
    case wg_util:is_app_running(Apps) of
        true ->
            %?PRINT("node is running~n", []),
            ?STATUS_SUCCESS;
        false ->
            %?PRINT("node:~p~n", [node()]),
            %?PRINT("node is not running:~p~n", [application:which_applications()]),
            ?STATUS_AGAIN
    end.
