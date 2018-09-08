%%%-------------------------------------------------------------------
%%% @author fx
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%     通过查询数据库生成exp相关的东西
%%% @end
%%% Created : 14. 七月 2015 下午3:43
%%%-------------------------------------------------------------------
-module(gen_daily_reward).
-include("genbase.hrl").
-include("db.hrl").
-include("sys_daily_reward.hrl").

%% 由genall调用
-export([gen/0]).

gen() ->
    [ok = gen_daily_reward(Tab) || Tab <- ["sys_daily_reward"]],
    ok.

%%-------------
%% internal API
%%-------------

%% 生成exp文件
gen_daily_reward(Tab) ->
    case ?DB_CENT:fetch(lists:concat(["select * from ", Tab])) of
        {error, _Reason} ->
            ?ERROR(?_U("获取表:~p错误:~p"), [Tab, _Reason]),
            {error, _Reason};
        {selected, _Fields, Rows} ->
            gen_daily_reward(Tab, Rows)
    end.

gen_daily_reward(Tab, L) ->
    ExpStr = [gen_daily_reward_row(Tab, R) ++ ".\n" || R <- L],
    File = game_path:data_file(Tab),
    ok = file:write_file(File, ExpStr).

%% 生成一行数据对应的record
gen_daily_reward_row(_Tab, [Id, Reward]) ->
    Record = #sys_daily_reward{
        id = Id,
        reward = Reward
    },
    genbase:term_string(Record).
