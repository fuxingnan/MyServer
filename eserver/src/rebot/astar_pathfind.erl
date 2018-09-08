%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2011.04.01
%%% @doc A*寻路(仅机器人和宠物,怪物搜索,追击时使用使用)
%%%     起点为start,终点为goal
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(astar_pathfind).
-include("wg.hrl").
-include("game.hrl").

-compile([export_all]).
-ifndef(NONE).
-define(NONE, none).
-endif.

%% 寻路中用到的node
-record(a_node, {
        xy,             % xy坐标
        g,              % g
        h,              % h
        f               % f
    }).

-record(state, {
        start,          % 起点
        goal,           % 终点
        width,          % 宽度
        height,         % 高度
        passable        % 检测节点是否可用
    }).

%% @doc 根据#sys_map,找出从(X0, Y0)到(X1, Y1)的路径
find({_, _} = Start, {_, _} = Start, _Width, _Height, _Passable) ->
    {ok, []};
find({_, _} = Start, {_, _} = Goal, Width, Height, Passable) 
    when is_function(Passable, 1) ->
    State = #state{
        start = Start,
        goal = Goal,
        width = Width,
        height = Height,
        passable = Passable
    },
    %?DEBUG(?_U("===>寻路从~w到~w"), [Start, Goal]),
    % 起点
    StartNode = new_node(Start, 0, State),
    % 开放列表(待检测节点) 
    Open = openset_add(StartNode, openset_new()),
    % 关闭列表(已检测节点),元素为{x, y}
    Closed = sets:new(),
    CameFrom = dict:store(Start, ?NONE, dict:new()),
    catch do_find(Open, Closed, CameFrom, State).

%%--------------
%% Internal API
%%--------------

%% 执行查找动作
%% 1,开放列表为空?是,返回?NONE
%% 2,查找f评分最低的节点
%% 3,判断是否达到目标?是,返回路径
%% 4,将此节点从开放列表移除,并添加到关闭列表
%% 5,检测此节点的可用邻居节点
%% 6,重复1-5步骤
do_find(Open, Closed, CameFrom, #state{goal = Goal} = State) ->
    % 1
    ?IF(openset_is_empty(Open), throw({?NONE, {State#state.start, Goal}}), ok),
    % 2
    {Lowest, Open2} = openset_take_lowest(Open),
    %?DEBUG(?_U("分数最低的节点:~w"), [Lowest]),
    % 3
    ?IF(Goal =:= Lowest#a_node.xy, 
        throw(reconstruct_path(CameFrom, State)), ok),
    % 4
    Closed2 = sets:add_element(Lowest#a_node.xy, Closed),
    % 5
    {Open3, CameFrom2} = scan_neighbor(Lowest, Open2, Closed2, CameFrom, State),
    %?DEBUG(?_U("开放列表数目:~w 关闭列表数目:~w "), 
    %    [openset_size(Open3), sets:size(Closed2)]),
    % 6
    do_find(Open3, Closed2, CameFrom2, State).

%% 检测邻居节点
scan_neighbor(Parent, Open, Closed, CameFrom, State) ->
    #a_node{xy = ParentXY, g = ParentG} = Parent,
    List = get_neighbor(ParentXY, Closed, State), 
    %?DEBUG(?_U("邻居节点列表:~w"), [List]),

    lists:foldl(
    fun(NodeXY, {OpenAcc, CameFromAcc}) ->
        NodeGTemp = ParentG + dist_between(ParentXY, NodeXY),
        NodeExist = openset_lookup(NodeXY, Open),
        case NodeExist of
            false ->
                Node = new_node(NodeXY, NodeGTemp, State),
                OpenAcc2 = openset_add(Node, OpenAcc),
                CameFromAcc2 = dict:store(NodeXY, ParentXY, CameFromAcc),
                %?DEBUG(?_U("添加到开放列表"), []),
                {OpenAcc2, CameFromAcc2};
            #a_node{} when NodeGTemp > NodeExist#a_node.g ->
                {OpenAcc, CameFromAcc};
            #a_node{} ->
                Node = new_node(NodeXY, NodeGTemp, State),
                OpenAcc2 = openset_update(Node, OpenAcc),
                CameFromAcc2 = dict:store(NodeXY, ParentXY, CameFromAcc),
                %?DEBUG(?_U("更新开放列表中的元素"), []),
                {OpenAcc2, CameFromAcc2}
        end
    end, {Open, CameFrom}, List).

%% 获取邻居列表(可用且没有位于关闭列表)
get_neighbor({X0, Y0}, Closed, State) ->
    #state{width = Width, 
        height = Height,
        passable = FunPassable
    } = State,
    XList = [X0 -1, X0, X0 + 1],
    YList = [Y0 -1, Y0, Y0 + 1],
    [begin
        {X, Y} 
    end || X <- XList, Y <- YList, 
        X >= 0, Y >= 0, X < Width, Y < Height,
        not (X =:= X0 andalso Y =:= Y0),
        FunPassable({X, Y}),
        not sets:is_element({X, Y}, Closed)].

%% 生成新的node
new_node(XY, G, #state{goal = Goal}) ->
    H = heuristic(XY, Goal),
    #a_node{xy = XY, g = G, h = H, f = H + G}.

%% 构造路径
reconstruct_path(CameFrom, #state{start = Start, goal = Goal}) ->
    Path = do_reconstruct_path(CameFrom, Goal, [Goal], Start),
    %?DEBUG(?_U("寻路完成路径:~p~n"), [Path]),
    {ok, Path}.

do_reconstruct_path(_CameFrom, Start, Path, Start) ->
    Path;
do_reconstruct_path(CameFrom, Goal, Path, Start) ->
    From = dict:fetch(Goal, CameFrom),
    do_reconstruct_path(CameFrom, From, [From | Path], Start).

%%----------
%% 开放列表
%%----------

%% 开放列表记录
-record(openset, {
        list = [],
        dict = dict:new()
    }).

%% 新的开放列表
openset_new() ->
    #openset{}.

%% 开放列表大小
openset_size(#openset{dict = Dict}) ->
    dict:size(Dict).

%% 从开放列表中获取f得分最低的节点
openset_take_lowest(#openset{list = [H | T], dict  = Dict} = OpenSet) ->
    #a_node{xy = XY} = H,
    OpenSet2 = OpenSet#openset{list = T, 
        dict = dict:erase(XY, Dict)
    },
    {H, OpenSet2}.

%% 添加到开放列表
openset_add(Node, #openset{list = List, dict = Dict} = OpenSet) ->
    #a_node{xy = XY} = Node,
    OpenSet#openset{
        list = do_sort_by_f_score([Node | List]),
        dict = dict:store(XY, Node, Dict)
    }.

%% 更新开放列表
openset_update(Node, #openset{list = List, dict = Dict} = OpenSet) ->
    #a_node{xy = XY} = Node,
    List2 = lists:keyreplace(XY, #a_node.xy, List, Node),
    OpenSet#openset{
        list = do_sort_by_f_score(List2),
        dict = dict:store(XY, Node, Dict)
    }.

%% 查找某个节点
openset_lookup(XY, #openset{dict = Dict}) ->
    case dict:find(XY, Dict) of
        {ok, Value} ->
            Value;
        error ->
            false
    end.

%% 是否为空
openset_is_empty(#openset{list = List}) ->
    length(List) =:= 0.
 
%% 依据f评分排序
do_sort_by_f_score(List) ->
    F = 
    fun(#a_node{f = F1}, #a_node{f = F2}) ->
            F1 < F2
    end,
    lists:sort(F, List).

%% 曼哈顿距离(计算h)
heuristic({X0, Y0}, {X1, Y1}) ->
    abs(X0 - X1) + abs(Y0 - Y1).

%% 计算两个相邻节点间的距离
dist_between({X0, Y0}, {X1, Y1}) ->
    if 
        X0 =:= X1 orelse Y0 =:= Y1 ->
            10;
        true ->
            14
    end.

%%----------------
%% Eunit Test
%%----------------

-ifdef('0').
%%-ifdef(EUNIT).

%% 测试寻路
path_find_test_() ->
    Passable =
    fun({X, Y}) ->
        map_misc:is_pos_idle(11001, X, Y)
    end,
    ?DEBUG(?_U("地图~p宽度:~w 高度:~w"), [11001, Width, Height]),
    [
    ?_assertMatch({ok, _}, 
        find({65,48}, {65,48}, Width, Height, Passable)),
    ?_assertMatch({ok, _},
        find({65,48}, {65,49}, Width, Height, Passable)),
    ?_assertMatch({ok, _},
        find({65,48}, {65,50}, Width, Height, Passable)),
    ?_assertMatch({ok, _},
        find({65,48}, {65,51}, Width, Height, Passable)),
    ?_assertMatch({ok, _},
        find({65,48}, {58,58}, Width, Height, Passable)),
    ?_assertMatch({?NONE, _},
        find({65,48}, {66, 76}, Width, Height, Passable)),
    ?_assertMatch({?NONE, _},
        find({65,48}, {66, 77}, Width, Height, Passable))
    ].

-endif.
