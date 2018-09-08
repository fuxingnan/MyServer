# -*- coding: utf8 -*-

import os
import traceback
import json

import silp

'''
The purpose to have this plugin is to define db schema in one place, and use
silp to create the needed lines to be either used in source code or as SQL
statement.

At the moment, the schemas will be saved under `silp_plugins` folder

Custom extra fields
- size
- sql_type

Json Table Schema
- http://dataprotocols.org/json-table-schema/
'''

import sys

path = os.path.dirname(__file__)
if not path in sys.path:
    sys.path.insert(0, path)
    silp.info('Insert %s to sys.path' % path)

from sql_create import sql_create_table
from hrl_record import hrl_record, hrl_record_end
from erl_db_accessor import \
        erl_db_accessor_primary, erl_db_accessor_relation, erl_db_accessor_secondary, erl_db_accessor_extension, \
        erl_db_accessor_update_cache_fields_header, erl_db_accessor_update_cache_fields_footer, \
        erl_db_accessor_update_cache_fields_update
from erl_mod_c2s import \
        erl_mod_c2s_helpers, erl_mod_c2s_records_to_fields, \
        erl_mod_c2s_to_pb, erl_mod_c2s_record_to_fields

