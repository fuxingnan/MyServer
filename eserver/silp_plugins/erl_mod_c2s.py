# -*- coding: utf8 -*-

import os
import traceback
import json

import silp

import utils

def _append_records_to_lists(lines, table, schema):
    lines.append('%%%% @doc 转换 Records -> Lists of Fields #%s' % table)
    lines.append('%s_records_to_field_lists([], Lists) ->' % table)
    lines.append('    lists:map(fun(List) -> lists:reverse(List) end, Lists);')
    lines.append('%s_records_to_field_lists([Record | Tail], Lists) ->' % table)
    lines.append('    Vals = db_%s:record_to_fields(Record),' % table)
    lines.append('    %s_records_to_field_lists(Tail,' % table)
    lines.append('        lists:zipwith(fun(Val, List) -> [Val | List] end, Vals, Lists)).')
    lines.append('')
    lines.append('%s_records_to_field_lists(Records) ->' % table)
    lines.append('    Lists = [')
    utils.append_fields_multi(lines, table, schema, '    ', lambda field: '[]', 3)
    lines.append('    ],')
    lines.append('    %s_records_to_field_lists(Records, Lists).' % table)
    lines.append('')

def erl_mod_c2s_helpers(table):
    schema = utils.load_schema(table)
    if schema is None: return None
    lines = []
    _append_records_to_lists(lines, table, schema)
    return lines

def _append_records_to_lists_match(lines, table, schema, records):
    lines.append('[')
    max_padding = schema['fields_max_name_len'] + 1 + len('_%s_List' % table.title())
    utils.append_fields_multi(lines, table, schema, '    ',
            lambda field: '_%s_%s_List' % (table.title(), utils.get(field, 'name').title()), max_padding)
    lines.append('] = %s_records_to_field_lists(%s),' % (table, records))

def erl_mod_c2s_records_to_fields(table, records):
    schema = utils.load_schema(table)
    if schema is None: return None
    lines = []
    _append_records_to_lists_match(lines, table, schema, records)
    return lines

def _append_record_to_fields_match(lines, table, schema, records):
    lines.append('[')
    max_padding = schema['fields_max_name_len'] + 1 + len('_%s_' % table.title())
    utils.append_fields_multi(lines, table, schema, '    ',
            lambda field: '_%s_%s' % (table.title(), utils.get(field, 'name').title()), max_padding)
    lines.append('] = db_%s:record_to_fields(%s),' % (table, records))

def erl_mod_c2s_record_to_fields(table, record):
    schema = utils.load_schema(table)
    if schema is None: return None
    lines = []
    _append_record_to_fields_match(lines, table, schema, record)
    return lines

def _append_to_pb(lines, module, table, schema, pb_type, pb_schema):
    lines.append('%s_MsgId = ?PROTO_CONVERT({mod_%s, %s}),' % (pb_type.title(), module, pb_type))
    lines.append('%s_Record = #%s{' % (pb_type.title(), pb_type))
    def get_line(pb_field, is_last):
        return '    %s = %s%s' % (pb_field[0], pb_field[1], not is_last and ',' or '')
    utils.append_list_single(lines, pb_schema, get_line)
    lines.append('    },')

def erl_mod_c2s_to_pb(module, table, pb_type):
    schema = utils.load_schema(table)
    if schema is None: return None
    pb_schema = schema['pb_types'][pb_type]
    lines = []
    _append_to_pb(lines, module, table, schema, pb_type, pb_schema)
    return lines

