%% coding: latin-1
%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date 2010-10-31
%%% @doc 用来生成模块（proto和data模块调用）
%%%
%%%----------------------------------------------------------------------
-module(genbase).
-vsn('0.1').
-include("genbase.hrl").
-include("player.hrl").
-include_lib("xmerl/include/xmerl.hrl").

-export([module/4, module/5]).
-export([hrl/3, hrl/4]).
-export([gen_data_file/2, gen_data_file/3]).

-export([xml_get_attr/2]).
-export([term_string/1, json_key/2, json_key/3]).
-export([ convert_to_player_attr_var/1]).

%% @doc 生成代码
%% Name 模块名称(atom)
module(Name, Desc, Attr, Body) ->
    module(".", Name, Desc, Attr, Body).

module(Dir, Name, Desc, Attr, Body) 
    when is_list(Dir), is_list(Name), is_list(Attr) ->
    FileName =
    case filename:extension(Name) of
        ".erl" ->
            Name;
        [] ->
            lists:concat([Name, ".erl"])
    end,
    ModName = filename:basename(FileName, ".erl"),
    Path = filename:join([Dir, FileName]),
    ModDef = module_def(ModName, Desc),
    ModAttr = module_attr(Attr),
    ok = file:write_file(Path, [ModDef, ModAttr, "\n", Body]).

%% @doc 生成头文件
hrl(Name, Desc, Body) ->
    hrl(".", Name, Desc, Body).

hrl(Dir, Name, Desc, Body) 
    when is_list(Name) ->
    FileName =
    case filename:extension(Name) of
        ".hrl" ->
            Name;
        [] ->
            Name ++ ".hrl"
    end,
    Path = filename:join([Dir, FileName]),
    HrlDesc = hrl_desc(Name, Desc),
    {HrlHead, HrlFoot} = hrl_macro(filename:basename(Name, ".hrl")),
    ok = file:write_file(Path, [HrlDesc, HrlHead, Body, HrlFoot]).

%% @doc 生成*.data文件
gen_data_file(Table, Fun) ->
    Sql = lists:concat(["select * from ", Table]),
    gen_data_file(Table, Sql, Fun).
gen_data_file(Table, Sql, Fun) ->
    case ?DB_CENT:fetch(Sql) of
        {error, _Reason} ->
            ?ERROR(?_U("获取表:~p错误:~p"), [Table, _Reason]),
            {error, _Reason};
        {selected, _Fields, Rows} ->
            Str = 
            [begin
                Record = 
                ?IF(erlang:is_function(Fun, 1),
                    Fun(Row),
                    Fun(Table, Row)),
                Str = genbase:term_string(Record),
                Str ++ ".\n"
            end || Row <- Rows],
            File = game_path:data_file(Table),
            ok = file:write_file(File, Str)
    end.

%% @doc xml获取属性
xml_get_attr(Id, #xmlElement{attributes = Attrs}) ->
    case lists:keyfind(Id, #xmlAttribute.name, Attrs) of
        false ->
            false;
        #xmlAttribute{value = Value} ->
            {ok, Value}
    end;
xml_get_attr(Id, Attrs) when is_list(Attrs) ->
    case lists:keyfind(Id, #xmlAttribute.name, Attrs) of
        false ->
            false;
        #xmlAttribute{value = Value} ->
            {ok, Value}
    end;
xml_get_attr(_Id, _) ->
    {error, not_valid_xmlelement}.


%% @doc 每个字段都转化成对应的term
term_string(Field) ->
    io_lib:format("~w", [Field]).

%% @doc 获取json object中对应value
json_key(Key, L) ->
    proplists:get_value(Key, L).
json_key(Key, L, Default) ->
    proplists:get_value(Key, L, Default).

%%--------------
%% internal API
%%--------------

%% 生成模块的头部声明
module_def(Name, Desc) ->
    io_lib:format(
    "%%%----------------------------------------------------------------------\n"
    "%%%\n"
    "%%% @author: auto generate\n"
    % 不显示时间,便于svn管理
    %"%%% @date: ~s\n"
    "%%% @doc: ~s (自动生成，请勿编辑!)\n"
    "%%%\n"
    "%%%----------------------------------------------------------------------\n"
    "-module(~s).\n",
    [Desc, Name]).

%% 将属性转化成字符串
module_attr(Attr) ->
    F =
    fun({Tag, V}) ->
        io_lib:format(
        "-~p(~s).\n",
        [Tag, V])
    end,
    lists:map(F, Attr).

%%-----------
%% 关于头文件
%%-----------

%% 生成头文件描述
hrl_desc(_Name, Desc) ->
    io_lib:format(
    "%%%----------------------------------------------------------------------\n"
    "%%%\n"
    "%%% @author: auto generate\n"
    % 不显示时间,便于svn管理
    %"%%% @date: ~s\n"
    "%%% @doc: ~s (自动生成，请勿编辑！)\n"
    "%%%\n"
    "%%%----------------------------------------------------------------------\n",
    [Desc]).

%% 生成头文件的宏
hrl_macro(Name) ->
    Macro = string:to_upper(Name) ++ "_HRL",
    Head =
    io_lib:format(
    "-ifndef(~s).\n"
    "-define(~s, true).\n",
    [Macro, Macro]),
    Foot =
    io_lib:format(
    "-endif. % ~s",
    [Macro]),
    {Head, Foot}.

%%--------------------------
%% 配置属性到运行时数据转化
%%--------------------------

%% %% @doc 转化到装备属性
%% convert_to_equip_attr(0) ->
%%     0;
%% convert_to_equip_attr(N) when N >= 1, N =< 13 ->
%%     #equip.data + N;
%% convert_to_equip_attr(14) ->
%%     #equip.att_phy_add;
%% convert_to_equip_attr(15) ->
%%     #equip.def_phy;
%% convert_to_equip_attr(16) ->
%%     #equip.att_poi;
%% convert_to_equip_attr(17) ->
%%     #equip.def_poi;
%% convert_to_equip_attr(18) ->
%%     #equip.speed.

%% @doc 属性转化到player_attr_var
%% *NOTE*严重依赖与const.hrl中attr_id_xx与player_attr_var的定义!
convert_to_player_attr_var(1) ->
    #player_attr_var.hp;
convert_to_player_attr_var(N) when N >= 2, N =< 15 ->
    #player_attr_var.hp + N - 1;
convert_to_player_attr_var(16) ->
    #player_attr_var.speed;
convert_to_player_attr_var(N) when N >= 30, N =< 31 ->
    N.
