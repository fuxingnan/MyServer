# -*- coding: utf8 -*-

import os
import traceback
import json

import silp

import utils
import sys_utils

def hrl_record_end(table):
    lines = []
    lines.append('}).')
    lines.append('-type %s() :: #%s{}.' % (table, table))
    return lines

def hrl_record(table, is_partial):
    is_partial = is_partial.strip() == 'true'

    schema = utils.load_schema(table)
    if schema is None: return None

    lines = []
    lines.append('%%%% %s基本信息(修改数据库时，需要修改此record)' % utils.get(schema, 'description', table))
    _hrl_record_with_schema(lines, table, schema, is_partial)
    return lines

def _hrl_record_with_schema(lines, table, schema, is_partial):
    if schema is None: return None

    lines.append('-record(%s, {' % table)

    def get_default(field):
        val = utils.get_default_value(field)
        if val is not None:
            return ' = %s' % utils.get_erlang_value(val)
        return ''

    max_len = 0
    for field in schema['fields']:
        name = utils.get(field, 'name')
        default = get_default(field)
        max_len = max(max_len, len(name) + len(default))

    max_padding = 4 * ((max_len + 1) / 4 + 1) - 1 #the -1 here is for the comma

    def get_line(field, is_last):
        name = utils.get(field, 'name')
        description = utils.get(field, 'description')
        has_comma = is_partial or (not is_last)
        default = get_default(field)
        padding = (max_padding - len(name) - len(default)) * ' '
        return '    %s%s%s%s%%%% %s' % (name, default, has_comma and ',' or ' ', padding, description)
    utils.append_fields_single(lines, table, schema, get_line)

    if is_partial:
        lines.append('    %% 以上是持久化数据，以下是非持久化数据')
    else:
        lines.append('    }).')
        lines.append('-type %s() :: #%s{}.' % (table, table))

    return lines

def hrl_sys_record(table):
    schema, _ = sys_utils.load_sys_schema(table)
    if schema is None: return None

    table = 'sys_' + table
    lines = []
    lines.append('%%%% %s (由 %s 自动生成)' % (table, utils.get(schema, 'description', table)))
    _hrl_record_with_schema(lines, table, schema, False)
    return lines
