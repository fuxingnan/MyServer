%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 关于account数据库相关操作
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(db_account).
-author("huang.kebo@gmail.com").
-vsn('0.1').
-include("wg.hrl").
-include("common.hrl").
-include("errno.hrl").
-include("db.hrl").
-include("account.hrl").

-export([is_exist/2, create/3, set_status/3, delete/2, delete/1,
        set_id_status/3,set_player_id/2,get_max_id/0,get_sid_by_accname/1,set_player_ip/2,get_status/1,change_account/2,get_account_by_playerid/1,set_status_by_sid/2]).

-define(TABLE, "account").
-define(ACCOUNT_ID_START, 0).

%% account的所有持久化字段
-define(FULL_FIELDS, 
    ["accname", "sid", "status", "time", "ip"]).

%% @doc 按player_id删除玩家
delete(PlayerId) when is_integer(PlayerId) ->
    case ?DB_GAME:delete(?TABLE, ["player_id=", db_util:encode(PlayerId)]) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            false;
        {error, _Reason} ->
            ?ERROR(?_U("删除玩家:~p失败"),
                    [PlayerId]),
            ?C2SERR(?E_DB)
    end.
    
%% @doc 删除
delete(AccName, Sid) ->
    case ?DB_GAME:delete(?TABLE, where(AccName, Sid)) of
        {updated, 1} ->
            ok;
        {updated, 0} ->
            false;
        {error, _Reason} ->
            ?ERROR(?_U("删除玩家:~p失败"), 
                    [AccName]),
            ?C2SERR(?E_DB)
    end.

%% @doc 判断帐号是否存在
is_exist(AccName, Sid) ->
    case ?DB_GAME:select(?TABLE, ["status"], where(AccName, Sid)) of
        {selected, _, []} ->
            false;
        {selected, _, [[_]]} ->
            true;
        {error, _Reason} ->
            ?ERROR(?_U("判断玩家:~p帐号是否存在失败:~p"),
                [AccName, _Reason]),
            ?C2SERR(?E_DB)
    end.
%% @doc 获取当前最大玩家id
get_max_id() ->
    case ?DB_GAME:select(?TABLE, ["count(*)"], []) of
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家最大帐号数量失败:~p"), [_Reason]),
            ?C2SERR(?E_DB);
        {selected, _Fields, [[undefined]]} ->
            ?ACCOUNT_ID_START;
        {selected, _Fields, [[Count]]} ->
            ?ASSERT(Count >= ?ACCOUNT_ID_START),
            Count
    end.

%% @doc 创建帐号
create(AccName, Sid, Ip) ->
    Status = ?ACCOUNT_STATUS_INIT,
    Now = wg_util:now_sec(),
    case ?DB_GAME:insert(?TABLE, [AccName, Sid,  Status, Now, Ip]) of
        {updated, 1} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("创建玩家:~p帐号失败:~p"),
                [AccName, _Reason]),
            ?C2SERR(?E_DB)
    end.

get_sid_by_accname(Name) ->
    case ?DB_GAME:select(?TABLE, ["sid"], where(Name, 1)) of
        {selected, _, [[Register]]} ->
            Register;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家playerid出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

get_account_by_playerid(PlayerId) ->
    case ?DB_GAME:select(?TABLE, ["accname"], whereplayerid(PlayerId)) of
        {selected, _, [[Register]]} ->
            Register;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家playeraccount出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

get_status(PlayerId) ->
    case ?DB_GAME:select(?TABLE, ["status"], whereplayerid(PlayerId)) of
        {selected, _, [[Register]]} ->
            Register;
        {selected, _, []} ->
            ?C2SERR(0);
        {error, _Reason} ->
            ?ERROR(?_U("查询玩家playerstatus出错~p"), [_Reason]),
            ?C2SERR(?E_DB)
    end.

%% @doc 设置帐号进度状态
set_player_id(AccName,Id) ->
    case ?DB_GAME:update(?TABLE, ["sid"], [Id], where(AccName, Id)) of
        {updated, _} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("更新玩家:~p的playerid失败:~p"),
                [AccName, _Reason]),
            ?C2SERR(?E_DB)
    end.
%% @doc 设置帐号进度状态
change_account(PlayerId,NewAccount) ->
    case ?DB_GAME:update(?TABLE, ["accname"], [NewAccount], whereplayerid(PlayerId)) of
        {updated, _} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("更新玩家:~p的帐号失败:~p"),
                [PlayerId, _Reason]),
            ?C2SERR(?E_DB)
    end.

set_player_ip(AccName,Ip) ->
    case ?DB_GAME:update(?TABLE, ["ip"], [Ip], where(AccName, Ip)) of
        {updated, _} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("更新玩家:~p的playerip失败:~p"),
                [AccName, _Reason]),
            ?C2SERR(?E_DB)
    end.

set_status_by_sid(Sid, Status) ->
    case ?DB_GAME:update(?TABLE, ["status"], [Status], whereplayerid(Sid)) of
        {updated, _} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("更新玩家:~p的状态失败:~p"),
                [Sid, _Reason]),
            ?C2SERR(?E_DB)
    end.

set_status(AccName, Sid, Status) ->
    case ?DB_GAME:update(?TABLE, ["status"], [Status], where(AccName, Sid)) of
        {updated, _} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("更新玩家:~p的状态失败:~p"),
                [AccName, _Reason]),
            ?C2SERR(?E_DB)
    end.
%% @doc 设置玩家id
set_id_status(AccName, Sid, Status) ->
    case ?DB_GAME:update(?TABLE, ["status"], [Status], where(AccName, Sid)) of
        {updated, _} ->
            ok;
        {error, _Reason} ->
            ?ERROR(?_U("更新玩家:~p的状态失败:~p"),
                [AccName, _Reason]),
            ?C2SERR(?E_DB)
    end.

%%--------------------
%% Internal API
%%--------------------

%% sql需要的条件
where(AccName,_) ->
    ["accname=", db_util:encode(AccName)].

whereplayerid(PlayerId) ->
    ["sid=", db_util:encode(PlayerId)].
