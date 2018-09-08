# -*- coding: utf8 -*-

import os
import traceback
import json

import silp

import utils

def _append_table_defines(lines, table, schema):
    lines.append('-define(TABLE_%s, "%s").' % (table.upper(), table))
    lines.append('-define(FULL_FIELDS_%s, [' % table.upper())
    utils.append_fields_multi(lines, table, schema, '    ', lambda field: '"%s"' % utils.get(field, 'name'))
    lines.append('    ]).')

def _append_fields_pattern_match(lines, table, schema, lead_padding):
    def get_len(l):
        return (l + 1) * 2 + 2
    max_padding = 4 * (get_len(schema['fields_max_name_len']) / 4 + 1) - 1
    def get_line(field, is_last):
        name = utils.get(field, 'name')
        description = utils.get(field, 'description')
        has_comma = (not is_last)
        padding = (max_padding - get_len(len(name))) * ' '
        return '%s%s = %s%s%s%%%% %s' % (lead_padding, name, name.title(), has_comma and ',' or ' ', padding, description)
    utils.append_fields_single(lines, table, schema, get_line)

def _append_fields_to_record(lines, table, decode, schema):
    def get_decoded_record():
        if decode:
            return 'decode(%s)' % table.title()
        else:
            return table.title()
    lines.append('fields_to_record([')
    utils.append_fields_multi(lines, table, schema, '    ', lambda field: utils.get(field, 'name').title())
    lines.append('    ]) ->')
    lines.append('    %s = #%s{' % (table.title(), table))
    _append_fields_pattern_match(lines, table, schema, '        ')
    lines.append('    },')
    lines.append('    %s.' % get_decoded_record())

def _append_record_to_field(lines, table, encode, schema):
    if encode:
        return _append_record_to_field_encode(lines, table, schema)
    else:
        return _append_record_to_field_simple(lines, table, schema)

def _append_record_to_field_encode(lines, table, schema):
    lines.append('record_to_fields(%s=#%s{}) ->' % (table.title(), table))
    lines.append('    #%s{' % table)
    _append_fields_pattern_match(lines, table, schema, '        ')
    lines.append('    } = encode(%s),' % table.title())
    lines.append('    [')
    utils.append_fields_multi(lines, table, schema, '    ', lambda field: utils.get(field, 'name').title())
    lines.append('    ].')

def _append_record_to_field_simple(lines, table, schema):
    lines.append('record_to_fields(#%s{' % table)
    _append_fields_pattern_match(lines, table, schema, '        ')
    lines.append('    } = _%s) -> [' % table.title())
    utils.append_fields_multi(lines, table, schema, '    ', lambda field: utils.get(field, 'name').title())
    lines.append('    ].')

def _append_accessor_export_common(lines, table, schema):
    lines.append('-export[fields_to_record/1, record_to_fields/1].')
    lines.append('')

def _append_accessor_common(lines, table, encode_decode, schema):
    _append_table_defines(lines, table, schema)
    lines.append('')
    _append_fields_to_record(lines, table, encode_decode, schema)
    lines.append('')
    _append_record_to_field(lines, table, encode_decode, schema)
    lines.append('')

def _append_common_db_crud_export(lines, table, schema):
    lines.append('-export[create/1, update/1, list/1, list_all/0, count/1, count_all/0].')

def _append_primary_db_crud_export(lines, table, schema):
    lines.append('-export[append/1, load/1, delete/1].')
    lines.append('')

def _append_primary_db_crud(lines, table, schema):
    _append_common_db_create(lines, table, schema)
    _append_primary_db_append(lines, table, schema)
    _append_primary_db_load(lines, table, schema)
    _append_primary_db_update(lines, table, schema)
    _append_primary_db_delete(lines, table, schema)
    _append_common_db_list(lines, table, schema)
    _append_common_db_list_all(lines, table, schema)
    _append_common_db_count(lines, table, schema)
    _append_common_db_count_all(lines, table, schema)

def _append_common_db_create(lines, table, schema):
    lines.append('%%%% @doc 创建数据 #%s' % table)
    lines.append('create(%s) ->' % table.title())
    lines.append('    Vals = record_to_fields(%s),' % table.title())
    lines.append('    case ?DB_GAME:insert(?TABLE_%s, Vals) of' % (table.upper()))
    lines.append('        {updated, 1} ->')
    lines.append('            ok;')
    lines.append('        {error, _Reason} ->')
    lines.append('            ?ERROR("Create %s error: ~p ~p", [%s, _Reason]),' % (table, table.title()))
    lines.append('            ?C2SERR(?E_DB)')
    lines.append('    end.')
    lines.append('')

def _append_common_db_load(lines, table, x, schema):
    lines.append('%%%% @doc 加载数据 #%s' % table)
    lines.append('load(%s) ->' % x.title())
    lines.append('    case ?DB_GAME:select(?TABLE_%s, ?FULL_FIELDS_%s, ["%s=", db_util:encode(%s)]) of' % (table.upper(), table.upper(), x, x.title()))
    lines.append('        {error, _Reason} ->')
    lines.append('            ?ERROR("Load %s error: ~p ~p", [%s, _Reason]),' % (table, x.title()))
    lines.append('            [];')
    lines.append('        {selected, _Fields, [Row]} ->')
    lines.append('            % ?DEBUG("selected fields: ~p~nrow: ~p", [_Fields, Row]),')
    lines.append('            fields_to_record(Row);')
    lines.append('        {selected, _Fields, []} ->')
    lines.append('            ?DEBUG("Load %s not found: ~p", [%s]),' % (table, x.title()))
    lines.append('            []')
    lines.append('    end.')
    lines.append('')

def _append_common_db_update(lines, table, x, schema):
    def get_where():
        if x == 'id':
            where = 'db_util:where_id(Id)'
        else:
            where = '["%s=", db_util:encode(%s)]' % (x, x.title())
        return where
    lines.append('%%%% @doc 更新数据 #%s' % table)
    lines.append('update(%s) ->' % table.title())
    lines.append('    ["%s" | Fields] = ?FULL_FIELDS_%s,' % (x, table.upper()))
    lines.append('    [%s | Vals] = record_to_fields(%s),' % (x.title(), table.title()))
    lines.append('    case ?DB_GAME:update(?TABLE_%s, Fields, Vals, %s) of' % (table.upper(), get_where()))
    lines.append('        {updated, 1} ->')
    lines.append('            ok;')
    lines.append('        {updated, 0} ->')
    lines.append('            ok;')
    lines.append('        {error, _Reason} ->')
    lines.append('            ?ERROR("Update %s error: ~p ~p", [%s, _Reason]),' % (table, x.title()))
    lines.append('            ?C2SERR(?E_DB)')
    lines.append('    end.')
    lines.append('')

def _append_common_db_delete(lines, table, x, schema):
    def get_where():
        if x == 'id':
            where = 'db_util:where_id(IdOrConditions)'
        else:
            where = '["%s=", db_util:encode(%sOrConditions)]' % (x, x.title())
        return where
    lines.append('%%%% @doc 删除数据 #%s' % table)
    lines.append('delete(%sOrConditions) ->' % x.title())
    lines.append('    Conditions = case %sOrConditions of' % x.title())
    lines.append('        [_Head | _Tail] -> %sOrConditions;' % x.title())
    lines.append('        _ -> %s' % get_where())
    lines.append('    end,')
    lines.append('    case ?DB_GAME:delete(?TABLE_%s, Conditions) of' % (table.upper()))
    lines.append('        {updated, _N} ->')
    lines.append('            ok;')
    lines.append('        {error, _Reason} ->')
    lines.append('            ?ERROR("Delete %s error: ~p ~p", [Conditions, _Reason]),' % table)
    lines.append('            ?C2SERR(?E_DB)')
    lines.append('    end.')
    lines.append('')

def _append_primary_db_append(lines, table, schema):
    lines.append('%%%% @doc 添加数据 (自动生成 Id) #%s' % table)
    lines.append('append(%s) ->' % table.title())
    lines.append('    ["id" | Fields] = ?FULL_FIELDS_%s,' % table.upper())
    lines.append('    [_Id | _Vals] = record_to_fields(%s),' % table.title())
    lines.append('    Vals = lists:map(fun mysql:encode/1, _Vals),')
    lines.append('    InsertSql = ')
    lines.append('    ["insert into ", ?TABLE_%s, "(",' % table.upper())
    lines.append('     string:join(Fields, ", "),')
    lines.append('     ") values (", string:join(Vals, ", "), ");"],')
    lines.append('    FetchIdSql = "select LAST_INSERT_ID();",')
    lines.append('    DoTrans = fun() ->')
    lines.append('        mysql:fetch(InsertSql),')
    lines.append('        mysql:fetch(FetchIdSql)')
    lines.append('    end,')
    lines.append('    case ?DB_GAME:transaction(DoTrans) of')
    lines.append('        {atomic, {data, {mysql_result, _, [[Id]], _, _}}} ->')
    lines.append('            Id;')
    lines.append('        {atomic, Other} ->')
    lines.append('            ?ERROR("Append %s, Failed to Fetch Id: ~p", [Other]),' % table)
    lines.append('            ?C2SERR(?E_DB);')
    lines.append('        {error, _Reason} ->')
    lines.append('            ?ERROR("Append %s error: ~p", [_Reason]),' % (table))
    lines.append('            ?C2SERR(?E_DB)')
    lines.append('    end.')
    lines.append('')

def _append_primary_db_load(lines, table, schema):
    return _append_common_db_load(lines, table, 'id', schema)

def _append_primary_db_update(lines, table, schema):
    return _append_common_db_update(lines, table, 'id', schema)

def _append_primary_db_delete(lines, table, schema):
    return _append_common_db_delete(lines, table, 'id', schema)

def _append_common_db_list(lines, table, schema):
    lines.append('%%%% @doc 加载列表 #%s' % table)
    lines.append('list(Conditions) ->')
    lines.append('    case ?DB_GAME:select(?TABLE_%s, ?FULL_FIELDS_%s, Conditions) of' % (table.upper(), table.upper()))
    lines.append('        {error, _Reason} ->')
    lines.append('            ?ERROR("List %s error: ~p ~p", [Conditions, _Reason]),' % table)
    lines.append('            [];')
    lines.append('        {selected, _Fields, Rows} ->')
    lines.append('            [fields_to_record(Row) || Row <- Rows]')
    lines.append('    end.')
    lines.append('')

def _append_common_db_list_all(lines, table, schema):
    lines.append('list_all() -> list([]).')
    lines.append('')

def _append_common_db_count(lines, table, schema):
    lines.append('%%%% @doc 计数 #%s' % table)
    lines.append('count(Conditions) ->')
    lines.append('    case ?DB_GAME:select(?TABLE_%s, ["count(*)"], Conditions) of' % table.upper())
    lines.append('        {error, _Reason} ->')
    lines.append('            ?ERROR("Count %s error: ~p ~p", [Conditions, _Reason]),' % table)
    lines.append('            0;')
    lines.append('        {selected, _Fields, [[Count]]} ->')
    lines.append('            Count')
    lines.append('    end.')
    lines.append('')

def _append_common_db_count_all(lines, table, schema):
    lines.append('count_all() -> count([]).')
    lines.append('')

def erl_db_accessor_primary(table, encode_decode='false'):
    schema = utils.load_schema(table)
    if schema is None: return None
    encode_decode = encode_decode.strip() == 'true'
    lines = []
    _append_accessor_export_common(lines, table, schema)
    _append_common_db_crud_export(lines, table, schema)
    _append_primary_db_crud_export(lines, table, schema)
    _append_accessor_common(lines, table, encode_decode, schema)
    _append_primary_db_crud(lines, table, schema)
    return lines

def _append_relation_db_delete(lines, table, x, y, schema):
    lines.append('%%%% @doc 删除数据 #%s' % table)
    lines.append('delete(Conditions) ->')
    lines.append('    case ?DB_GAME:delete(?TABLE_%s, Conditions) of' % (table.upper()))
    lines.append('        {updated, _N} ->')
    lines.append('            ok;')
    lines.append('        {error, _Reason} ->')
    lines.append('            ?ERROR("Delete %s error: ~p ~p", [Conditions, _Reason]),')
    lines.append('            ?C2SERR(?E_DB)')
    lines.append('    end.')
    lines.append('')
    lines.append('delete(%s, %s) ->' % (x.title(), y.title()))
    lines.append('    Conditions = ["%s=", db_util:encode(%s), " and %s=", db_util:encode(%s)],' % (x, x.title(), y, y.title()))
    lines.append('    delete(Conditions).')
    lines.append('')

def _append_relation_db_load(lines, table, x, y, schema):
    lines.append('%%%% @doc 加载数据 #%s' % table)
    lines.append('load(%s, %s) ->' % (x.title(), y.title()))
    lines.append('    Conditions = ["%s=", db_util:encode(%s), " and %s=", db_util:encode(%s)],' % (x, x.title(), y, y.title()))
    lines.append('    case ?DB_GAME:select(?TABLE_%s, ?FULL_FIELDS_%s, Conditions) of' % (table.upper(), table.upper()))
    lines.append('        {error, _Reason} ->')
    lines.append('            ?ERROR("Load %s error: ~p ~p ~p", [%s, %s, _Reason]),' % (table, x.title(), y.title()))
    lines.append('            [];')
    lines.append('        {selected, _Fields, [Row]} ->')
    lines.append('            % ?DEBUG("selected fields: ~p~nrow: ~p", [_Fields, Row]),')
    lines.append('            fields_to_record(Row);')
    lines.append('        {selected, _Fields, []} ->')
    lines.append('            ?DEBUG("Load %s not found: ~p ~p", [%s, %s]),' % (table, x.title(), y.title()))
    lines.append('            []')
    lines.append('    end.')
    lines.append('')

def _append_relation_db_update(lines, table, x, y, schema):
    lines.append('%%%% @doc 更新数据 #%s' % table)
    lines.append('update(%s) ->' % table.title())
    lines.append('    ["%s" | _Fields] = ?FULL_FIELDS_%s,' % (x, table.upper()))
    lines.append('    ["%s" | Fields] = _Fields,' % y)
    lines.append('    [%s | _Vals] = record_to_fields(%s),' % (x.title(), table.title()))
    lines.append('    [%s | Vals] = _Vals,' % y.title())
    lines.append('    Conditions = ["%s=", db_util:encode(%s), " and %s=", db_util:encode(%s)],' % (x, x.title(), y, y.title()))
    lines.append('    case ?DB_GAME:update(?TABLE_%s, Fields, Vals, Conditions) of' % (table.upper()))
    lines.append('        {updated, 1} ->')
    lines.append('            ok;')
    lines.append('        {updated, 0} ->')
    lines.append('            ok;')
    lines.append('        {error, _Reason} ->')
    lines.append('            ?ERROR("Update %s error: ~p ~p ~p", [%s, %s, _Reason]),' % (table, x.title(), y.title()))
    lines.append('            ?C2SERR(?E_DB)')
    lines.append('    end.')
    lines.append('')

def _append_relation_db_list_by(lines, table, x, schema):
    lines.append('list_by_%s(%s) -> list(["%s=", db_util:encode(%s)]).' % (x, x.title(), x, x.title()))
    lines.append('')

def _append_relation_db_count_by(lines, table, x, schema):
    lines.append('count_by_%s(%s) -> count(["%s=", db_util:encode(%s)]).' % (x, x.title(), x, x.title()))
    lines.append('')

def _append_relation_db_crud(lines, table, x, y, schema):
    _append_common_db_create(lines, table, schema)
    _append_relation_db_update(lines, table, x, y, schema)
    _append_relation_db_delete(lines, table, x, y, schema)
    _append_relation_db_load(lines, table, x, y, schema)
    _append_common_db_list(lines, table, schema)
    _append_common_db_list_all(lines, table, schema)
    _append_relation_db_list_by(lines, table, x, schema)
    _append_relation_db_list_by(lines, table, y, schema)
    _append_common_db_count(lines, table, schema)
    _append_common_db_count_all(lines, table, schema)
    _append_relation_db_count_by(lines, table, x, schema)
    _append_relation_db_count_by(lines, table, y, schema)

def _append_relation_db_crud_export(lines, table, x, y, schema):
    lines.append('-export[load/2, delete/1, delete/2].')
    lines.append('-export[list_by_%s/1, list_by_%s/1].' % (x, y))
    lines.append('-export[count_by_%s/1, count_by_%s/1].' % (x, y))
    lines.append('')

def erl_db_accessor_relation(table, x, y, encode_decode='false'):
    schema = utils.load_schema(table)
    if schema is None: return None
    encode_decode = encode_decode.strip() == 'true'
    lines = []
    _append_accessor_export_common(lines, table, schema)
    _append_common_db_crud_export(lines, table, schema)
    _append_relation_db_crud_export(lines, table, x, y, schema)
    _append_accessor_common(lines, table, encode_decode, schema)
    _append_relation_db_crud(lines, table, x, y, schema)
    return lines

def _append_secondary_db_crud(lines, table, x, schema):
    _append_primary_db_crud(lines, table, schema);
    _append_relation_db_list_by(lines, table, x, schema)
    _append_relation_db_count_by(lines, table, x, schema)

def _append_secondary_db_crud_export(lines, table, x, schema):
    _append_primary_db_crud_export(lines, table, schema)
    lines.append('-export[list_by_%s/1, count_by_%s/1].' % (x, x))
    lines.append('')

def erl_db_accessor_secondary(table, x, encode_decode='false'):
    schema = utils.load_schema(table)
    if schema is None: return None
    encode_decode = encode_decode.strip() == 'true'
    lines = []
    _append_accessor_export_common(lines, table, schema)
    _append_common_db_crud_export(lines, table, schema)
    _append_secondary_db_crud_export(lines, table, x, schema)
    _append_accessor_common(lines, table, encode_decode, schema)
    _append_secondary_db_crud(lines, table, x, schema)
    return lines


def _append_extension_db_crud(lines, table, x, schema):
    _append_common_db_create(lines, table, schema)
    _append_common_db_list(lines, table, schema)
    _append_common_db_list_all(lines, table, schema)
    _append_common_db_count(lines, table, schema)
    _append_common_db_count_all(lines, table, schema)
    _append_common_db_load(lines, table, x, schema)
    _append_common_db_update(lines, table, x, schema)
    _append_common_db_delete(lines, table, x, schema)

def _append_extension_db_crud_export(lines, table, x, schema):
    lines.append('-export[load/1, delete/1].')
    lines.append('')

def erl_db_accessor_extension(table, x, encode_decode='false'):
    schema = utils.load_schema(table)
    if schema is None: return None
    encode_decode = encode_decode.strip() == 'true'
    lines = []
    _append_accessor_export_common(lines, table, schema)
    _append_common_db_crud_export(lines, table, schema)
    _append_extension_db_crud_export(lines, table, x, schema)
    _append_accessor_common(lines, table, encode_decode, schema)
    _append_extension_db_crud(lines, table, x, schema)
    return lines

def erl_db_accessor_update_cache_fields_header(table):
    schema = utils.load_schema(table)
    if schema is None: return None

    params = schema['primaryKey']
    if type(params) == list:
        params = ', '.join(['%s' % key.title() for key in params])
    else:
        params = params.title()

    lines = []
    lines.append('%% @doc Calculate the cache fields #%s' % table)
    lines.append('update_cache_fields(%s) ->' % params)
    lines.append('    case load(%s) of' % params)
    lines.append('        %s = #%s{' % (table.title(), table))
    def get_line_key(field_name, is_last):
        return   '            %s = %s,' % (field_name, field_name.title())
    utils.append_single(lines, table, schema['cache_keys'], get_line_key)
    def get_line_field(field_name, is_last):
        has_comma = (not is_last)
        return   '            %s = _Old_%s%s' % (field_name, field_name.title(), has_comma and ',' or '')
    utils.append_single(lines, table, schema['cache_fields'], get_line_field)
    lines.append('        } ->')
    return lines

def erl_db_accessor_update_cache_fields_update(table):
    schema = utils.load_schema(table)
    if schema is None: return None
    lines = []
    lines.append('New_%s = %s#%s{' % (table.title(), table.title(), table))
    def get_line(field_name, is_last):
        has_comma = (not is_last)
        return   '    %s = %s%s' % (field_name, field_name.title(), has_comma and ',' or '')
    utils.append_single(lines, table, schema['cache_fields'], get_line)
    lines.append('},')
    lines.append('ok = update(New_%s),' % table.title())
    lines.append('New_%s;' % table.title())
    return lines

def erl_db_accessor_update_cache_fields_footer(table):
    schema = utils.load_schema(table)
    if schema is None: return None
    lines = []
    lines.append('        _ -> none')
    lines.append('    end.')
    return lines

