# -*- coding: utf8 -*-

import os
import traceback
import json

import silp

def load_schema(table):
    schema = None
    try:
        path = os.path.dirname(__file__)
        schema = json.load(open(os.path.join(path, table + '.json')))

    except Exception as e:
        silp.error('Load Schema Failed: %s -> %s' % (table, e))
        silp.error(traceback.format_exc())

    update_schema(schema)
    return schema

def update_schema(schema):
    if schema is not None:
        max_name_len = 0
        count = 0
        for field in schema['fields']:
            name = get(field, 'name')
            max_name_len = max(max_name_len, len(name))
            count += 1
        schema['fields_count'] = count
        schema['fields_max_name_len'] = max_name_len


def get_field(schema, field_name):
    for field in schema['fields']:
        if field_name == get(field, 'name'):
            return field
    return None

def get(field, key, default=''):
    if field is None or not field.has_key(key): return default
    return field[key].encode('utf8')

def get_erlang_value(val):
    if val is None:
        return 'undefined'
    elif type(val) is unicode:
        return '"%s"' % val.encode("utf8")
    elif type(val) is str:
        return '"%s"' % val
    elif type(val) is int:
        return '%s' % val
    elif type(val) is bool:
        return val and 'true' or 'false'
    else:
        silp.error("Unknown type: %s -> %s", type(val), val)
        return '%s' % val

def get_default_value(field):
    if field.has_key('default'):
        return field['default']
    field_type = get(field, 'type')
    if field_type == 'integer':
        return 0
    elif field_type == 'string':
        return ""
    else:
        return None

def append_list_single(lines, schema_list, func):
    count = 0
    for item in schema_list:
        count += 1

    index = 0
    for item in schema_list:
        is_last = (index == count - 1)
        lines.append(func(item, is_last))
        index += 1

def append_fields_single(lines, table, schema, func):
    count = schema['fields_count']

    index = 0
    for field in schema['fields']:
        is_last = (index == count - 1)
        lines.append(func(field, is_last))
        index += 1

def append_single(lines, table, lst, func):
    count = len(lst)

    index = 0
    for item in lst:
        is_last = (index == count - 1)
        lines.append(func(item, is_last))
        index += 1

def append_fields_multi(lines, table, schema, lead_padding, func, max_padding=None):
    count = schema['fields_count']
    if max_padding is None:
        max_padding = schema['fields_max_name_len'] + 1

    index = 0
    line_item = 0
    line = lead_padding;
    for field in schema['fields']:
        value = func(field)

        if len(line) > 60 or line_item > 4:
            lines.append(line)
            line = lead_padding
            line_item = 0
        padding = (max_padding - len(value)) * ' '

        if index == count - 1:
            line = line + value
            lines.append(line)
        else:
            line = line + value + ',' + padding

        index += 1
        line_item += 1
