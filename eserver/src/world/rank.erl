
-module(rank).
-author("fuxing").
-vsn('0.1').
-include("wg.hrl").
-include("game.hrl").
-include("room.hrl").

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1]).


%

%% 创建添加更新

-export([get_win_rank/1,get_money_rank/1,get_lose_rank/1,get_all_rank/0]).


%% 删除

%% gen_server相关函数

-export([call/1, handle_call/3, handle_cast/2, handle_info/2,
  terminate/2, code_change/3]).


%% 状态,用于队伍id，从1开始

-record(state, {
        id_new = 1
    }).


%% 服务名字

-define(START_NAME, {global, ?MODULE}).
-define(NAME, ?MODULE).


%% 表名称


-define(RANK_LIST, 'rank_list').
%% @doc 启动

start_link()->
    ?DEBUG(?_U("启动排行榜管理器服务"),[]),
    gen_server:start_link(?START_NAME, ?MODULE, [], []).


%%初始化

init(_Type) ->
    erlang:process_flag(trap_exit, true),
    erlang:process_flag(priority, high),
    create_table(),
    register(?NAME, self()),
    {ok, #state{}}.

create_table() ->
   
  ?RANK_LIST = ets:new(?RANK_LIST, [set, public, named_table,
    {keypos, #rank_list.id},
    ?ETS_CONCURRENCY
  ]),
    ok.
get_all_rank()->
  call({get_all_rank}).

get_win_rank(Rank_Data) ->
  call({get_win_rank, Rank_Data}).

get_money_rank(RankMoneyData) ->
  call({get_money_rank, RankMoneyData}).

get_lose_rank(LoseRankData) ->
  call({get_lose_rank, LoseRankData}).


handle_call({get_all_rank}, _From, #state{id_new = IdNew} = State) ->
  case ets:lookup(?RANK_LIST, 1) of
    [] ->
      Res = {[],[],[]},
      Res;

    [#rank_list{member = MoneyRankList,member_win = WinRankList,member_lost = Lose_rank_List} = Rank_money_list] ->
      NewMoneyRankList = [X||#money_rank_data{money = OtherMoney} = X <-MoneyRankList,OtherMoney > 0],

      NewWinRankList = [X||#win_rank_data{money = OtherMoney} = X <-WinRankList,OtherMoney > 0],

      NewLose_rank_List = [X||#lose_rank_data{money = OtherMoney} = X <-Lose_rank_List,OtherMoney > 0],

      Res = {NewMoneyRankList,NewWinRankList,NewLose_rank_List}
  end,
  {reply, Res, State};


handle_call({get_lose_rank, LoseRankData}, _From, #state{id_new = IdNew} = State) ->
  case ets:lookup(?RANK_LIST, 1) of
    [] ->
      MoneyRankList = #rank_list
      {
        id = 1,
        member_lost = [LoseRankData]
      },
      true = ets:insert(?RANK_LIST, MoneyRankList),
      #lose_rank_data{money = OtherMoney} = LoseRankData,
      ?IF(OtherMoney > 0, LoseRank = 1 ,LoseRank = -1),
      LoseRank;

    [#rank_list{member_lost = Member_Money_List} = Rank_money_list] ->
      #lose_rank_data{money = LoseMoney} = LoseRankData,
      New_Money_Rank_List = do_add_lose_money_rank(Member_Money_List,LoseRankData),
      NewMoneyRankList = Rank_money_list#rank_list{member_lost = New_Money_Rank_List},
      true = ets:insert(?RANK_LIST, NewMoneyRankList),
      LoseRank = do_get_lose_rank(New_Money_Rank_List,LoseMoney),
      LoseRank

  end,
  {reply, LoseRank, State};

handle_call({get_money_rank, RankMoneyData}, _From, #state{id_new = IdNew} = State) ->
  case ets:lookup(?RANK_LIST, 1) of
    [] ->
      MoneyRankList = #rank_list
      {
        id = 1,
        member= [RankMoneyData]
      },
      true = ets:insert(?RANK_LIST, MoneyRankList),
      #money_rank_data{money = OtherMoney} = RankMoneyData,

      ?IF(OtherMoney > 0, MyMoneyRank = 1 ,MyMoneyRank = -1),
      MyMoneyRank;

    [#rank_list{member = Member_Money_List} = Rank_money_list] ->
      #money_rank_data{money = TatalMoney} = RankMoneyData,
      New_Money_Rank_List = do_add_money_rank(Member_Money_List,RankMoneyData),
      NewMoneyRankList = Rank_money_list#rank_list{member = New_Money_Rank_List},
      true = ets:insert(?RANK_LIST, NewMoneyRankList),
      MyMoneyRank = do_get_money_rank(New_Money_Rank_List,TatalMoney),
      MyMoneyRank

  end,
  {reply, MyMoneyRank, State};
handle_call({get_win_rank, Rank_Data}, _From, #state{id_new = IdNew} = State) ->
  case ets:lookup(?RANK_LIST, 1) of
    [] ->
      MoneyRankList = #rank_list
      {
        id = 1,
        member_win = [Rank_Data]
      },
      true = ets:insert(?RANK_LIST, MoneyRankList),

      #win_rank_data{money = OtherMoney} = Rank_Data,

      ?IF(OtherMoney > 0, MyWinRank = 1 ,MyWinRank = -1),
      MyWinRank;

    [#rank_list{member_win = Member_Win_List} = Rank_money_list] ->
      #win_rank_data{money = MyFirstMoney} = Rank_Data,
      New_Win_Rank_List = do_add_win_money_rank(Member_Win_List,Rank_Data),
      NewMoneyRankList = Rank_money_list#rank_list{member_win = New_Win_Rank_List},
      true = ets:insert(?RANK_LIST, NewMoneyRankList),
      MyWinRank = do_get_win_money_rank(New_Win_Rank_List,MyFirstMoney),
      MyWinRank

  end,
{reply, MyWinRank, State}.



handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ?DEBUG(?_U("进程停止:~p"), [_Reason]),
  ok.

code_change(_Old, State, _Extra) ->
  {ok, State}.

call(Req) ->
  case gen_server:call(game_misc:whereis_name(?NAME), Req, ?GEN_TIMEOUT) of
    {error, Code} ->
      ?C2SERR(Code);
    Reply ->
      Reply
  end.


do_sort_money_rank(L) ->
  lists:sort(fun(M1, M2) -> M1#money_rank_data.money =< M2#money_rank_data.money end, L).
do_sort_max_win_rank(L) ->
  lists:sort(fun(M1, M2) -> M1#win_rank_data.money =< M2#win_rank_data.money end, L).
do_sort_max_lose_rank(L) ->
  lists:sort(fun(M1, M2) -> M1#lose_rank_data.money =< M2#lose_rank_data.money end, L).
%%更新房主id

do_get_win_money_rank(WinRankList,Money)->
  NewList = [X||#win_rank_data{money = OtherMoney} = X <-WinRankList,OtherMoney > Money],
  ?IF(Money > 0, Rank = length(NewList)+1 ,Rank = -1),
  Rank.
do_get_money_rank(MoneyRankList,Money)->
  NewList = [X||#money_rank_data{money = OtherMoney} = X <-MoneyRankList,OtherMoney > Money],
  ?IF(Money > 0, Rank = length(NewList)+1 ,Rank = -1),
  Rank.
do_get_lose_rank(LoseRankList,Money)->

  NewList = [X||#lose_rank_data{money = OtherMoney} = X <-LoseRankList,OtherMoney > Money],
  ?IF(Money > 0, Rank = length(NewList)+1 ,Rank = -1),
  Rank.



do_add_money_rank(RankList,Member) ->
  %?DEBUG(?_U("旧金钱排行榜:~p"), [RankList]),
  #money_rank_data{id = MemberId} = Member,
%%  case lists:keyreplace(MemberId,#money_rank_data.id,RankList,Member) of
%%    RankList ->
%%      ?DEBUG(?_U("玩家在不再金钱总排行榜中:~p"), [RankList]),
%%      RankList3 = [Member | RankList];
%%    New_Rank_List->
%%      ?DEBUG(?_U("玩家在金钱总排行榜中:~p"), [New_Rank_List]),
%%      RankList3 = New_Rank_List
%%  end,


  case lists:keyfind(MemberId, #money_rank_data.id, RankList) of
    false ->
      %?DEBUG(?_U("玩家在不再金钱总排行榜中:~p"), [Member]),
      RankList3 = [Member | RankList];
    _ ->
      %?DEBUG(?_U("玩家在金钱总排行榜中:~p"), [RankList]),
      RankList3 = lists:keyreplace(MemberId,#money_rank_data.id,RankList,Member)
  end,


  RankList2 = do_sort_money_rank(RankList3),
  case length(RankList2) > ?Rank_list_max of
    true ->
      [H|NewRank] = RankList2;
    false ->
      NewRank = RankList2
  end,

  %?DEBUG(?_U("新的金钱排行榜:~p"), [NewRank]),
  NewRank.

do_add_win_money_rank(RankList,Member) ->
  %?DEBUG(?_U("旧一次金钱排行榜:~p"), [RankList]),
  #win_rank_data{id = MemberId} = Member,
  %?DEBUG(?_U("id:~p"), [MemberId]),
%%  case lists:keyreplace(MemberId,#win_rank_data.id,RankList,Member) of
%%    RankList ->
%%    ?DEBUG(?_U("玩家在不再一次排行榜中:~p"), [RankList]),
%%      RankList3 = [Member | RankList];
%%    New_Rank_List->
%%      ?DEBUG(?_U("玩家在一次排行榜中:~p"), [RankList]),
%%      RankList3 = New_Rank_List
%%  end,

  case lists:keyfind(MemberId, #win_rank_data.id, RankList) of
    false ->
      %?DEBUG(?_U("添加加一次赢排行榜中:~p"), [Member]),
      RankList3 = [Member | RankList];
    _ ->
      %?DEBUG(?_U("修改一次赢排行榜中:~p"), [RankList]),
      RankList3 = lists:keyreplace(MemberId,#win_rank_data.id,RankList,Member)
  end,



  RankList2 = do_sort_max_win_rank(RankList3),
  case length(RankList2) > ?Rank_list_max of
    true ->
      [H|NewRank] = RankList2;
    false ->
      NewRank = RankList2
  end,

  %?DEBUG(?_U("新的一次金钱排行榜:~p"), [NewRank]),
  NewRank.

do_add_lose_money_rank(RankList,Member) ->
  %?DEBUG(?_U("旧输一次金钱排行榜:~p"), [RankList]),

  #lose_rank_data{id = MemberId} = Member,

  case lists:keyfind(MemberId, #lose_rank_data.id, RankList) of
    false ->
      %?DEBUG(?_U("添加一次输排行榜中:~p"), [Member]),
      RankList3 = [Member | RankList];
    _ ->
      %?DEBUG(?_U("修改一次输排行榜中:~p"), [RankList]),
      RankList3 = lists:keyreplace(MemberId,#lose_rank_data.id,RankList,Member)
  end,

%%  ?DEBUG(?_U("id:~p"), [MemberId]),
%%  case lists:keyreplace(MemberId,#lose_rank_data.id,RankList,Member) of
%%    RankList ->
%%      ?DEBUG(?_U("玩家在不再一次输排行榜中:~p"), [Member]),
%%      RankList3 = [Member | RankList];
%%    New_Rank_List->
%%      ?DEBUG(?_U("玩家在一次输排行榜中:~p"), [RankList]),
%%      RankList3 = New_Rank_List
%%  end,


  RankList2 = do_sort_max_lose_rank(RankList3),
  case length(RankList2) > ?Rank_list_max of
    true ->
      [H|NewRank] = RankList2;
    false ->
      NewRank = RankList2
  end,

  %?DEBUG(?_U("新的输一次金钱排行榜:~p"), [NewRank]),
  NewRank.
