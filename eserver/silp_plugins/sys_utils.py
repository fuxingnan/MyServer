# -*- coding: utf8 -*-

import os
import traceback
import json
import re

import silp
import utils

def camelcase_to_underscore(name):
    # http://stackoverflow.com/questions/1175208/elegant-python-function-to-convert-camelcase-to-camel-case
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def underscore_to_camelcase(name):
    return name.title().replace('_', '')

def _update_field(txt_name, field, txt_type):
    field_type = ''
    sql_type = ''

    if txt_type == 'STRING':
        field_type = 'string'
        sql_type = 'VARCHAR(50) NOT NULL'
    elif txt_type == 'INT':
        field_type = 'integer'
        sql_type = 'INT(11) NOT NULL'
    elif txt_type == 'FLOAT':
        field_type = 'float'
        sql_type = 'FLOAT NOT NULL'
    elif txt_type == 'BOOL':
        field_type = 'integer'
        sql_type = 'TINYINT(1) unsigned NOT NULL'
    else:
        silp.error('Unsupport type in %s.txt %s: %s' %(txt_name, field['description'], txt_type))
        return

    field['type'] = field_type
    field['sql_type'] = sql_type

def _load_fields(txt_name, txt_content):
    fields = []
    names = txt_content[0].split('\t')
    types = txt_content[1].split('\t')
    index = 0;
    for name in names:
        field = {}
        field['name'] = camelcase_to_underscore(name)
        field['description'] = name
        _update_field(txt_name, field, types[index])
        fields.append(field)
        index += 1
    return fields

def load_sys_schema(table):
    schema = None
    try:
        path = os.path.dirname(__file__)
        txt_name = underscore_to_camelcase(table)
        txt_content = open(os.path.join(path, '..', 'doc', txt_name + '.txt')).readlines()
        txt_content = [line.replace('\n', '').replace('\r', '') for line in txt_content]
        schema = {
            'description': underscore_to_camelcase(table) + '.txt',
            'fields': _load_fields(txt_name, txt_content),
        }

    except Exception as e:
        silp.error('Load Sys Schema Failed: %s -> %s' % (table, e))
        silp.error(traceback.format_exc())
        return None, []

    utils.update_schema(schema)
    return schema, txt_content[2:]
