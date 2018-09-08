%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc 平台接入接口的验证,未配置的情况下只做参数解析，不做合法性检查
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(game_partner_dev).
-author("huang.kebo@gmail.com").
-vsn('1.0').

-include("wg.hrl").
-include("errno.hrl").
-include("game.hrl").
-include("../src/proto/proto.hrl").
-include("pbmessage_pb.hrl").

-export([auth/1, parse_cm/1, identify/3]).

-define(IDENTIFY_TIMEOUT, 50000).

%% @doc 验证登录是否合法，返回用户在平台中的标示，以及防沉迷状态
auth(#cg_login{account = Account} = _Req) ->
    {ok, Account, 0, 2}.

%% @doc 游客永远使用默认的防沉迷状态
parse_cm(_Cm) ->
    0.

%% @doc 游客不可以通过防沉迷，只能用默认值
identify(_AccName, _Name, _Num) ->
    game_partner_4399:identify(_AccName, _Name, _Num).
    %{ok, ?FCM_CHECKED_DEFAULT}.
