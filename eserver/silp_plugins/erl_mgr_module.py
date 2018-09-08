# -*- coding: utf8 -*-

import os
import sys
import traceback
import json

import silp

path = os.path.dirname(__file__)
if not path in sys.path:
    sys.path.insert(0, path)
    silp.info('Insert %s to sys.path' % path)

import utils

def default_impl(mod, *skips):
    lines = []
    if not 'start' in skips:
        lines.append('%% @doc 启动服务')
        lines.append('start_link() ->')
        lines.append('    ?DEBUG(?_U("启动 %s_mgr 服务"),[]),' % mod)
        lines.append('    gen_server:start_link(?SERVER, ?MODULE, [], []).')
        lines.append('')

    if not 'init' in skips:
        lines.append('%% @doc Init')
        lines.append('init(_Type) ->')
        lines.append('    ?DEBUG(?_U("初始化 %s_mgr 服务"), []),' % mod)
        lines.append('    erlang:process_flag(trap_exit, true),')
        lines.append('    erlang:process_flag(priority, high),')
        lines.append('    do_init().')
        lines.append('')

    if not 'terminate' in skips:
        lines.append('%% @doc 结束')
        lines.append('terminate(_Reason, _State) ->')
        lines.append('    ?DEBUG(?_U("停止 %s_mgr 服务:~p"), [_Reason]),' % mod)
        lines.append('    do_sync(),')
        lines.append('    ok.')
        lines.append('')

    if not 'code_change' in skips:
        lines.append('code_change(_Old, State, _Extra) ->')
        lines.append('    {ok, State}.')
        lines.append('')

    if not 'i' in skips:
        lines.append('%% @doc 运行信息')
        lines.append('i() ->')
        lines.append('    [].')
        lines.append('')

    if not 'p' in skips:
        lines.append('%% @doc 运行信息字符')
        lines.append('p(_Info) ->')
        lines.append('    "".')
        lines.append('')

    if not 'handle_info' in skips:
        lines.append('handle_info(_Info, State) ->')
        lines.append('    ?INFO(?_U("%s_mgr 收到消息: ~p"), [_Info]),' % mod)
        lines.append('    {noreply, State}.')
        lines.append('')

    if not 'handle_call' in skips:
        lines.append('handle_call({Action, Arg}, _From, State) ->')
        lines.append('    Reply =')
        lines.append('        case catch ?MODULE:Action(Arg) of')
        lines.append('            {error, Code} ->')
        lines.append('                {error, Code};')
        lines.append('            {\'EXIT\', {undef, Reason}} ->')
        lines.append('                ?ERROR(?_U("%s_mgr:handle_call 不存在的Action: ~p, 参数: ~p, 系统原因: ~p "),' % mod)
        lines.append('                    [Action, Arg, Reason]),')
        lines.append('                {error, ?E_SYSTEM};')
        lines.append('            {\'EXIT\', Reason} ->')
        lines.append('                ?ERROR(?_U("%s_mgr:handle_call Action: ~p, 参数: ~p, 发生严重错误: ~p"),' % mod)
        lines.append('                    [Action, Arg, Reason]),')
        lines.append('                {error, ?E_SYSTEM};')
        lines.append('            Result ->')
        lines.append('                ?DEBUG(?_U("%s_mgr:handle_call Action: ~p, 参数: ~p, 结果:~p"),' % mod)
        lines.append('                    [Action, Arg, Result]),')
        lines.append('                Result')
        lines.append('        end,')
        lines.append('    {reply, Reply, State};')
        lines.append('')
        lines.append('handle_call(_Msg, _From, State) ->')
        lines.append('    {noreply, State}.')
        lines.append('')

    if not 'handle_cast' in skips:
        lines.append('handle_cast({Action, Arg}, State) ->')
        lines.append('    case catch (?MODULE:Action(Arg)) of')
        lines.append('        {error, _Code} ->')
        lines.append('            ?ERROR(?_U("%s_mgr:handle_cast -> Action: ~p, 参数: ~p, Code: ~p"),' % mod)
        lines.append('                [Action, Arg, _Code]);')
        lines.append('        {_Cls, _Reason} ->')
        lines.append('            ?ERROR(?_U("%s_mgr:handle_cast -> Action: ~p, 参数: ~p, Cls: ~p, Error: ~p"),' % mod)
        lines.append('                [Action, Arg, _Cls, _Reason]);')
        lines.append('        _Result ->')
        lines.append('            ?DEBUG(?_U("%s_mgr:handle_cast Action: ~p, 参数: ~p, 结果:~p"),' % mod)
        lines.append('                [Action, Arg, _Result]),')
        lines.append('            ok')
        lines.append('    end,')
        lines.append('    {noreply, State};')
        lines.append('')
        lines.append('handle_cast(_Msg, State) ->')
        lines.append('    {noreply, State}.')
        lines.append('')

    if not 'do' in skips:
        lines.append('%% @doc 对外接口 同步')
        lines.append('do(Action, Arg) ->')
        lines.append('    case catch gen_server:call(?SERVER, {Action, Arg}, ?GEN_TIMEOUT) of')
        lines.append('        {error, Code} ->')
        lines.append('            ?C2SERR(Code);')
        lines.append('        {timeout, _} ->')
        lines.append('            ?ERROR("%s_mgr:do 操作超时: Action: ~p Arg: ~p", [Action, Arg]),')
        lines.append('            ?C2SERR(?E_TIMEOUT);')
        lines.append('        Result ->')
        lines.append('            Result')
        lines.append('    end.')
        lines.append('')
    if not 'async_do' in skips:
        lines.append('%% @doc 对外接口 异步')
        lines.append('async_do(Action, Arg) ->')
        lines.append('    ok = gen_server:cast(?SERVER, {Action, Arg}).')
        lines.append('')

    return lines

def _append_common_exports(lines, table, schema):
    lines.append('-export([do/2, async_do/2]).')
    lines.append('')

def _append_common_defines(lines, table, schema):
    lines.append('-define(SERVER, {global, ?MODULE}).')
    lines.append('')

def _append_ets_defines(lines, table, schema):
    lines.append('%% 表名称定义')
    lines.append("-define(TABLE_MGR_%s, 'mgr_%s'). " % (table.upper(), table))
    lines.append('')

def _append_ets_internals(lines, table, key, schema):
    lines.append('%%---------------')
    lines.append('%% internal API')
    lines.append('%%---------------')
    lines.append('%% @doc mgr_%s 缓存表的初始化' % table)
    lines.append('create_table() ->')
    lines.append('    ?TABLE_MGR_%s =' % (table.upper()))
    lines.append('        ets:new(?TABLE_MGR_%s, [' % (table.upper()))
    lines.append('            set, public, named_table,')
    lines.append('            {keypos, #%s.%s}, ' % (table, key))
    lines.append('            ?ETS_CONCURRENCY')
    lines.append('        ]),')
    lines.append('    ok.')
    lines.append('')
    lines.append('%% @doc 获取某个记录')
    lines.append('lookup(%s) ->' % key.title())
    lines.append('    case ets:lookup(?TABLE_MGR_%s, %s) of' % (table.upper(), key.title()))
    lines.append('        [] ->')
    lines.append('            ?ERROR(?_U("%s: ~p 不存在"), [%s]),' % (table, key.title()))
    lines.append('            ?C2SERR(0);')
    lines.append('        [E] ->')
    lines.append('            E')
    lines.append('    end.')
    lines.append('')
    lines.append('%% @doc Insert 记录')
    lines.append('insert(%s) ->' % table.title())
    lines.append('    true = ets:insert(?TABLE_MGR_%s, %s),' % (table.upper(), table.title()))
    lines.append('    %s.' % table.title())
    lines.append('')
    lines.append('%% @doc 获取所有记录')
    lines.append('list_all() ->')
    lines.append('    [Mgr_%s ||' % (table.title()))
    lines.append('      #%s{} =' % (table))
    lines.append('        Mgr_%s <- ets:tab2list(?TABLE_MGR_%s)].' % (table.title(), table.upper()))
    lines.append('')


def ets_external(table, key):
    schema = utils.load_schema(table)
    if schema is None: return None

    lines = []
    _append_common_exports(lines, table, schema)
    _append_common_defines(lines, table, schema)
    _append_ets_defines(lines, table, schema)
    return lines

def ets_internal(table, key):
    schema = utils.load_schema(table)
    if schema is None: return None

    lines = []
    _append_ets_internals(lines, table, key, schema)
    return lines

def ets_no_extras(*args):
    lines = []
    lines.append('do_init() ->')
    lines.append('    create_table(),')
    lines.append('    {ok, normal}.')
    lines.append('')
    lines.append('do_sync() ->')
    lines.append('    ok.')
    lines.append('')
    return lines

    lines.append('%% @doc 插入记录, ')
    lines.append('insert(%s) ->' % table.title())
    lines.append('    ets:insert(?TABLE_MGR_%s, %s).' % (table.upper(), table.title()))
    lines.append('')
    lines.append('%% @doc 更新记录, ')
    lines.append('update(%s) ->' % table.title())
    lines.append('    ets:insert(?TABLE_MGR_%s, %s).' % (table.upper(), table.title()))
    lines.append('')
    lines.append('%% @doc 获取所有记录')
