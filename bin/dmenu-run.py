#!/usr/bin/env python

import json
import os
import re
import subprocess

devnull = open(os.devnull)


def list_env_var(envvar):
    return os.environ[envvar].split(':')


def list_paths(path, executable=False, directory=False, recursive=False, regular=False):
    result = []

    for root, dirs, files in os.walk(path, followlinks=True):
        
        if directory:
            result += map(lambda x: (root, x), dirs)
        
        if files and (executable or regular):
            for file in files:
                abspath = os.path.join(root, file)
                if executable and os.access(abspath, os.X_OK):
                    result += [(root, file)]
                    continue
                if regular and os.path.isfile(abspath):
                    result += [(root, file)]

        if not recursive:
            break

    return result


def executables():
    result = []

    for directory in list_env_var('PATH'):
        paths = list_paths(directory, executable=True)
        result += map(lambda item: "{0:<50} [Executable: '{1}']".format(item[1], os.path.join(item[0], item[1])), paths)

    return result


def dirs():
    result = []
    result += list_paths(os.environ['HOME'], directory=True, regular=True)
    # result += list_paths("/your/custom/dir", directory=True)
    return map(lambda item: "{0:<50} [Open: '{1}']".format(item[1], os.path.join(item[0], item[1])), result)


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


run = dmenu(['-p', 'run:', '-l', '10', '-b', '-i'], [join(sorted(dirs())), join(sorted(executables()))])
if run:
    match = re.match(r'.+\s+\[Executable\: \'(.+)\'\]', run)
    if match:
        subprocess.call(match.groups()[0], shell=True)
        os.exit(0)
    match = re.match(r'.+\s+\[Open\: \'(.+)\'\]', run)
    if match:
        subprocess.call(['xdg-open', match.groups()[0]])
        os.exit(0)
    subprocess.call(run, shell=True)
