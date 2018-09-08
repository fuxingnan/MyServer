#!/usr/bin/env python

import os
import glob

CHANGE_ID = False
CHANGE_NAME = True
CONVERT_TO_UTF8 = True


file_header = None

def convert_scale(val):
    return float(val) * 100

def get_data(line):
    if line.startswith('Id'):
        return None
    elif line.startswith('INT'):
        return None
    elif line.startswith('#'):
        return None
    try:
        result = line.split('\t')
        result = [field.strip() for field in result]
        result[0] = int(result[0]) #Id
        result[2] = int(result[2]) #SceneID
        for index in range(4, 7):
            result[index] = convert_scale(result[index])
        return result
    except Exception as e:
        print 'Invalid Line: %s -> %s' % (line, e)
        return None

def get_header(txt_context):
    result = []
    for line in txt_context:
        if get_data(line) is not None:
            break
        result.append(line)
    return result

def load_npc_table(path, all, npcs, monsters):
    txt_content = open(path).readlines()
    txt_content = [line.replace('\n', '').replace('\r', '') for line in txt_content]
    global file_header
    if file_header is None:
        file_header = get_header(txt_content)
    line_count = 1
    npc_count = 0
    monster_count = 0
    for line in txt_content:
        data = get_data(line)
        if data is not None:
            if data[1].startswith('NPC'):
                all.append(data)
                npcs.append(data)
                npc_count += 1
            elif data[1].startswith('Monster'):
                all.append(data)
                monsters.append(data)
                monster_count += 1
            else:
                print 'Invalid Desc: %s[%s] %s' % (path, line_count, data[1])
        line_count += 1
    print '%s: NPC -> %s, Monster -> %s' % (path, npc_count, monster_count)

def load_npc_tables(path):
    all = []
    npcs = []
    monsters = []
    matches = glob.glob(os.path.join(path, 'Scene*.txt'))
    for match in matches:
        load_npc_table(match, all, npcs, monsters)
    return all, npcs, monsters

def load_name_translations(path):
    names = {}
    txt_content = open(path).readlines()
    txt_content = [line.replace('\n', '').replace('\r', '') for line in txt_content]
    for line in txt_content:
        result = line.split('\t')
        result = [field.strip() for field in result]
        if len(result) > 3:
            name = result[2]
            name = name.split(' ')[0]
            names[name] = result[1]
            #print "Name: %s -> %s" % (name, result[1])
    return names

def cmp_data(a, b):
    if a[2] != b[2]:
        return cmp(a[2], b[2])
    return cmp(a[0], b[0])

def translate_name(names, name):
    name = name.split(' ')[0]
    return names.get(name, name)

def write(path, data_list, names):
    f = open(path, 'w')
    f.writelines('\n'.join(file_header))
    f.write('\n')
    count = 0
    for data in data_list:
        if CHANGE_ID:
            data[0] = count
        if CHANGE_NAME:
            data[1] = translate_name(names, data[1])
        data_str = ['%s' % field for field in data]
        f.write('\t'.join(data_str))
        f.write('\n')
        count += 1
    f.close()
    if CONVERT_TO_UTF8:
        os.system('iconv -f GBK -t utf8 %s > /tmp/_merge_npc_tables.txt' % path)
        os.system('cp /tmp/_merge_npc_tables.txt %s' % path)

def process_data_list(data_list):
    data_list.sort(cmp_data)

def main():
    path = os.path.dirname(__file__)
    all, npcs, monsters = load_npc_tables(path + '/npc')

    names = load_name_translations(path + '/npc/sys.txt')

    process_data_list(all)
    process_data_list(npcs)
    process_data_list(monsters)

    write(path + '/../../build/table/SceneNpc.txt', all, names)
    write(path + '/../../build/table/server/SceneNpc.txt', npcs, names)
    write(path + '/../../build/table/server/SceneMonster.txt', monsters, names)

    print 'Total Numbers: NPC -> %s, Monster -> %s' % (len(npcs), len(monsters))

if __name__ == '__main__':
    main()
