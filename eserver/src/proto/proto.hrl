%%%----------------------------------------------------------------------
%%%
%%% @author: kebo
%%% @date: 2012-04-18
%%% @doc 协议处理公用头文件
%%% [2字节长度][1字节消息分类][1字节消息id][消息数据]
%%% 所有数据采用big-endian(网络字节序号)
%%%
%%%----------------------------------------------------------------------
-ifndef(PROTO_HRL).
-define(PROTO_HRL, true).

-include("pbmessage_pb.hrl").
%% 协议中使用的loop的长度(bits)
-define(LOOP_SIZE, 16).

%% 协议中Section的长度(bits)
-define(SECTION_SIZE, 8).

%% 协议中Method的长度(bits)
-define(METHOD_SIZE, 8).

%% 协议中error code的长度(bits)
-define(CODE_SIZE, 16).

%%
%% 协议中MF和id转化
%%
-define(PROTO_CONVERT(MF), (proto_convert:id_mf_convert(MF))).

-endif. % PROTO_HRL
