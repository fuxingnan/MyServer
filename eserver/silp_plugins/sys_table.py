# -*- coding: utf8 -*-

import os
import traceback
import json

import silp

import sys

path = os.path.dirname(__file__)
if not path in sys.path:
    sys.path.insert(0, path)
    silp.info('Insert %s to sys.path' % path)

from sql_create import sql_create_sys_table, sql_insert_sys_data
from hrl_record import hrl_sys_record
from erl_sys_module import erl_sys_simple, erl_sys_custom
from erl_gen_module import erl_gen_simple, erl_gen_custom

