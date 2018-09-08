%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc player app内部使用
%%%
%%%----------------------------------------------------------------------
-ifndef(PLAYER_INTERNAL_HRL).
-define(PLAYER_INTERNAL_HRL, true).
-include("../src/proto/proto.hrl").

-define(PLAYER_SUP, player_sup).
-define(ROBOT_SUP, robot_sup).
-define(PLAYER_STEP_TICK, player_step_tick). % 玩家每走一格需要的时间
-define(PLAYER_STEP_CD, player_step_cd). % 玩家每走一格的允许的cd时间


-define(NEWBIE_ROBOT_SUP, newbie_robot_sup).

%%---------------
%% 数据同步timer
%%---------------

%% 数据同步event
-define(DATA_SYNC_EVENT, '$mod_data_sync_event').

%SILP:db_schema:hrl_record(player_attribs, true)
%% Player额外属性基本信息(修改数据库时，需要修改此record) %__SILP__
-record(player_attribs, {                                                     %__SILP__
    player_id,          %% 会员ID                                           %__SILP__
    fellow_skills_str,  %% 伙伴技能（Erlang List Encoded as String）    %__SILP__
    %% 以上是持久化数据，以下是非持久化数据                 %__SILP__
    fellow_skills = [], %% 伙伴技能（Erlang List）
    fellows = []        %% 伙伴（Erlang List）
%SILP:db_schema:hrl_record_end(player_attribs)
}).                                                                    %__SILP__
-type player_attribs() :: #player_attribs{}.                           %__SILP__

-endif. % PLAYER_INTERNAL_HRL
