# -*- coding: utf8 -*-

import os
import traceback
import json

import silp

import utils
import sys_utils

def _append_common_export(lines, table, schema):
    lines.append('-export([init/0, reload/0]).')
    lines.append('-export([get/1, list/0]).')

def _append_common_defines(lines, table, schema):
    lines.append('%% 表名称定义')
    lines.append("-define(TABLE_SYS_%s, 'sys_%s'). " % (table.upper(), table))
    lines.append('')
    lines.append('%% 数据文件')
    lines.append('-define(FILE_SYS_%s, "sys_%s.data").' % (table.upper(), table))
    lines.append('')

def _append_common_functions(lines, table, key, schema):
    lines.append('%% @doc 系统表的初始化')
    lines.append('init() ->')
    lines.append('    ?INFO(?_U("sys_%s 系统表初始化")),' % table)
    lines.append('    ok = create_table(),')
    lines.append('    ok = create_indexes(),')
    lines.append('    ok = load(),')
    lines.append('    ok.')
    lines.append('')
    lines.append('load() ->')
    lines.append('    ?INFO(?_U("加载 sys_%s 系统表")),' % table)
    lines.append('    ok = load_table(),')
    lines.append('    ok = load_indexes(),')
    lines.append('    ok.')
    lines.append('')
    lines.append('%% 重新加载数据')
    lines.append('reload() ->')
    lines.append('    ?INFO(?_U("重新加载 sys_%s 系统表")),' % table)
    lines.append('    load().')
    lines.append('')
    lines.append('%% @doc 获取某个记录, ')
    lines.append('get(%s) ->' % key.title())
    lines.append('    case ets:lookup(?TABLE_SYS_%s, %s) of' % (table.upper(), key.title()))
    lines.append('        [] ->')
    lines.append('            ?ERROR(?_U("%s: ~p 不存在"), [%s]),' % (table, key.title()))
    lines.append('            ?C2SERR(0);')
    lines.append('        [E] ->')
    lines.append('            E')
    lines.append('    end.')
    lines.append('')
    lines.append('%% @doc 获取所有记录')
    lines.append('list() ->')
    lines.append('    [Sys_%s ||' % (table.title()))
    lines.append('      #sys_%s{} =' % (table))
    lines.append('        Sys_%s <- ets:tab2list(?TABLE_SYS_%s)].' % (table.title(), table.upper()))
    lines.append('')

def _append_common_internals(lines, table, key, schema):
    lines.append('%%---------------')
    lines.append('%% internal API')
    lines.append('%%---------------')
    lines.append('')
    lines.append('%% 创建 sys_%s 相关表' % table)
    lines.append('create_table() ->')
    lines.append('    ?TABLE_SYS_%s =' % (table.upper()))
    lines.append('        ets:new(?TABLE_SYS_%s, [' % (table.upper()))
    lines.append('            set, public, named_table,')
    lines.append('            {keypos, #sys_%s.%s}, ' % (table, key))
    lines.append('            ?ETS_CONCURRENCY')
    lines.append('        ]),')
    lines.append('    ok.')
    lines.append('')
    lines.append('%% 加载 sys_%s 数据' % table)
    lines.append('load_table() ->')
    lines.append('    {ok, List} = file:consult(game_path:data_file(?FILE_SYS_%s)),' % table.upper())
    lines.append('    ?INFO(?_U("加载 sys_%s 条数:~b"), [length(List)]),' % table)
    lines.append('    true = ets:insert(?TABLE_SYS_%s, List),' % table.upper())
    lines.append('    ok.')
    lines.append('')

def _append_no_extra_indexes(lines, table, schema):
    lines.append('%% 创建 sys_%s 相关索引表' % table)
    lines.append('create_indexes() ->')
    lines.append('    ok.')
    lines.append('')
    lines.append('%% 加载 sys_%s 索引数据' % table)
    lines.append('load_indexes() ->')
    lines.append('    ok.')

def erl_sys_custom(table, key):
    schema, _ = sys_utils.load_sys_schema(table)
    if schema is None: return None

    lines = []
    _append_common_export(lines, table, schema)
    _append_common_defines(lines, table, schema)
    _append_common_functions(lines, table, key, schema)
    _append_common_internals(lines, table, key, schema)
    return lines

def erl_sys_simple(table, key):
    schema, _ = sys_utils.load_sys_schema(table)
    if schema is None: return None

    lines = erl_sys_custom(table, key)
    _append_no_extra_indexes(lines, table, schema)
    return lines
