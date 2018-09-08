#!/usr/bin/env python

from bs4 import BeautifulSoup

MESSAGE_ID_PATH = 'build/unity/MessageID.cs'
MESSAGE_ID_OLD_PATH = 'build/unity/MessageID_old.cs'

def load_section(section):
    result = {}
    result['name'] = to_str(section['name'])
    result['id'] = int(to_str(section['id']))
    result['desc'] = to_str(section['desc'])
    msgs = section.findAll(name='msg')
    result['msgs'] = [('PACKET_' + to_str(msg['name']).upper(),
             int(to_str(msg['id'])), 
             to_str(msg['desc'])) for msg in msgs]
    return result

def load_msgs(path):
    lines = open(path).readlines()
    msgs = []
    for line in lines:
        if (line.strip().startswith('//')):
            continue
        if line.find('=') > 0:
            segs = line.split('=')
            msg = segs[0].strip()
            value_segs = segs[1].split(',')
            value = int(to_str(value_segs[0].strip()))
            comment = value_segs[1].strip().replace('//', '')
            msgs.append((msg, value, comment))
        elif line.find(',') > 0:
            segs = line.split(',')
            msg = segs[0].strip()
            value = 0
            comment = segs[1].strip().replace('//', '')
            msgs.append((msg, value, comment))
    return msgs

def to_str(val):
    if type(val) is unicode:
        return '%s' % val.encode("utf8")
    elif type(val) is str:
        return '%s' % val
    elif type(val) is int:
        return '%s' % val
    elif type(val) is bool:
        return val and 'true' or 'false'
    else:
        silp.error("Unknown type: %s -> %s", type(val), val)
        return '%s' % val

def has_msg(sections, msg_name):
    if msg_name == 'PACKET_NONE':
        return True
    for section in sections:
        for msg in section['msgs']:
            if msg[0] == msg_name:
                return True
    return False

def get_lines(sections, old_msgs):
    msg_count = 0
    lines = []
    lines.append('//This code create by CodeEngine, do NOT modify')
    lines.append('')
    lines.append('using System;')
    lines.append('public enum MessageID :ushort {')

    max_name_len = 0
    for section in sections:
        for msg in section['msgs']:
            max_name_len = max(max_name_len, len(msg[0]))
    for msg in old_msgs:
        max_name_len = max(max_name_len, len(msg[0]))
    max_padding = max_name_len + 1;

    padding = (max_padding - len('PACKET_NONE')) * ' '
    lines.append('    %s%s = 0,' %
            ('PACKET_NONE', padding))
    lines.append('')

    for section in sections:
        lines.append('    //%s: id = %s, name = %s' % (section['desc'], section['id'], section['name']))
        section_id = section['id'] * 256
        for msg in section['msgs']:
            padding = (max_padding - len(msg[0])) * ' '
            lines.append('    %s%s = %s, // %s:%s' %
                    (msg[0], padding, section_id + msg[1], msg[1],
                     msg[2]))
            msg_count = msg_count + 1
        lines.append('')

    lines.append('    //Other Messages')
    for msg in old_msgs:
        if not has_msg(sections, msg[0]):
            padding = (max_padding - len(msg[0])) * ' '
            lines.append('    %s%s, // %s' %
                    (msg[0], padding,
                     msg[2]))
            msg_count = msg_count + 1

    lines.append('')
    lines.append('    PACKET_SIZE')
    lines.append('}')
    return lines, msg_count

def main():
    protocol = BeautifulSoup(''.join(open('src/proto/protocol.xml').readlines()))
    msgs = []
    sections = []
    for _section in protocol.findAll(name='section'):
        sections.append(load_section(_section))

    old_msgs = load_msgs(MESSAGE_ID_OLD_PATH)
    lines, msg_count = get_lines(sections, old_msgs)
    open(MESSAGE_ID_PATH, 'w').write('\n'.join(lines))
    print('%s: Total %s Messages' % (MESSAGE_ID_PATH, msg_count))

if __name__ == '__main__':
    main()

