#!/usr/bin/env python

import json
import os
import re
import subprocess

devnull = open(os.devnull)
extensions_path = '/home/matejc/.config/chromium/Default/Extensions'


def list_apps(path):
    result = []
    for root, dirs, files in os.walk(path, followlinks=True):
        if files:
            for file in files:
                if file == "manifest.json":
                    abspath = os.path.join(root, file)
                    app_id = os.path.basename(os.path.dirname(root))
                    with open(abspath) as f:
                        o = json.load(f)
                    result += [(app_id, o['name'])]
    return result


def items():
    result = []
    result += list_apps(extensions_path)
    # result += list_paths("/your/custom/dir", directory=True)
    return map(lambda item: "{0:<50} [app_id: '{1}']".format(item[1], item[0]), result)


def join(paths):
    return '\n'.join(paths).encode('utf-8')


def dmenu(args=[], options=[]):
    dmenu_cmd = ["dmenu"]
    if args:
        dmenu_cmd += args
    p = subprocess.Popen(
        dmenu_cmd,
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    if options:
        stdout, _ = p.communicate('\n'.join(options).encode('utf-8'))
    else:
        stdout, _ = p.communicate()
    return stdout.decode('utf-8').strip('\n')


def read_last(path):
    result = []
    if not os.path.isfile(path):
        return result
    with open(path, 'r') as f:
        for line in f:
            s = line.strip()
            if s:
                result += [s]
    return result


def write_last(path, newentry):
    lines = read_last(path)
    if not newentry:
        return
    s = newentry.strip()
    lines.insert(0, s)
    with open(path, 'w') as f:
        f.write(join(remove_duplicates(lines[0:4])))


def remove_duplicates(values):
    result = []
    seen = set()
    for value in values:
        if value not in seen:
            result.append(value)
            seen.add(value)
    return result


s = join(read_last('/home/matejc/.dmenu_chrome_apps_last') + sorted(items()))
run = dmenu(['-p', 'run:', '-l', '10', '-b', '-i'], [s])
if run:
    match = re.match(r'.+\s+\[app_id\: \'(.+)\'\]', run)
    if match:
        write_last('/home/matejc/.dmenu_chrome_apps_last', run)
        subprocess.call('chromium --profile-directory=Default --app-id='+match.groups()[0], shell=True)
