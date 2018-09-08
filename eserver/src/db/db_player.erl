%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2015.06.24
%%% @doc 关于player的数据库相关操作
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(db_player).
-author("huang.kebo@gmail.com").
-vsn('0.1').
-include("wg.hrl").
-include("db.hrl").
-include("errno.hrl").
-include("const.hrl").
-include("newbie.hrl").
-include("player.hrl").

-include("lang.hrl").
-include("common.hrl").

-export([create/1, delete/1]).
-export([is_exist/1, is_exist_by_name/1, get_basic_intro_by_id/1,
    get_career_sex_mapid_by_id/1,
    get_id_by_name/1, get_name_by_id/1, mapkey_hp/1, get_realm_by_id/1,
    get_gold_payment/1, set_gold_vip_payment/4, set_room_card/2,set_gold_payment/3,
    get_max_id/0, get_max_stren_realm/1, get_logout_by_id/1,get_level_by_id/1,
    get_score_by_id/1,get_money_by_id/1,get_registernum_by_id/1,set_Money_by_id/2,set_registernum_by_id/2,
    set_score_by_id/2,set_level_data/4,get_registertime_by_id/1,set_registertime_by_id/2
]).

-export([load/1, save/1, save/2]).
-export([table_name/0, vip_list/0]).


-define(ENCODE, game_misc:encode_term).
-define(DECODE, game_misc:decode_term).

-define(TABLE, "player").
%% player的所有持久化字段
-define(FULL_FIELDS,
    ["id", "roomId", "useId", "unitId", "giveTimes", "lastGiveTime", "money","firstmoney","cardone","cardtwo","gamenum","roomtype","roomcard"
    ]).

-define(_2U(A), unicode:characters_to_binary(A)).

%% @doc 创建角色
create(Id) ->
    do_create(Id, ?PlayerRoomId, ?useid,?unitid,?giveTimes,?lastGiveTime,?PlayerMoney, ?First_Max_Win,?CARD_ONE,?CARD_TWO,?GAME_NUM,?ROOM_TYPE,?ROOM_CARD).

%% @doc 判断玩家是否存在
is_exist(Id) when is_integer(Id) ->
    case ?DB_GAME:select(?TABLE, ["id"], ["id=", db_util:encode(Id)]) of
        {selected, _, [[Id]]} ->
            true;
        {selected, _, []} ->
            false;
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家数据失败:~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 根据玩家id获取等级
get_level_by_id(Id) when is_integer(Id) ->
    case ?DB_GAME:select(?TABLE, ["level"], ["id=", db_util:encode(Id)]) of
        {selected, _, [[Level]]} ->
            Level;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家等级出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.
%% @doc 根据玩家id获取得分
get_score_by_id(Id) when is_integer(Id) ->
    case ?DB_GAME:select(?TABLE, ["score"], ["id=", db_util:encode(Id)]) of
        {selected, _, [[Score]]} ->
            Score;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家得分出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.
%% @doc 根据玩家id获取金钱
get_money_by_id(Id) when is_integer(Id) ->
    case ?DB_GAME:select(?TABLE, ["money"], ["id=", db_util:encode(Id)]) of
        {selected, _, [[Money]]} ->
            Money;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家金钱出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.
%% @doc 根据玩家id获取签到次数
get_registernum_by_id(Id) when is_integer(Id) ->
    case ?DB_GAME:select(?TABLE, ["registernum"], ["id=", db_util:encode(Id)]) of
        {selected, _, [[Register]]} ->
            Register;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家签到次数出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.
%% @doc 根据玩家id获取上次签到时间
get_registertime_by_id(Id) when is_integer(Id) ->
    case ?DB_GAME:select(?TABLE, ["extraone"], ["id=", db_util:encode(Id)]) of
        {selected, _, [[RegisterTime]]} ->
            RegisterTime;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家上次签到时间出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 根据玩家名字判断是否存在
is_exist_by_name(Name) when is_binary(Name) ->
    case catch get_id_by_name(Name) of
        {error, _} ->
            false;
        Id when is_integer(Id) ->
            true
    end.

%% @doc 根据平台帐号获取角色信息+地图id
get_career_sex_mapid_by_id(Id) ->
    case ?DB_GAME:select(?TABLE, ["career", "sex", "mapid", "realm"],
        ["id=", db_util:encode(Id)]) of
        {error, _Reason} ->
            ?ERROR(?_U("获取角色id+mapid出错:~p"), [_Reason]),
            ?C2SERR(?E_DB);
        {selected, _Fields, []} ->
            ?C2SERR(0);
        {selected, _Fields, [[Career, Sex, MapId, Realm]]} ->
            {Career, Sex, MapId, Realm}
    end.

%% @doc 根据玩家名字获取id
get_id_by_name(Name) when is_binary(Name) ->
    case ?DB_GAME:select(?TABLE, ["id"], ["name=", db_util:encode(Name)]) of
        {selected, _, [[Id]]} ->
            Id;
        {selected, _, []} ->
            ?INFO(?_U("玩家不存在~p"), [Name]),
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家id出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 根据玩家id获取姓名
get_name_by_id(Id) when is_integer(Id) ->
    case ?DB_GAME:select(?TABLE, ["name"], ["id=", db_util:encode(Id)]) of
        {selected, _, [[Name]]} ->
            Name;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家名字出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 根据玩家id获取阵营
get_realm_by_id(Id) when is_integer(Id) ->
    case ?DB_GAME:select(?TABLE, ["realm"], ["id=", db_util:encode(Id)]) of
        {selected, _, [[Realm]]} ->
            Realm;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家阵营出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 根据玩家id获取最后登出时间
get_logout_by_id(Id) when is_integer(Id) ->
    case ?DB_GAME:select(?TABLE, ["last_logout_time"], ["id=", db_util:encode(Id)]) of
        {selected, _, [[Time]]} ->
            Time;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家登出时间出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 根据玩家id获取姓名
get_basic_intro_by_id(Id) when is_integer(Id) ->
    Fields = [
      "name",
      "lvl",
      "sex",
      "career",
      "vip",
      "last_login_time"
    ],
    case ?DB_GAME:select(?TABLE, Fields, ["id=", db_util:encode(Id)]) of
        {selected, _, [[Name, Lvl, Sex, Career, Vip, LastLogin]]} ->
            Intro = #player_basic_intro{
                id      = Id,
                name    = Name,
                lvl     = Lvl,
                sex     = Sex,
                career  = Career,
                battle_stren = 0,
                vip     = ?IF(Vip > 0, 1, 0),
                guild_name = <<>>,
                last_login_time = LastLogin
            },
            {ok, Intro};
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家名字出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 获取玩家所在的地图和血量
mapkey_hp(Id) ->
    case ?DB_GAME:select(?TABLE, ["mapid", "instance", "hp"], where(Id)) of
        {selected, _, [[MapId, Instance, HP]]} ->
            {ok, {MapId, Instance}, HP};
        {error, _Reason} ->
            {error, _Reason}
    end.

%% @doc 获取玩家的金币和累积充值
get_gold_payment(Id) ->
    case ?DB_GAME:select(?TABLE, ["gold", "total_payment"], where(Id)) of
        {selected, _, [[Gold, TotalPayment]]} ->
            {Gold, TotalPayment};
        {error, _Reason} ->
            ?C2SERR(?E_DB)
    end.

%% @doc 设置金币和vip等级
set_gold_vip_payment(Id, Gold, Vip, TotalPayment) ->
    case ?DB_GAME:update(?TABLE, ["gold", "vip", "total_payment"],
        [Gold, Vip, TotalPayment], where(Id)) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            ?WARN(?_U("更新玩家:~p金币和vip返回0"), [Id]),
            ok;
        {error, _Reason} ->
            ?C2SERR(?E_DB)
    end.

set_level_data(Id,Level,Score,Money) ->
    case ?DB_GAME:update(?TABLE, ["level", "score"  "money"],
        [Level, Score,Money], where(Id)) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            ?WARN(?_U("更新玩家:~p等级返回0"), [Id]),
            ok;
        {error, _Reason} ->
            ?C2SERR(?E_DB)
    end.
set_Money_by_id(Id,Money) ->
    case ?DB_GAME:update(?TABLE, ["money"],
        [Money], where(Id)) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            ?WARN(?_U("更新玩家:~p金钱返回0"), [Id]),
            ok;
        {error, _Reason} ->
            ?C2SERR(?E_DB)
    end.
set_registernum_by_id(Id,RegisterNum) ->
    case ?DB_GAME:update(?TABLE, ["registernum"],
        [RegisterNum], where(Id)) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            ?WARN(?_U("更新玩家:~p签到返回0"), [Id]),
            ok;
        {error, _Reason} ->
            ?C2SERR(?E_DB)
    end.
set_score_by_id(Id,Score) ->
    case ?DB_GAME:update(?TABLE, ["score"],
        [Score], where(Id)) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            ?WARN(?_U("更新玩家:~p得分返回0"), [Id]),
            ok;
        {error, _Reason} ->
            ?C2SERR(?E_DB)
    end.

set_registertime_by_id(Id,Time) ->
    case ?DB_GAME:update(?TABLE, ["extraone"],
        [Time], where(Id)) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            ?WARN(?_U("更新玩家:~p签到时间返回0"), [Id]),
            ok;
        {error, _Reason} ->
            ?C2SERR(?E_DB)
    end.

%% @doc 设置金币
set_room_card(Id, RoomCard) ->
    case ?DB_GAME:update(?TABLE, ["roomcard"],
        [RoomCard], where(Id)) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            ?WARN(?_U("更新玩家:~p房卡失败返回0"), [Id]),
            ok;
        {error, _Reason} ->
            ?C2SERR(?E_DB)
    end.

%% @doc 设置金币
set_gold_payment(Id, Gold, TotalPayment) ->
    case ?DB_GAME:update(?TABLE, ["gold", "total_payment"],
        [Gold, TotalPayment], where(Id)) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            ?WARN(?_U("更新玩家:~p金币和vip返回0"), [Id]),
            ok;
        {error, _Reason} ->
            ?C2SERR(?E_DB)
    end.

%% @doc 获取当前最大玩家id
get_max_id() ->
    case ?DB_GAME:select(?TABLE, ["max(id)"], []) of
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家最大id失败:~p"), [_Reason]),
            ?C2SERR(?E_DB);
        {selected, _Fields, [[undefined]]} ->
            ?PLAYER_ID_START;
        {selected, _Fields, [[MaxId]]} ->
            ?ASSERT(MaxId >= ?PLAYER_ID_START),
            MaxId
    end.

%% @doc 获取指定国家的战斗力最的
%% 玩家
get_max_stren_realm(Realm) ->
    case ?DB_GAME:select(?TABLE, ["id", "name", "att_phy_max"], where_max_stren(Realm)) of
        {selected, _, [[Id, Name, BattleStren] |_]} ->
            {Id, Name, BattleStren};
        {selected, _, []} ->
            {0, "BOSS", 0};
        {error, _Reason} ->
            ?C2SERR(?E_DB)
    end.

%% @doc 加载数据 #player
load(Id) ->
    Fields = ?FULL_FIELDS,
    case ?DB_GAME:select(?TABLE, Fields, ["id=", db_util:encode(Id)]) of
        {error, _Reason} ->
            ?ERROR("get role_list error:~p", [_Reason]),
            [];
        {selected, _Fields, [Row]} ->
            %?DEBUG("selected fields:~p~nrow:~p", [_Fields, Row]),
            fields_to_player(Row)
    end.

%% @doc 存储玩家数据
save(Player) ->
    save(Player, false).


save(Player, WhenOffLine) ->
    ["id" | Fields] = ?FULL_FIELDS,
    [Id | Vals] = player_to_fields(Player, WhenOffLine),
    case ?DB_GAME:update(?TABLE, Fields, Vals, ["id=", db_util:encode(Id)]) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("保存玩家:~p的数据失败:~p"), [Id, _Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 获取表名称
table_name() ->
    ?TABLE.

%% @doc 获取vip用户id列表
vip_list() ->
    case ?DB_GAME:select(?TABLE, ["id"], ["vip<>0"]) of
        {selected, _, List} ->
            List;
        {error, _Reason} ->
            ?ERROR(?_U("查询vip列表失败:~p"),
                [_Reason]),
            ?C2SERR(?E_DB)
    end.



%%-----------------
%%  清档使用
%%-----------------
%% @doc 清理玩家
%% 充值0,lvl<40,now-last_logout_time>2592000
%% @end
%%clean_db() ->
 %%   end.

%% @doc 删除角色,清档用
delete(Id) ->
    Fun =
        fun() ->
          % 删除玩家数据
          case ?DB_GAME:delete(?TABLE, ["id=", db_util:encode(Id)]) of
              {updated, 1} ->
                  ok;
              _ ->
                  ?C2SERR(?E_NEXIST)
          end
        end,
    case ?DB_GAME:transaction(Fun, ?TIMEOUT) of
        {atomic, Res} ->
            %?DEBUG(?_U("删除玩家数据成功:~p"), [Res]),
            Res;
        _Reason ->
            ?ERROR(?_U("删除玩家数据失败:~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%%----------------
%% internal API
%%----------------
do_create(Id, RoomId, Useid,UnitId,GiveTimes,LastGiveTime,Money,Max_Win,CARD_ONE,CARD_TWO,GAME_NUM,ROOM_TYPE,Room_Card)->
    %?DEBUG(?_U("创建角色id:~p 等级:~p 金钱:~p"),
        %[Id, Level,Money]),
    Vals = [Id, RoomId, Useid,UnitId,GiveTimes,LastGiveTime,Money,Max_Win,CARD_ONE,CARD_TWO,GAME_NUM,ROOM_TYPE,Room_Card],
    case ?DB_GAME:insert(?TABLE, Vals) of
        {updated, 1} ->
            %?INFO(?_U("数据库添加玩家成功")),
            {ok,Id};
        {error, <<"#23000", _/bytes>>} ->
            % #23000Duplicate entry '123' for key 'name'
            %game_log:dup_name(Id),
            ?C2SERR(?E_CREATEROLE_FAIL_NAMEEXIST);
        _Other ->
            ?DEBUG(?_U("数据库错误:~p"), [_Other]),
            ?C2SERR(?E_DB)
    end.


%% 新手数据初始化
%%------------------


where(Id) ->
    ["id=", db_util:encode(Id)].

%% 指定国家
where_max_stren(Realm) ->
    ["realm=", db_util:encode(Realm), " and att_phy_max = (select max(att_phy_max) from     player where realm =", db_util:encode(Realm), ")"].

%% 转成ids列表和names列表等
to_ids_names_lvls_types_models(Rows, _Fields) ->
    case Rows of
        [] ->
            lists:duplicate(length(_Fields), []);
        _ ->
            wg_lists:unzip_more(Rows)
    end.

%% row转化成#player
fields_to_player(
    [Id, PlayerRoomId, Useid, Unitid, GiveTimes, LastGiveTime, PlayerMoney,First_Max_Win,CARD_ONE,CARD_TWO,GAME_NUM,ROOM_TYPE,Room_Card]
) ->
    Player = #player{
        id = Id,
        room_id = PlayerRoomId,
        user_id = Useid,
        unit_id = Unitid,
        giveTimes = GiveTimes,
        lastGiveTime = LastGiveTime,
        money = PlayerMoney,
        firstmoney = First_Max_Win,
        cardone = CARD_ONE,
        cardtwo = CARD_TWO,
        gamenum = GAME_NUM,
        roomtype = ROOM_TYPE,
        card_room = Room_Card
    },
    Player.

%% #player转化成fields
%% player_server在进程退出时做了时间修改，所以此处被延时写调用时不修改退出时间
player_to_fields(#player{
    id = Id,
    room_id = PlayerRoomId,
    user_id = Useid,
    unit_id = Unitid,
    giveTimes = GiveTimes,
    lastGiveTime = LastGiveTime,
    money = PlayerMoney,
    firstmoney = First_Max_Win,
    cardone = CARD_ONE,
    cardtwo = CARD_TWO,
    gamenum = GAME_NUM,
    roomtype = ROOM_TYPE,
    card_room = Card_Room
} = Player, _WhenOffLine) ->
   [Id, PlayerRoomId, Useid, Unitid, GiveTimes, LastGiveTime, PlayerMoney,First_Max_Win,CARD_ONE,CARD_TWO,GAME_NUM,ROOM_TYPE,Card_Room].

