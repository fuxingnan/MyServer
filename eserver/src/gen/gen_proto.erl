%% coding: latin-1
%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2015.06.13
%%% @doc 协议的自动生成
%%%
%%%----------------------------------------------------------------------
-module(gen_proto).
-include_lib("xmerl/include/xmerl.hrl").
-include("wg.hrl").
-export([gen/0]).

%% 协议文件
-define(PROTO_FILE, "src/proto/protocol.xml").

-define(P(D), io:format(D++"\n")).
-define(PNL(D), io:format(D)).
-define(P(F, D), io:format(F++"\n", D)).
-define(PNL(F, D), io:format(F, D)).

-define(U2B(Text), (unicode:characters_to_binary(Text))).
-define(LF, "\n").
-define(TAB, "    ").
-define(PATH, "src/proto").
-define(PATH_INCLUDE, "include").

-define(DECODE_MATCH_KEY, {'$decode', match}).
-define(DECODE_ASSIGN_KEY, {'$decode', assign}).
-define(ENCODE_FIELD_KEY, {'$encode', field}).
-define(C2S_LOOP_KEY, {'$decode', loop}).

gen() ->
    % 解析xml
    FilePath = filename:absname(?PROTO_FILE),
    case file:read_file(FilePath) of
        {error, _Reason} ->
            ?P("read file ~p error:~p", [FilePath, _Reason]),
            ?EXIT(1);
        {ok, Xml} ->
            % 去除xml中多余的空格和换行
            Xml2 = 
            re:replace(Xml, "(\>)[\n|\t|\s]+(\<)", "\\1\\2", [global, bsr_unicode, unicode]),
            XmlStr = binary_to_list(iolist_to_binary(Xml2)),
            %?P("xml is~n~s", [XmlStr]),
            case xmerl_scan:string(XmlStr, [{space, normalize}]) of
                {error, _Reason} ->
                    ?P("scan protocol file ~p error:~p", [FilePath, _Reason]),
                    ?EXIT(1);
                {_Element, [_|_] = Rest} ->
                    ?P("scan protocol file found the remain:~p", [Rest]),
                    ?EXIT(2);
                {Element, []} ->
                    %?P("scan protocol file ok!"),
                    Stripped = strip_dom(Element),
                    case catch parse_protocol(Stripped) of
                        {'EXIT', _Error} ->
                            ?P("parse protocol error:~p", [_Error]),
                            ?EXIT(1);
                        _ ->
                            ?EXIT(0)
                    end
            end
    end.

%% 分析协议
parse_protocol(#xmlElement{name = protocol, attributes = Attrs, content = Content}) ->
    Vsn = get_attr(version, Attrs),
    % 生成协议版本信息
    ok = gen_proto_vsn(Vsn),

    % 处理section
    lists:foreach(
    fun
        (#xmlElement{name = section} = Elem) ->
            gen_section(Elem);
        (#xmlElement{name = error} = Elem) ->
            gen_errno(Elem);
        (_) ->
            ok
    end,
    Content),

    % 生成proto_convert.erl文件
    gen_proto_convert(Content).

%% 生成协议版本头文件
gen_proto_vsn(Vsn) ->
    Body = 
    io_lib:format(
    "-define(PROTO_VSN, ~s)."?LF,
    [Vsn]),
    HrlName = "proto_vsn" ++ ".hrl",
    genbase:hrl(?PATH_INCLUDE, HrlName, "协议版本", Body).

%% 生成proto_convert.erl
gen_proto_convert(Content) ->
    Body =
    lists:map(
    fun
        (#xmlElement{name = section, attributes = Attrs, content = Msg}) ->
            Id = get_attr(id, Attrs),
            Name = get_attr(name, Attrs),
            proto_convert_section(Id, Name, Msg);
        (_) ->
            ""
    end,
    Content),

    ModName = "proto_convert.erl",
    ModAttr = [{include, "\"wg.hrl\""},
            {include, "\"../src/proto/proto.hrl\""},
            {export, "[id_mf_convert/1]"}],
    ModBody = lists:append(Body) ++ convert_section_last_clause() ++ ?LF,

    genbase:module(?PATH, ModName, "协议id转换", ModAttr, ModBody).

%% 解析每个section
proto_convert_section(Id, Name, Content) ->
    Section = string:to_lower(Name),

    % id_mf_convert(10) -> proto_acc;
    % id_mf_convert(proto_acc) -> 10;
    Start = 
    io_lib:format(
    ?LF
    "id_mf_convert(~s) -> proto_~s;"?LF
    "id_mf_convert(mod_~s) -> ~s;"
    ?LF,
    [Id, Section, Section, Id]),
    Msgs =
    lists:map(
    fun
        (#xmlElement{name = msg, attributes = Attrs}) ->
            MsgId = get_attr(id, Attrs),
            MsgName = string:to_lower(get_attr(name, Attrs)),

            % id_mf_convert({10, 0, _}) -> {proto_acc, login}; 
            % id_mf_convert({proto_acc, login}) -> {10, 0, 0};
            io_lib:format(
            "id_mf_convert({~s, ~s, _}) -> {mod_~s, proto_~s, ~s};"?LF
            "id_mf_convert({mod_~s, ~s}) -> {~s, ~s, 0};"?LF,
            [Id, MsgId, Section, Section, MsgName,
                Section, MsgName, Id, MsgId
            ]);
        (_) ->
            ""
    end,
    Content),
    lists:flatten([Start, Msgs]).

convert_section_last_clause() ->
"id_mf_convert({V, _, _} = _Arg) when is_integer(V) ->
    ?ERROR(\"invalid id:~p\", [_Arg]),
     error(invalid_id);
id_mf_convert({Mod, _} = _Arg) when is_atom(Mod) ->
    ?ERROR(\"invalid mf:~p\", [_Arg]),
    error(invalid_mf).
".

%% 分析error,生成 errno.hrl
gen_errno(#xmlElement{name = error,
        content = Content}) ->
    Body =
    lists:map(
    fun
        (#xmlElement{name = code, attributes = Attrs}) ->
            Id = get_attr(id, Attrs),
            Name = get_attr(name, Attrs),
            Desc = ?U2B(get_attr(desc, Attrs)),
            errno_define(Name, Id, Desc)
    end,
    Content),
    %?P("body:~n~p", [Body]),
    HrlName = "errno" ++ ".hrl",
    genbase:hrl(?PATH_INCLUDE, HrlName, "错误码", lists:append(Body)).

% 生成一行：-define(E_OK, 0).           % 成功
errno_define(Name, Id, Desc) ->
    true = length(Name) =< 36,
    Str =
    io_lib:format(
    "-define(~-36s, ~8s).    % ~s"?LF,
    [string:to_upper(Name), Id, Desc]),
    lists:flatten(Str).

%% 根据section对应协议文件
gen_section(#xmlElement{name = section,
        attributes = Attrs,
        content = Content}) ->
    Id = get_attr(id, Attrs),
    Name = get_attr(name, Attrs),
    Desc = ?U2B(get_attr(desc, Attrs)),

    ?P("section:~s(~s) ~s", [Name, Id, Desc]),

    % 将msg和type分开
    {MsgElems, _TypeElems} =
    lists:partition(
    fun
        (#xmlElement{name = msg}) ->
            true;
        (#xmlElement{name = type}) ->
            false
    end, Content),

    % 生成关于type的内容

    
    % 生成关于消息的内容
    {C2S, S2C} = parse_msgs(Name, MsgElems),
    {_C2SRecord, C2SMod} = lists:unzip(C2S),
    {_S2CRecord, S2CMod} = lists:unzip(S2C),

%%     HrlBody = C2SRecord ++ ?LF
%%         ++ S2CRecord ++ ?LF,
    ModBody = C2SMod ++ ?LF
        ++ S2CMod ++ encode_s2c_last_clause() ++ ?LF,
    % 写入头文件(现在不用生成协议头文件了)
    % HrlName = "proto_" ++ Name ++ ".hrl",
    % genbase:hrl(?PATH, HrlName, Desc, HrlBody),

    % 写入模块
    ModName = "proto_" ++ Name,
    ModAttr = [
        {compile, "[export_all]"},
        {include, "\"wg.hrl\""},
        {include, "\"game.hrl\""},
        {include, "\"pbmessage_pb.hrl\""}
    ],
    genbase:module(?PATH, ModName, Desc, ModAttr, ModBody).

%% 解析所有的消息
parse_msgs(Section, Elems) ->
    Msgs =
    lists:map(
    fun
        (#xmlElement{name = msg} = Msg) ->
            parse_msg(Section, Msg)
    end, Elems),
    lists:unzip(Msgs).

%% 分析消息
parse_msg(Section, Elem) ->
    #xmlElement{name = msg,
        attributes = Attrs} = Elem,
    _Id = get_attr(id, Attrs),
    Name = get_attr(name, Attrs),
    _Desc = ?U2B(get_attr(desc, Attrs)),
    clear_context(),
    NameLower = string:to_lower(Name),
    Dir = gc_cg(NameLower),
    DecodeMsg =  gen_msg_decode(Dir, Section, NameLower),
    EncodeMsg =  gen_msg_encode(Dir, Section, NameLower),
    clear_context(),
    {DecodeMsg, EncodeMsg}.


%% 分析消息 返回 {"", Body}
gen_msg_decode(gc, _Section, _Msg) ->
    {"", ""};
gen_msg_decode(cg, _Section, Msg) ->
    Body =
    io_lib:format(
    "~s(Bin) ->"?LF
    ?TAB"{ok, pbmessage_pb:decode_~s(Bin)}."?LF
    ?LF,
    [Msg, Msg]),
    {"", Body}.

gen_msg_encode(cg, _Section, _Msg) ->
    {"", ""};
gen_msg_encode(gc, _Section, Msg) ->
    Body =
        io_lib:format(
            "encode_s2c(#~s{} = Record) ->"?LF
    ?TAB"pbmessage_pb:encode_~s(Record);"?LF
    ?LF,
    [Msg, Msg]),
    {"", Body}.

%% encode_s2c的最后一个子句
encode_s2c_last_clause() ->
    "encode_s2c(_) -> error({?MODULE, unknown_s2c})."
    ?LF.


%%----------
%% xml 操作
%%----------

%% 获取xml节点属性
get_attr(Id, Attrs) ->
    case catch genbase:xml_get_attr(Id, Attrs) of
        false ->
            ?P("attribute :~p undefined! attrs:~p", [Id, Attrs]),
            ?EXIT(1);
        {ok, Value} ->
            Value;
        {error, _} ->
            ?P("get_attr badarg:~p", [Id]),
            ?EXIT(1)
    end.



%% 清除text中的空格,'\n','\t'
strip_dom(#xmlElement{content = Content} = Elem) ->
    Content2 =
    lists:foldr(
    fun(Child, Acc) ->
        case strip_dom(Child) of
            skip ->
                Acc;
            Elem2 ->
                %?P("element is ~p", [Elem]),
                [Elem2 | Acc]
        end
    end, [], Content),
    Elem#xmlElement{content = Content2};
strip_dom(#xmlText{value = Val} = Text) ->
    Stripped = strip_space(Val),
    case Stripped =:= "" of
        true ->
            skip;
        _ ->
            Text#xmlText{value = Stripped}
    end;
strip_dom(#xmlComment{}) ->
    skip;
strip_dom(Elem) ->
    %?P("XML is ~p~n", [Elem]),
    Elem.

strip_space(Text) when is_list(Text) ->
    strip_space_left(strip_space_right(Text)).

-define(SPACES, "\r\n\t\s").
strip_space_left([H|T] = S)  ->
    case lists:member(H, ?SPACES) of
        true ->
            strip_space_left(T);
        false ->
            S
    end;
strip_space_left([]) ->
    [].
            
strip_space_right([H|T]) ->
    case lists:member(H, ?SPACES) of
        true ->
            case strip_space_right(T) of
                [] ->
                    [];
                T2 ->
                    [H|T2]
            end;
        false ->
            [H | strip_space_right(T)]
    end;
strip_space_right([]) ->
    [].

%% 清理本消息所有相关数据
clear_context() ->
    [erase(K) || {{Type, _} = K, _} <- get(), (Type =:= '$decode' orelse Type =:= '$encode')].

%% 判断Name是客户端发送的还是服务器发送
-spec gc_cg(string()) -> atom().
gc_cg(Name) ->
    case string:left(Name, 3) of
        "gc_" ->
            gc;
        "cg_" ->
            cg
    end.
