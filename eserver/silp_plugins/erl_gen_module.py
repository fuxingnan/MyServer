# -*- coding: utf8 -*-

import os
import traceback
import json

import silp

import utils
import sys_utils

import erl_db_accessor

def _append_common_export(lines, table, schema):
    lines.append('%% 由genall调用')
    lines.append('-export([gen/0]).')

def _append_common_functions(lines, table, schema):
    lines.append('gen() ->')
    lines.append('    Sql = "select "')
    def get_line(field, is_last):
        name = utils.get(field, 'name')
        if not is_last:
            return '          " `%s`,"' % name
        else:
            return '          " `%s`"' % name
    utils.append_fields_single(lines, table, schema, get_line)
    lines.append('          " from sys_%s",' % table)
    lines.append('    genbase:gen_data_file("sys_%s", Sql, fun row_to_record/1),' % table)
    lines.append('    ok.')
    lines.append('')

def _append_common_internals(lines, table, schema):
    lines.append('%%---------------')
    lines.append('%% internal API')
    lines.append('%%---------------')
    lines.append('')
    erl_db_accessor._append_table_defines(lines, 'sys_' + table, schema)
    lines.append('')
    erl_db_accessor._append_fields_to_record(lines, 'sys_' + table, False, schema)
    lines.append('')
    lines.append('row_to_record(Row) when is_list(Row) ->')
    lines.append('    Record = fields_to_record(Row),')
    lines.append('    process_record(Record).')
    lines.append('')

def _append_simple_internals(lines, table, schema):
    lines.append('process_record(Record) ->')
    lines.append('    Record.')

def erl_gen_custom(table):
    schema, _ = sys_utils.load_sys_schema(table)
    if schema is None: return None

    lines = []
    _append_common_export(lines, table, schema)
    _append_common_functions(lines, table, schema)
    _append_common_internals(lines, table, schema)
    return lines

def erl_gen_simple(table):
    schema, _ = sys_utils.load_sys_schema(table)
    if schema is None: return None

    lines = erl_gen_custom(table)
    _append_simple_internals(lines, table, schema)
    return lines

