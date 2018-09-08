#!/usr/bin/env python

import re
import os
import sys
import argparse
import glob
import plistlib
import datetime
import pytz
from blessings import Terminal

CODE_CONTEXT = 6

ROOT_PATH = os.path.abspath(os.getcwd())

UNITY_CODE_PATH = os.path.join(ROOT_PATH, '../yulong/unity/MLDJ_Script/')
UNITY_CODE_EXCLUDE_LIST = [
]

ERL_CODE_PATH = os.path.join(ROOT_PATH, 'src/')
ERL_CODE_EXCLUDE_PREFIX = [
    "proto/proto_"
]

UNITY_HANDLERS_PATH = os.path.join(UNITY_CODE_PATH, 'GameLogic/NetWork/PacketHandler/')

ERL_HANDLERS_PATH = os.path.join(ERL_CODE_PATH, '../include/pbmessage_pb.hrl')

ERL_MODULES_PATH = os.path.join(ERL_CODE_PATH, 'player/mod/')

UNITY_HANDLER_FILENAME_SUFFIX = 'Handler.cs'
UNITY_HANDLER_FILENAME_PATTERN = '*' + UNITY_HANDLER_FILENAME_SUFFIX

ERL_MODULE_FILENAME_SUFFIX = '.erl'
ERL_MODULE_FILENAME_PATTERN = 'mod_*' + ERL_MODULE_FILENAME_SUFFIX

ERL_GATEWAY_PATH = os.path.join(ERL_CODE_PATH, 'gateway')
ERL_GATEWAY_FILENAME_PATTERN = 'gate_*' + ERL_MODULE_FILENAME_SUFFIX

#Report Sections

UNKNOWN = 'Unknown'
NA = 'N/A'
USED = 'Used'
UNUSED = 'Unused'

TODO = 'Todo'
DONE = 'Done'

#Report Item Keys
PATH = 'path'
NAME = 'name'
CODE = 'code'
CODES = 'codes'
SENDERS = 'senders'

STATE = 'state'

# Global Vars

Unity_Codes = None
Erl_Codes = None

#Debugging Utils
term = Terminal()

verbose_mode = False

def info(msg):
    print term.normal + msg


def verbose(msg):
    if verbose_mode:
        info(msg)


def error(msg):
    print term.red + msg


def format_error(err):
    return term.red(err)


def format_path(path):
    return term.blue(path)


def format_param(param):
    return term.yellow(param)


# Unity Handlers
def load_unity_handlers(patterns):
    path = os.path.join(UNITY_HANDLERS_PATH, UNITY_HANDLER_FILENAME_PATTERN)
    verbose('Load Unity Handles: %s' % path)
    matches = glob.glob(path)
    filtered = []
    for match in matches:
        matched = True
        if patterns:
            matched = False
            for pattern in patterns:
                if match.lower().find(pattern.lower()) >= 0:
                    matched = True
                    break
        if matched:
            verbose('Unity Handler Found: %s' % os.path.basename(match))
            filtered.append(match)
    info('Total Number of Found Unity Handlers %s' % len(filtered))
    return filtered


def to_string(line, encoding=None):
    if type(line) == unicode:
        result = line.encode('utf8')
    elif encoding and type(line) == str:
        failed = False
        try:
            result = line.decode(encoding).encode('utf8')
        except:
            failed = True
        if failed:
            result = line
        #result = line.decode('utf16')
    else:
        result = line
    #info('%s: %s' % (type(line), result))
    #return '%s: %s' % (type(line), result)
    return result

def is_unity_handler_hint(line):
    if line.find('//enter your logic') >= 0:
        return True
    if line.find('if (null == packet) return (uint)PACKET_EXE.PACKET_EXE_ERROR;') >= 0:
        return True
    return False

def get_unity_handler_state(handler, lines):
    found_execute = False
    found_hint = False
    for line in lines:
        if found_execute:
            pass #can count {} in the future
        else:
            if line.find('public uint Execute(PacketDistributed ipacket)') >= 0:
                found_execute = True

        if found_hint:
            if len(line.strip()) == 0:
                continue
            if is_unity_handler_hint(line):
                continue
            if line.find('return (uint)PACKET_EXE.PACKET_EXE_CONTINUE;') >= 0:
                if os.path.basename(handler).startswith('GC_'):
                    return UNUSED
                else:
                    return NA
            else:
                return USED
        else:
            if is_unity_handler_hint(line):
                found_hint = True

    if not found_hint and found_execute:
        return USED

    return UNKNOWN


def process_unity_handler(handler):
    lines = open(handler).readlines()
    state = get_unity_handler_state(handler, lines)
    verbose('%s: %s -> %s' % (os.path.basename(handler), len(lines), state))
    item = {}
    item[PATH] = os.path.relpath(handler, ROOT_PATH)
    item[NAME] = os.path.basename(handler).replace(UNITY_HANDLER_FILENAME_SUFFIX, '')
    item[STATE] = state
    item[CODE] = lines
    return item


def process_unity_handlers(handlers, report):
    i = 0
    for handler in handlers:
        i = i + 1
        item = process_unity_handler(handler)
        state = item[STATE]
        if state == USED:
            process_erl_senders(item)
            state = item[STATE]

        info('[%s] %s: %s' % (i, item[NAME], state))
        if not report.has_key(state):
            report[state] = []
        report[state].append(item)


def load_erl_codes():
    global Erl_Codes
    Erl_Codes = {}
    files = [os.path.join(dirpath, f)
             for dirpath, dirnames, files in os.walk(ERL_CODE_PATH)
             for f in files if f.endswith('.erl')]
    for path in files:
        path = os.path.abspath(path)
        name = path.replace(ERL_CODE_PATH, '')
        excluded = False
        for exclude_prefix in ERL_CODE_EXCLUDE_PREFIX:
            if name.startswith(exclude_prefix):
                excluded = True
                break
        if not excluded:
            key = os.path.relpath(path, ROOT_PATH)
            Erl_Codes[key] = open(path).readlines()
            verbose('Load Erl Code: %s -> %s' % (key, len(Erl_Codes[key])))
        else:
            verbose('Exclude Erl Code: %s' % (name))



def process_erl_senders(item):
    global Erl_Codes
    if not Erl_Codes:
        load_erl_codes()
    senders = {}
    for path in Erl_Codes:
        line_number = 1
        lines = Erl_Codes[path]
        for line in lines:
            if line.find('#%s{' % item[NAME].lower()) >= 0:
                code = []
                for i in range(line_number - CODE_CONTEXT - 1, line_number + CODE_CONTEXT):
                    if i >= 0 and i < len(lines):
                        if i == line_number - 1:
                            code.append('%s: -> %s' % (i, lines[i]))
                        else:
                            code.append('%s:    %s' % (i, lines[i]))
                senders[path] = code
            line_number = line_number + 1

    if len(senders) > 0:
        item[SENDERS] = senders
        item[STATE] = DONE
    else:
        item[STATE] = TODO


def load_unity_codes():
    global Unity_Codes
    Unity_Codes = {}
    files = [os.path.join(dirpath, f)
             for dirpath, dirnames, files in os.walk(UNITY_CODE_PATH)
             for f in files if f.endswith('.cs')]
    for path in files:
        path = os.path.abspath(path)
        name = path.replace(UNITY_CODE_PATH, '')
        excluded = False
        for exclude_name in UNITY_CODE_EXCLUDE_LIST:
            if exclude_name == exclude:
                excluded = True
                break
        if not excluded:
            key = os.path.relpath(path, ROOT_PATH)
            Unity_Codes[key] = open(path).readlines()
            verbose('Load Unity Code: %s -> %s' % (key, len(Unity_Codes[key])))
        else:
            verbose('Exclude Unity Code: %s' % (name))



def process_unity_senders(item):
    global Unity_Codes
    if not Unity_Codes:
        load_unity_codes()
    senders = {}
    for path in Unity_Codes:
        line_number = 1
        lines = Unity_Codes[path]
        for line in lines:
            if line.find(item[NAME]) >= 0:
                verbose('%s[%s]: %s' % (path, line_number, line))
            pattern = '.*\(\s*' + item[NAME] + '\s*\)\s*PacketDistributed.CreatePacket.*'
            if re.match(pattern, line) is not None:
                code = []
                for i in range(line_number - CODE_CONTEXT - 1, line_number + CODE_CONTEXT):
                    if i >= 0 and i < len(lines):
                        if i == line_number - 1:
                            code.append('%s: -> %s' % (i, lines[i]))
                        else:
                            code.append('%s:    %s' % (i, lines[i]))
                senders[path] = code
            line_number = line_number + 1

    if len(senders) > 0:
        item[SENDERS] = senders
        if item[STATE] != DONE:
            item[STATE] = TODO
    else:
        if item[STATE] != DONE:
            item[STATE] = UNUSED

def load_erl_modules(modules_path, module_filename_pattern):
    path = os.path.join(modules_path, module_filename_pattern)
    verbose('Load Erlang Modules: %s' % path)
    matches = glob.glob(path)
    modules = []
    for match in matches:
        verbose('Erlang Module Found: %s' % os.path.basename(match))
        lines = open(match).readlines()
        modules.append([match, lines])
    info('Total Number of Found Erlang Modules (%s) %s' % (path, len(modules)))
    return modules

def load_erl_handlers(patterns):
    lines = open(ERL_HANDLERS_PATH).readlines()
    filtered = []
    for line in lines:
        pattern = '-record\((.*)\,'
        match = re.match(pattern, line)
        if match is not None:
            match = match.group(1).upper()
            if match.startswith('CG_'):
                matched = True
                if patterns:
                    matched = False
                    for pattern in patterns:
                        if match.lower().find(pattern.lower()) >= 0:
                            matched = True
                            break
                if matched:
                    verbose('Erlang Handler Found: %s' % match)
                    filtered.append(match)
    info('Total Number of Found Erlang Handlers %s' % len(filtered))
    return filtered

def process_erl_handlers(handlers, modules, report):
    i = 0
    for handler in handlers:
        i = i + 1
        item = process_erl_handler(handler, modules)
        state = item[STATE]
        if state != NA:
            process_unity_senders(item)
            state = item[STATE]

        info('[%s] %s: %s' % (i, item[NAME], state))
        if not report.has_key(state):
            report[state] = []
        report[state].append(item)

def get_erl_module_codes(modules, msg):
    result = []
    for module in modules:
        match = module[0]
        line_number = 1
        lines = module[1]
        for line in lines:
            if line.find('#%s{' % msg.lower()) >= 0:
                code = []
                for i in range(line_number - CODE_CONTEXT - 1, line_number + CODE_CONTEXT):
                    if i >= 0 and i < len(lines):
                        if i == line_number - 1:
                            code.append('%s: -> %s' % (i, lines[i]))
                        else:
                            code.append('%s:    %s' % (i, lines[i]))
                result.append({PATH:os.path.relpath(module[0], ROOT_PATH), CODE:code})
            line_number = line_number + 1
    return result

def process_erl_handler(handler, modules):
    item = {}
    item[NAME] = handler

    codes = get_erl_module_codes(modules, handler)
    if os.path.basename(handler).startswith('GC_'):
        state = NA
    else:
        if codes:
            state = DONE
        else:
            state = UNKNOWN

    verbose('%s: %s -> %s' % (os.path.basename(handler), len(codes), state))
    item[STATE] = state
    item[CODES] = codes
    return item


def generate_handlers_report(patterns):
    info('')
    unity_handlers = load_unity_handlers(patterns)
    report = {}
    process_unity_handlers(unity_handlers, report)

    info('')
    erl_modules = load_erl_modules(ERL_MODULES_PATH, ERL_MODULE_FILENAME_PATTERN)
    erl_modules.extend(load_erl_modules(ERL_GATEWAY_PATH, ERL_GATEWAY_FILENAME_PATTERN))
    erl_handlers = load_erl_handlers(patterns)
    process_erl_handlers(erl_handlers, erl_modules, report)
    return report


def append_code_block(lines, path, code):
    lang = 'Erlang'
    encoding = None
    if path:
        lines.append(path + '\n')
        if path.endswith('.cs'):
            lang = 'C#'
            enca_cmd = 'enca -L none %s' % os.path.join(ROOT_PATH, path)
            verbose('Detecting Encoding: %s' % enca_cmd)
            enca_code = os.system(enca_cmd)
            if enca_code != 0:
                info('Found GBK File [%s]: %s' % (enca_code, path))
                encoding = 'gbk'
    lang = '' #can't be parsed properply due to the line number
    lines.append('```%s\n' % lang)
    last_line = ''
    for line in code:
        last_line = '%s' % (to_string(line, encoding).replace('\r', ''))
        lines.append(last_line)
    if not last_line.endswith('\n'):
        lines.append('\n')
    lines.append('```\n\n')


def generate_md_lines_state(lines, report, state, deep):
    if not report.has_key(state):
        return

    items = report[state]
    lines.append('\n## %s Messages: %s\n' % (state, len(items)))
    for item in items:
        if deep:
            lines.append('### %s\n' % (item[NAME]))
            if item.has_key(CODES):
                for code in item[CODES]:
                    append_code_block(lines, code.get(PATH), code[CODE])
            else:
                append_code_block(lines, item.get(PATH), item[CODE])
            if item.has_key(SENDERS):
                for sender in item[SENDERS]:
                    append_code_block(lines, sender, item[SENDERS][sender])
        else:
            lines.append(' - %s\n' % (item[NAME]))


def generate_md_overview(lines, report):
    lines.append('| State | Count |\n')
    lines.append('| :---- | ----: |\n')
    def add_state(state):
        if report.has_key(state):
            items = report[state]
            lines.append('| %s | %s |\n' % (state, len(items)))
    for state in (UNKNOWN, TODO, DONE, UNUSED):
        add_state(state)


def save_state_report(prefix, report, state):
    lines = []
    lines.append('# Message Progress Report [%s]\n' % state)
    generate_md_overview(lines, report)
    generate_md_lines_state(lines, report, state, True)
    path = 'build/reports/%s_messages_%s.md' % (prefix, state.lower())
    open(os.path.join(ROOT_PATH, path), 'w').writelines(lines)
    info('%s Report Saved: %s' % (state, path))


def save_overview_report(prefix, report):
    lines = []
    lines.append('# Message Progress Report [Overview]\n')
    generate_md_overview(lines, report)
    for state in (UNKNOWN, TODO, DONE, UNUSED):
        generate_md_lines_state(lines, report, state, False)
    path = 'build/reports/%s_messages_overview.md' % prefix
    open(os.path.join(ROOT_PATH, path), 'w').writelines(lines)
    info('Overview Report Saved: %s' % path)


def sort_report(report):
    for state in report:
        report[state].sort(lambda a, b: cmp(a[NAME], b[NAME]))


def info_overview(prefix, report):
    info('Message Progress Overview: %s' % prefix)
    def add_state(state):
        if report.has_key(state):
            items = report[state]
            info('%s -> %s' % (state, len(items)))
            for item in items:
                info('    %s' % item[NAME])
    for state in (UNKNOWN, TODO, DONE, UNUSED):
        add_state(state)


#Main Entry
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbose', action='store_true')
    parser.add_argument('patterns', nargs='*')

    args = parser.parse_args()
    global verbose_mode
    verbose_mode = args.verbose

    report = generate_handlers_report(args.patterns)

    sort_report(report)

    prefix = 'all'
    if args.patterns:
        prefix = ''
        for p in args.patterns:
            if prefix:
                prefix = prefix + '_'
            prefix = prefix + p

    info('')
    info_overview(prefix, report)

    info('')
    save_overview_report(prefix, report)
    save_state_report(prefix, report, UNKNOWN)
    save_state_report(prefix, report, TODO)
    save_state_report(prefix, report, DONE)

main()
