%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 后台玩家api,参考<游戏_后台HTTP接口>
%%% @end
%%%----------------------------------------------------------------------
-module('_http_api_user').
-author("huang.kebo@gmail.com").
-vsn('1.0').
-include("wg.hrl").
-include("wg_httpd.hrl").
-include("wg_log.hrl").
-include("errno.hrl").
-include("const.hrl").
-include("lang.hrl").
-include("world_api.hrl").

-export([handle/2]).

%% @doc 处理后台api
handle(Req, Method) ->
    Qs = 
    case Method of
        'GET' ->
            Req:parse_qs();
        'POST' ->
            Req:parse_post()
    end,
    Msg = ?QS_GET("msg", Qs, ""),
    case catch handle_msg(Msg, Qs) of
        ok ->
            %game_log:api_user(Msg, Req:get(raw_path)),
            {200, [], ?N2S(?API_SUCCESS)};
        {error, Code} ->
            {200, [], ?N2S(Code)};
        _Other ->
            ?ERROR(?_U("处理api/user请求,发生未知错误:~p"), [_Other]),
            {500, [], io_lib:format("~p", [_Other])}
    end.

%%---------------
%% Internal API
%%---------------

%% 处理具体的消息
handle_msg("1021", Qs) ->
    [Id, Gold] = get_qs(Qs, ["id", "yb"]),
    case catch player_server:admin_payment(?S2N(Id), ?S2N(Gold)) of
        ok ->
            ok;
        _Other ->
            ?ERROR(?_U("玩家:~p充值错误!:~p"), [Id, Gold]),
            {error, ?API_PAYMENT}
    end;
% 赠送元宝(走邮件)
handle_msg("1022", Qs) ->
    [Id, YB] = get_qs(Qs, ["id", "yb"]),
    mod_mail:send_sys_mail(?SYSTEM_ID_WEBAPI, ?S2N(Id), 
        "_LANG_ADMIN_ADD_GOLD_TITLE", %?_LANG_ADMIN_ADD_GOLD_TITLE,
        "_LANG_ADMIN_ADD_GOLD_CONTENT", %?_LANG_ADMIN_ADD_GOLD_CONTENT,
        0, ?S2N(YB), 0, 0);

%% 设置玩家vip等级
handle_msg("1023", Qs) ->
    [Id, Vip_lvl] = get_qs(Qs, ["id", "vip_lvl"]),
    Id1 = ?S2N(Id),
    Vip_lvl1 = ?S2N(Vip_lvl),
    player_server:admin_set_vip_lvl(Id1, Vip_lvl1);

% 踢人
handle_msg("1031", Qs) ->
    [Id] = get_qs(Qs, ["id"]),
    ok = player_server:stop(?S2N(Id), kick),
    ok;
% 禁言
handle_msg("1032", Qs) ->
    [Id, Time] = get_qs(Qs, ["id", "time"]),
    ok = player_server:admin_ban_chat(?S2N(Id), ?S2N(Time)),
    ok;
% 解除禁言
handle_msg("1033", Qs) ->
    [Id] = get_qs(Qs, ["id"]),
    ok = player_server:admin_enable_chat(?S2N(Id)),
    ok;
% 封号(禁登录)
handle_msg("1034", Qs) ->
    [Id, Time] = get_qs(Qs, ["id","time"]),
     ok = player_server:admin_ban_acc(?S2N(Id), ?S2N(Time)),
    ok;
% 解除封号（解禁登录）
handle_msg("1035", Qs) ->
    [Id] = get_qs(Qs, ["id"]),
    ok = player_server:admin_enable_acc(?S2N(Id)),
    ok;
% 封ip
handle_msg("1036", Qs) ->
    [Ip, Time] = get_qs(Qs, ["ip", "time"]),
    ok = gm_ctrl:add_ip_ban(?S2N(Time), Ip),
    ok;
% 解除ip封锁
handle_msg("1037", Qs) ->
    [Ip] = get_qs(Qs, ["ip"]),
    ok = gm_ctrl:delete_ip_ban(Ip),
    ok;

%% 增加经验
handle_msg("1201", Qs) ->
     [Id, Exp] = get_qs(Qs, ["id", "exp"]),
     ok = player_server:admin_inc_exp(?S2N(Id), ?S2N(Exp)),
     ok;

%% 副本计数清零
handle_msg("1202", Qs) ->
    [Id, MapId] = get_qs(Qs, ["id", "mapid"]),
    player_server:admin_clear_dungeon_count(?S2N(Id), ?S2N(MapId)),
    ok;

%% 删除物品
handle_msg("1203", Qs) ->
    [Id, GoodsId] = get_qs(Qs, ["id", "goods_id"]),
    player_server:admin_del_goods(?S2N(Id), ?S2B(GoodsId)),
    ok;

% 设置玩家所在地图和坐标
% handle_msg("1104", Qs) ->
%     [Id, MapId, X, Y] = get_qs(Qs, ["role_id", "mapid", "x", "y"]),
%     ok = player_server:admin_map_switch(?S2N(Id), ?S2N(MapId), ?S2N(X), ?S2N(Y)),
%     {ok, ?API_UNKNOWN};

% 发送邮件
handle_msg("1105", Qs) ->
    IdsStr = ?QS_GET("ids", Qs),
    Title = ?QS_GET("title", Qs),
    Content = ?QS_GET("content", Qs, ""),
    Silver = ?S2N(?QS_GET("silver", Qs, "0")),
    Gold = ?S2N(?QS_GET("gold", Qs, "0")),
    GoodsId = ?S2N(?QS_GET("goods_id", Qs, "0")),
    GoodsCount = ?S2N(?QS_GET("count", Qs, "1")),
    IdList = string:tokens(IdsStr, ","),
    Ids = [?S2N(Id) || Id <- IdList],
    % 发送物品
    case catch mod_mail:send_sys_mail(?SYSTEM_ID_WEBAPI, Ids, Title, Content, Silver, Gold, 
            GoodsId, GoodsCount) of
        {error, Code} ->
            {error, Code};
        ok ->
            ok
    end;
handle_msg(_Msg, _Qs) ->
    ?WARN(?_U("后台api收到未知的消息类型:~w"), [_Msg]),
    {error, ?API_UNKNOWN}.

%% 获取qs参数
get_qs(Qs, Keys) ->
    [begin
        case ?QS_GET(Key, Qs) of
            undefined ->
                ?ERROR(?_U("参数:~p"), [Key]),
                throw({error, ?API_BADARG});
            Val ->
                Val
        end
    end || Key <- Keys].
