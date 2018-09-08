-module(db_SUITE).
%% Note: This directive should only be used in test suites.
-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include("game.hrl").
-include("test.hrl").
-include("wg.hrl").
-include("db.hrl").
-include("goods.hrl").
-include("task.hrl").
-include("skill.hrl").
-include("pet.hrl").
-include("relation.hrl").
-include("mail.hrl").

suite() -> [
    {timetrap,{minutes,2}}
    ].

init_per_suite(Config) ->
    crypto:start(),
    wg_loglevel:set(5),
    ?DEBUG("cwd is :~p", [file:get_cwd()]),
    util:setup_db(),
    File = game_path:conf_file("gh.conf"),
    {ok, _ConfPid} = wg_config:start(?CONF_SERVER, File),
    ?DEBUG("mysql process:~p", [util:mysql_pid()]),
    {ok, _ColleagePid} = colleage_mgr:start_link(),
    unlink(_ColleagePid),
    % 初始化world_id
    ok = world_id:init(),
    AccNames = [?S2B(lists:concat(["test_acc", Id])) 
        || Id <- lists:seq(44441, 44445)],
    [{accnames, AccNames} | Config].

end_per_suite(Config) ->
    clear_acc_data(Config),
    crypto:stop(),
    wg_config:stop(?CONF_SERVER),
    util:stop_db(),
    ok.

init_per_testcase(test_acc, Config) ->
    ok = sys_base_attr:init(),
    ok = sys_common_item:init(),
    ok = sys_task:init(),
    Config;
init_per_testcase(test_equip, Config) ->
    ok = sys_common_item:init(),
    Config;
init_per_testcase(test_skill, Config) ->
    ok = sys_skill:init(),
    Config;
init_per_testcase(Name, Config) ->
    %?DEBUG(?_U("~p 初始化:~n~p"), [Name, Config]),
    Config.

end_per_testcase(Name, Config) ->
    %?DEBUG(?_U("~p 完成:~n~p"), [Name, Config]).
    ok.

all() ->
    [
        test_acc,
        test_skill,
        test_goods,
        test_equip,
        test_pet,
        test_relation, 
        test_mail
    ].

%%-------------------------------------------------------------------------
%% Test cases starts here.
%%-------------------------------------------------------------------------

%% 测试账户
test_acc(Config) ->
    AccNames = ?config(accnames, Config),

    % 清除数据
    % [ok = db_player:delete_by_accname(AccName) || AccName <- AccNames],

    % 插入
    IdRange = ?CONF(id_range),
    [PlayerId | _] = PlayerIds =
    [begin
        {ok, Id} = db_player:create(IdRange, AccName, AccName,
                ?CAREER_SUIHUN, ?SEX_FEMALE),
       Id
    end || AccName <- AccNames],

    % 获取id_list
    [{_, _, _} = db_player:get_id_by_accname(AccName) || AccName <- AccNames],

    % 获取地图
    [{ok, {?MAPID_INIT, 1}, _} = db_player:mapkey_hp(Id)
        || Id <- PlayerIds],

    % 判断玩家是否存在
    true = db_player:is_exist(PlayerId),
    false = db_player:is_exist(PlayerId*3),

    true = db_player:is_exist_by_name(<<"test_acc44441">>),
    false = db_player:is_exist_by_name(<<"not_exist_name...">>),

    % 查询玩家id
    PlayerId = db_player:get_id_by_name(<<"test_acc44441">>),
    
    % 加载玩家
    Players =
    [begin
        #player{id = Id,
            mapid = ?MAPID_INIT,
            career = ?CAREER_SUIHUN,
            sex = ?SEX_FEMALE
        } = db_player:load(Id)
    end || Id <- PlayerIds],

    MapKey = {80888, 1},
    % 保存玩家
    [ok = db_player:save(Player#player{
            mapkey = MapKey,
            career = ?CAREER_DOUJIAN,
            sex = ?SEX_MALE
        }) || Player <- Players],

    % 重新加载
    [begin
        #player{id = PlayerId,
            mapkey = MapKey,
            career = ?CAREER_DOUJIAN,
            sex = ?SEX_MALE
        } = db_player:load(PlayerId)
    end || PlayerId <- PlayerIds],
    {save_config, [{player_ids, PlayerIds}]}.

%% 清理玩家数据
clear_acc_data(Config) ->
    PlayerIds = get_player_ids(Config),
    % 清理数据
    [ok = db_player:delete(PlayerId) || PlayerId <- PlayerIds].

%% 测试技能
test_skill(Config)->
    PlayerIds = [PlayerId | _] = get_player_ids(Config),
    SkillIds = lists:seq(611001, 611005),

    % 清理数据
    ok = db_skill:delete(PlayerId),
    % 技能列表
    [] = db_skill:list(PlayerId),

    % 添加数据
    [ok = db_skill:add(
            #skill{
                player_id = PlayerId,
                skill_id = SkillId,
                lvl = 1
            }) || SkillId <- SkillIds],

    % 更新等级
    [ok = db_skill:update_lvl(PlayerId, SkillId, 2)
        || SkillId <- SkillIds],

    [#skill{
            player_id = PlayerId,
            skill_id = SkillId,
            lvl = 2} = db_skill:get(PlayerId, SkillId)
        || SkillId <- SkillIds],

    % 删除数据
    [ok = db_skill:delete(PlayerId, SkillId)
        || SkillId <- SkillIds],
    {save_config, [{player_ids, PlayerIds}]}.

%% 生成多个guid
gen_ids(N)->
    [?N2B(I) || I <- lists:seq(1, N)].

%% db_goods测试
test_goods(Config)->
    [PlayerId | _] = PlayerIds = get_player_ids(Config),
    Ids = gen_ids(5),
    GoodsList = [#goods{
        id = Id,
        player_id = PlayerId,
        goods_id = 10,
        goods_type = ?GOODS_NORMAL,
        type = 1,
        count = 2,
        repos = 1,
        pos = 10,
        bind = 0,
        expire_time = 0
    } || Id <- Ids],
    % 清理
    ok = db_goods:delete_by_player(PlayerId),

    % 插入
    [ok = db_goods:add(Goods) || Goods <- GoodsList],

    % 更新
    GoodsUps = [#goods{
        id = Id,
        player_id = PlayerId,
        goods_id = 11,
        goods_type = 2,
        count = 3,
        repos = 2,
        pos = 11,
        bind = 0,
        expire_time = 0
    } || Id <- Ids],
    [ok = db_goods:update(GoodsUp) || GoodsUp <- GoodsUps],

    [ok = db_goods:update_pos(Id,2,12) || Id <- Ids],
    [ok = db_goods:update_count(Id, 4) || Id <- Ids],
    [ok = db_goods:update_bind(Id, 1) || Id <- Ids],
    
    % 清理
    [ok = db_goods:delete(Goods) || Goods <- GoodsList],
    {save_config, [{player_ids, PlayerIds}]}.

%% 测试equip
%% 生成一个装备
gen_equip(Id, PlayerId, GoodsId) ->
    #equip{
        id = Id,
        player_id = PlayerId,
        goods_id = GoodsId,
        quality = 4,
        hp = 1,
        mp = 2,
        str = 3,
        agi = 4,
        flex = 5,
        hit = 6,
        dodge = 7,
        crit = 8,
        ten = 19,
        wind_re = 9,
        fire_re = 10,
        water_re = 11,
        earth_re = 12,
        att_phy_min = 13,
        att_phy_max = 14,
        att_phy_add = 141,
        def_phy = 15,
        def_phy_add = 151,
        att_poi = 16,
        def_poi = 17,
        speed = 18,
        attrition = 19
    }.

test_equip(Config) ->
    PlayerIds = [PlayerId | _] = get_player_ids(Config),
    Ids = gen_ids(3),
    GoodsId = 5111000,
    GoodsList = [#goods{
        id = Id,
        player_id = 10,
        goods_id = GoodsId,
        goods_type = ?GOODS_EQUIP,
        count = 2,
        repos = 1,
        pos = 10,
        bind = 0,
        expire_time = 0,
        ptr = gen_equip(Id, PlayerId, GoodsId)
    } || Id <- Ids],
    EquipList = lists:sort([Equip || #goods{ptr = Equip} <- GoodsList]),

    % 清理
    ok = db_equip:delete_by_player(PlayerId),
    ?DEBUG(?_U("装备列表:~n~p"), [EquipList]),

    % 插入
    [ok = db_equip:add(Equip) || Equip <- EquipList],
    % 获取
    EquipList2 = lists:sort(db_equip:list(PlayerId)),
    ?DEBUG(?_U("查询的装备列表:~n~p"), [EquipList2]),

    % 更新
    StrenNew = 15,
    EquipList22 = [Equip#equip{
            stren = StrenNew
        } || Equip <- EquipList],
    [ok = db_equip:update(Equip) || Equip <- EquipList22],
    % 判断更新是否成功
    [begin
        #equip{stren = StrenNew} = Equip
    end || Equip <- db_equip:list(PlayerId)],

    [ok = db_equip:update_attrition(Id, 1000) || Id <- Ids],
    [begin
        #equip{attrition = 1000} = Equip
    end || Equip <- db_equip:list(PlayerId)],
    
    % 清理数据
    [case db_equip:delete(Id) of
        ok ->
            ok;
        false ->
            ok
    end || Id <- Ids],
    {save_config, [{player_ids, PlayerIds}]}.


%% 测试宠物
test_pet(Config)->
    PlayerIds = [PlayerId | _] = get_player_ids(Config),
    PetPoses = lists:seq(1, 5),
    Pet = #pet{
        player_id = PlayerId,
        goods_id = 1,
        lvl = 1,
        name = "hello",
        state = ?PET_STATE_REST,
        exp_cur = 1,
        exp = 2,
        joy = 3,
        life = 4,
        hp = 5,
        mp = 6,
        hp_full = 7,
        mp_full = 8,
        str = 9,
        agi = 10,
        flex = 11,
        att_phy_min = 12,
        att_phy_max = 13,
        def_phy  = 14,
        hp_color = 1,
        mp_color = 2,
        str_color = 3,
        agi_color = 4,
        flex_color = 5
    },
    % 首先清理数据
    [db_pet:delete(PlayerId, Pos) || Pos <- PetPoses],

    % 插入
    [ok = db_pet:add(Pet#pet{pos = P}) || P <- PetPoses],
    L = db_pet:list(PlayerId),
    true = length(PetPoses) =:= length(L),

    % 更新
    State = ?PET_STATE_FIGHT,
    Pos = lists:nth(1, PetPoses),
    ok = db_pet:update_state(PlayerId, Pos, State),
    #pet{state = State} = db_pet:get(PlayerId, Pos),

    Name = "dog",
    ok = db_pet:update_name(PlayerId, Pos, Name),
    Pet2 = #pet{name = <<"dog">>} = db_pet:get(PlayerId, Pos),

    Pet3 = Pet2#pet{lvl = 100, str = 200},
    case db_pet:update(Pet3) of
        ok ->
            ok;
        false ->
            ok
    end,
    Pet3 = db_pet:get(PlayerId, Pos),

    % 清理数据
    [ok = db_pet:delete(PlayerId, P) || P <- PetPoses],
    {save_config, [{player_ids, PlayerIds}]}.


%% 测试玩家关系
test_relation(Config)->
    PlayerIds = [PlayerId | PlayerOther] = get_player_ids(Config),
    Type = ?RELA_FRIEND,

    Relation = #relation{
            idA = PlayerId,
            type = Type
    },

    % 首先清理数据
    [db_relation:delete(PlayerId, IdB) || IdB <- PlayerOther],

    [] = db_relation:list(PlayerId),
    [ok = db_relation:add(Relation#relation{idB = IdB}) || IdB <- PlayerOther],
    L = db_relation:list(PlayerId),
    L1 = [#relation{id = {PlayerId, IdB, ?RELA_FRIEND}, idB = IdB} || IdB <- PlayerOther],
    LCombine = lists:zip(L, L1),
    lists:foreach(
    fun({#relation{id = Id}, #relation{id = Id}}) ->
            ok
    end, LCombine),

    [IdB1 | PlayerOther1] = PlayerOther,
    ok = db_relation:delete(PlayerId, IdB1),
    L2 = db_relation:list(PlayerId),
    L22 = [Relation#relation{id = {PlayerId, IdB, ?RELA_FRIEND}, idB = IdB} || IdB <- PlayerOther1],
    LCombine2 = lists:zip(L2, L22),
    lists:foreach(
    fun({#relation{id = Id}, #relation{id = Id}}) ->
            ok
    end, LCombine2),

    % 清理
    ok = db_relation:delete_by_player(PlayerId),
    [] = db_relation:list(PlayerId),
    {save_config, [{player_ids, PlayerIds}]}.

%% 测试邮件
t_mail(RecvId, Time, SendId, Title, Content, GoodsId) ->
    mod_mail:new_mail(
        RecvId, <<"recv_name">>, ?MAIL_TYPE_SYS, Time, SendId, <<"send_name">>,
        Title, Content, GoodsId, 1, 2, 3, 4).

test_mail(Config)->
    PlayerIds = [PlayerA, PlayerB, PlayerC | _] = get_player_ids(Config),
    % 清理
    [ok = db_mail:delete_by_player(Id) || Id <- PlayerIds],

    % 添加
    [] = db_mail:list(PlayerA),
    GuidB = <<"guidbs234">>,
    MailB = t_mail(PlayerA, ?NOW_SEC, PlayerB, <<"hello_from_a">>, <<"world">>, GuidB),
    GuidC = <<"guidcs111">>,
    MailC = t_mail(PlayerA, ?NOW_SEC + 2, PlayerC, <<"hello_from_c">>, <<"world">>, GuidC),
    ok = db_mail:add(MailB),
    ok = db_mail:add(MailC),
    [MailB2, MailC2] = lists:sort(db_mail:list(PlayerA)),
    [mail, _ | BT] = tuple_to_list(MailB),
    [mail, _ | BT] = tuple_to_list(MailB2),

    [mail, _ | CT] = tuple_to_list(MailC),
    [mail, _ | CT] = tuple_to_list(MailC2),

    % 删除邮件
    ok = db_mail:delete(MailC2#mail.id),
    [MailB2] = db_mail:list(PlayerA),

    % 更新
    ok = db_mail:update_read(MailB2#mail.id, ?MAIL_STATE_READ),
    false = db_mail:update_read(MailB2#mail.id * 20, ?MAIL_STATE_READ),
    [#mail{state_read = ?MAIL_STATE_READ}] = db_mail:list(PlayerA),
    ok = db_mail:update_read(MailB2#mail.id, ?MAIL_STATE_UNREAD),

    ok = db_mail:update_lock(MailB2#mail.id, ?MAIL_STATE_LOCK),
    false = db_mail:update_read(MailB2#mail.id * 20, ?MAIL_STATE_LOCK),
    [#mail{state_lock = ?MAIL_STATE_LOCK}] = db_mail:list(PlayerA),
    
    % 删除附件
    ok = db_mail:delete_attach(MailB2#mail.id),
    [#mail{goods_id = <<>>,
            goods_num = 0, 
            silver = 0, 
            gold = 0
    }] = db_mail:list(PlayerA),

    % 删除所有
    [ok = db_mail:delete_by_player(Id) || Id <- PlayerIds],
    {save_config, [{player_ids, PlayerIds}]}.

clear_acc_db() ->
    AccTab = db_player:table_name(),
    {selected, _, [[N]]} = ?DB_GAME:select(AccTab, ["count(*)"], []),
    if
        N =< 10 ->
            {updated, N} = ?DB_GAME:delete(db_player:table_name(), []),
            ok;
        true ->
            ?WARN("数据库中拥有:~p 条数据，清除请谨慎！", [N]),
            error(db_size)
    end.

%% 从config中查询player ids
get_player_ids(Config) ->
    {_, ConfigAcc} = ?config(saved_config, Config),
    ?config(player_ids, ConfigAcc).
