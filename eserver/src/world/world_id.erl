%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 用来为每个对象生成一个唯一id, 基于mnesia实现
%%%
%%%----------------------------------------------------------------------
-module(world_id).
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg.hrl").
-include("game.hrl").

-export([init/0, init/1, clear/0]).
-export([i/0]).
-export([new/0, new/1]).
-export([player/0,
        goods/0,
        colleage/0,
        box/0,
        mount/0,
        pet/0,
        mail/0,
        guild/0,
        mon/0,
        master/0,
        account/0
    ]).

%% 用来帮助生成唯一id
-record(world_id, {
        type,       % 类型 
        count       % 计数,可能为int或binary(默认为int)
    }).

-define(TABLE, world_id).

%% id类型
-define(ID_TYPE_DEFAULT, '$id_type_default').

-define(ID_TYPE_PLAYER, '$id_player').
-define(ID_TYPE_ACCOUNT, '$id_type_account').

-define(ID_TYPE_GOODS, '$id_type_goods').
-define(ID_TYPE_COLLEAGE, '$id_type_colleage').
-define(ID_TYPE_MASTER, '$id_type_master').
-define(ID_TYPE_BOX, '$id_type_box').
-define(ID_TYPE_MOUNT, '$id_type_mount').
-define(ID_TYPE_PET, '$id_type_pet').
-define(ID_TYPE_MAIL, '$id_type_mail').
-define(ID_TYPE_GUILD, '$id_type_guild').
-define(ID_TYPE_MON, '$id_type_mon').

%% @doc 初始化,加载持久化数据(game使用)
init() ->
    init(true).

%% @doc 初始化
init(LoadData) ->
    % 确保mnesia运行中
    wg_mnesia:ensure_mnesia_is_running(),
    % 链接其他节点
    wg_mnesia:conn_nodes(nodes()),
    % 创建表
    case wg_mnesia:is_table_exists(?TABLE) of
        true ->
            %?DEBUG("~p table exists", [?TABLE]),
            ok;
        false ->
            ?DEBUG(?_U("~p table not exists"), [?TABLE]),
            {atomic, ok} =
            mnesia:create_table(?TABLE, 
                [{type, set}, 
                {ram_copies, [node()]},
                {attributes, record_info(fields, world_id)}]),
            ok
    end,

    % 初始化计数
    ?IF(LoadData, ok = do_init_count(), ok),
    ok.

%% @doc 清除
clear() ->
    {atomic, ok} = mnesia:delete_table(?TABLE),
    ok.

%% @doc 当前状态
i() ->
    All = mnesia:dirty_match_object(wg_mnesia:wild_pattern(?TABLE)),
    [begin
        #world_id{type = Type, count = Count} = E,
        {Type, Count}
    end || E <- All].

%% @doc 为游戏中的对象提供唯一id
new() ->
    do_new(?ID_TYPE_DEFAULT).

%% @doc 为游戏中对象提供唯一id
new(Type) ->
    do_new(Type).

%% @doc 获取新的玩家唯一id
player() ->
    do_new(?ID_TYPE_PLAYER).

%% @doc 获取新的玩家唯一id
account() ->
    do_new(?ID_TYPE_ACCOUNT).

%% @doc 获取新的物品唯一id
goods() ->
    do_new(?ID_TYPE_GOODS).

%% @doc 获取新的学院唯一id
colleage() ->
    do_new(?ID_TYPE_COLLEAGE).

%% @doc 箱子id, binary
box() ->
    do_new(?ID_TYPE_BOX).

%% @doc 坐骑id, binary
mount() ->
    ?MOUNT_OBJ_ID(do_new(?ID_TYPE_MOUNT)).

%% @doc 获取新的宠物id, int
pet() ->
    do_new(?ID_TYPE_PET).

%% @doc 获取新的邮件id, int
mail() ->
    do_new(?ID_TYPE_MAIL).

%% @doc 获取新的工会id, int
guild() ->
    do_new(?ID_TYPE_GUILD).

%% @doc 获取师门唯一id
master()    ->
    do_new(?ID_TYPE_MASTER).

%% doc 获取新的怪物id
mon() ->
    ?MON_OBJE_ID(do_new(?ID_TYPE_MON)).

%%--------------
%% internal API
%%--------------

%% 初始化计数
%-ifdef(COMM_TEST).
do_init_count() ->
    PlayerMaxId = max(db_player:get_max_id(), ?PLAYER_ID_START),
    AcountMaxId = max(db_account:get_max_id(), ?ACCOUNT_ID_START),
    ?DEBUG(?_U("玩家的最大id为:~b"), [PlayerMaxId]),
    do_set_count(?ID_TYPE_PLAYER, PlayerMaxId),
    do_set_count(?ID_TYPE_ACCOUNT, AcountMaxId).
%-else.
%do_init_count() ->
    % 计算id最小值，确保各服id起点不同，合服时比较方便，将来跨服战也会好做些
    %SidList = ?CONF(server_ids, [0]),
    %MaxSid = lists:min(SidList),
    %BaseNormal = MaxSid * 1000000,
    %BaseGoods = MaxSid * 100000000,
    %BaseMasters = MaxSid * 10000,




%% 设置id
do_set_count(Type, Count) ->
    Fun =
    fun() ->
            WorldId = #world_id{type = Type, count = Count},
            mnesia:write(WorldId)
    end,
    case mnesia:transaction(Fun) of
        {atomic, ok} ->
            ok;
        _Reason ->
            ?ERROR(?_U("设置类型:~p count失败:~p"), [Type, _Reason]),
            ?C2SERR(?E_UNKNOWN)
    end.

%% 生成新的id
%% 使用dirty_update_counter,其仍然可以保证原子性
do_new(Type) ->
    case catch mnesia:dirty_update_counter(?TABLE, Type, 1) of
        {'EXIT', _Reason} ->
            ?ERROR(?_U("类型:~p自增id失败:~p"), [Type, _Reason]),
            ?C2SERR(?E_UNKNOWN);
        Id ->
            Id
    end.

%%-------------
%% Eunit Test
%%-------------

-ifdef(EUNIT).

basic_test_() ->
    {inorder, {setup,
        fun() ->init(false) end,
        fun(_) -> clear() end,
        [
            ?_assertEqual(1, new()),
            ?_assertEqual(2, new()),
            ?_assertEqual(3, new()),
            ?_assertEqual(1, new('&dummmmmmy_type')),
            ?_assertEqual(2, new('&dummmmmmy_type')),

            ?_assertEqual(1, player()),
            ?_assertEqual(<<"1">>, goods()),
            ?_assertEqual(1, colleage()),
            ?_assertEqual(1, box()),
            ?_assertEqual(1, mount()),
            ?_assertEqual(1, pet()),
            ?_assertEqual(1, mail())
        ]}}.

-endif.
