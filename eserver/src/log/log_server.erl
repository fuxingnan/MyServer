%%%----------------------------------------------------------------------
%%%
%%% @author kebo
%%% @date  2012.04.18
%%% @doc log 服务
%%% @end
%%%
%%%----------------------------------------------------------------------
-module(log_server).
-author("huang.kebo@gmail.com").
-vsn('1.0').
-behaviour(gen_server).
-include("wg.hrl").
-include("common.hrl").

-export([start_link/2]).
-export([i/1, write/2, write/3, write_iodata/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
                            terminate/2, code_change/3]).

%% 定义结构
-record(state, {
        file,       % 日日文件
        fd          % 当前文件句柄
    }).

%% 宏定义
-define(DATETIME, erlang:localtime()).

%% @doc 启动
start_link(Name, LogFile) ->
    gen_server:start_link({global, Name}, ?MODULE, LogFile, []).

%% @doc 信息
i(Server) ->
    #state{} = State = call(Server, get_state),
    [{file, State#state.file}].

%% @doc 写入日志
write(Server, Data) when is_list(Data) ->
    write(Server, Data, "|").

%% @doc 写入日志
%% sep为分隔符
write(Server, Data, Sep) when is_list(Data) ->
    cast(Server, {write, [do_join(Data, Sep), "\n"]}).

%% @doc 写入日志
write_iodata(Server, Data) ->
    cast(Server, {write, Data}).

%%----------------------
%% gen_server callbacks
%%----------------------
init(LogFile) ->    
    erlang:process_flag(trap_exit, true),
    erlang:process_flag(priority, high),
    LogFileBin = 
    if 
        is_list(LogFile) ->
            erlang:list_to_binary(LogFile);
        is_binary(LogFile) ->
            LogFile
    end,
    case catch open_log_file(LogFileBin) of
        {ok, FdNew} ->
            {ok, #state{fd = FdNew, file = LogFileBin}};
        {error, Reason} ->
            {stop, Reason}
    end.

handle_call(get_state, _From, State) ->
    {reply, State, State};
handle_call(_Msg, _From, State) ->
    {noreply, State}.

handle_cast({write, Data}, State) ->
    case catch do_write(Data, State) of
        {ok, State2} ->
            {noreply, State2};
        {error, Reason} ->
            ?DEBUG(?_U("写入日志报错:~p"), [Reason]),
            {stop, Reason, State}
    end;
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{fd = Fd}) ->
    ?DEBUG(?_U("进程停止:~p"), [_Reason]),
    ?IF(Fd =/= undefined, file:close(Fd), ok),
    ok.

code_change(_Old, State, _Extra) ->
    {ok, State}.
    
%%--------------
%% internal API
%%--------------

%% 调用
call(Server, Req) ->
    gen_server:call(Server, Req).

%% 异步通知
cast(Server, Req) when is_pid(Server) ->
    gen_server:cast(Server, Req);
cast(Server, Req) when is_atom(Server) ->
    gen_server:cast({global, Server}, Req).

%% 打开日志文件
open_log_file(LogFile) ->
    ok = filelib:ensure_dir(LogFile),
    case file:open(LogFile, [raw, write, append, {delayed_write, 65536, 2000}]) of
        {ok, Fd} ->
            {ok, Fd};
        {error, Reason} ->
            ?ERROR(?_U("打开log文件:~s出错:~p"), [LogFile, Reason]),
            throw({error, Reason})
    end.

%% 检测文件是否存在
check_state(#state{file = LogFile, fd = Fd} = State) ->
    case wg_util:is_regular(LogFile) of
        true ->
            State;
        false ->
            catch file:close(Fd),
            {ok, FdNew} = open_log_file(LogFile),
            State#state{fd = FdNew}
    end.

%% 写入文件
do_write(Data, State) ->
    #state{fd = Fd} = State2 = check_state(State),
    case file:write(Fd, Data) of
        ok ->
            {ok, State2};
        {error, enospc} ->
            ?ERROR(?_U("写入log文件出错:磁盘空间不足"), []),
            {error, enospc};
        {error, Reason} ->
            ?ERROR(?_U("写入log文件出错:~p"), [Reason]),
            {error, Reason}
    end.

%% 字符串的join
do_join([], Sep) when is_list(Sep) ->
    []; 
do_join([H|T], Sep) ->
    [H | [[Sep, X] || X <- T]].


%%------------
%% EUNIT test
%%------------
-ifdef(EUNIT).

-endif.
