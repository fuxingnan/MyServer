# -*- coding: utf8 -*-

import os
import traceback
import json

import silp

import utils
import sys_utils

def _append_create_table(lines, table, schema):
    lines.append('CREATE TABLE IF NOT EXISTS `%s` (' % table)
    def get_line(field, is_last):
        name = utils.get(field, 'name')
        sql_type = utils.get(field, 'sql_type')
        description = utils.get(field, 'description')
        has_comma = (not is_last)
        return '  `%s` %s %s%s' % (name, sql_type, description and ("COMMENT '%s'" % description) or '', has_comma and ',' or '')
    utils.append_fields_single(lines, table, schema, get_line)
    lines.append(') ENGINE=InnoDB DEFAULT CHARSET=utf8 CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;')
    lines.append('')

def _append_primary_key(lines, table, schema):
    primary_key = schema['primaryKey']
    if type(primary_key) == list:
        primary_key = ','.join(['`%s`' % key for key in primary_key])
    else:
        primary_key = '`%s`' % primary_key
    lines.append('ALTER TABLE `%s`' % table)
    lines.append('  ADD PRIMARY KEY (%s);' % primary_key)
    lines.append('')

def _append_auto_increment(lines, table, schema):
    field_name = '%s' % schema['autoIncrement']
    field = utils.get_field(schema, field_name)
    name = utils.get(field, 'name')
    sql_type = utils.get(field, 'sql_type')
    description = utils.get(field, 'description')
    lines.append('ALTER TABLE `%s`' % table)
    lines.append('  MODIFY `%s` %s AUTO_INCREMENT%s;' % (name, sql_type, description and (" COMMENT '%s'" % description) or ''))
    lines.append('')

def sql_create_table(table):
    schema = utils.load_schema(table)
    if schema is None: return None
    lines = []
    _append_create_table(lines, table, schema)
    _append_primary_key(lines, table, schema)
    if schema.has_key('autoIncrement'):
        _append_auto_increment(lines, table, schema)
    return lines

def sql_create_sys_table(table):
    schema, _ = sys_utils.load_sys_schema(table)
    if schema is None: return None

    table = 'sys_' + table
    lines = []
    _append_create_table(lines, table, schema)
    return lines

def _get_value_str(field, value):
    field_type = field['type']
    if field_type == 'string':
        return '"%s"' % value.replace('"', '')
    return value

def _append_insert_sys_data(lines, table, schema, row):
    values = row.split('\t')
    line = 'insert into sys_%s values(' % table
    index = 0
    for value in values:
        field = schema['fields'][index]
        line += _get_value_str(field, value)
        if index == schema['fields_count'] - 1:
            line += ');'
        else:
            line += ', '
        index += 1
    lines.append(line)

def sql_insert_sys_data(table):
    schema, rows = sys_utils.load_sys_schema(table)
    if schema is None: return None

    lines = []
    for row in rows:
        if len(row) == 0:
            continue
        elif row[0] == '#':
            continue
        else:
            _append_insert_sys_data(lines, table, schema, row)
    return lines

