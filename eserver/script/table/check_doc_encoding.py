#!/usr/bin/env python

import os
import glob
from blessings import Terminal

BOM_STR = '\xef\xbb\xbf'

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


def is_gbk_encoding(path):
    enca_cmd = 'enca -L none %s' % path
    print format_path('Detecting Encoding: %s' % enca_cmd)
    enca_code = os.system(enca_cmd)
    if enca_code != 0:
        print format_param('Found GBK File [%s]: %s' % (enca_code, path))
        return True
    return False

def convert_gbk_file(path):
    print format_path('Convert from GBK to UTF-8: %s' % path)
    os.system('iconv -f GBK -t utf8 %s > /tmp/_check_doc_encoding.txt' % path)
    os.system('cp /tmp/_check_doc_encoding.txt %s' % path)

def check_bom(path):
    lines = open(path).readlines();
    lines = [line.replace('\n', '').replace('\r', '') for line in lines]
    if len(lines) > 0 and lines[0].startswith(BOM_STR):
        print format_path('File with BOM detected: %s' % path)
        lines[0] = lines[0].replace(BOM_STR, '')
        open(path, 'w').writelines('\n'.join(lines))
        print format_param('BOM removed: %s' % path)

def has_enca():
    has_enca_code = os.system('which enca')
    return has_enca_code == 0

def main():
    if not has_enca():
        error('Please install inotify-tools to run this script')
        info('')
        print format_param('sudo apt-get install enca')
        info('')
        return

    path = os.path.dirname(__file__)
    matches = glob.glob(os.path.join(path, '../../doc', '*.txt'))

    gbk_files = []
    for match in matches:
        if is_gbk_encoding(match):
            gbk_files.append(match)

    info('--------------------------------------------------------------------------------')
    print format_param('Total GBK Files: %s' % len(gbk_files))

    for path in gbk_files:
        convert_gbk_file(path)

    for path in matches:
        check_bom(path)
if __name__ == '__main__':
    main()
