#!/run/current-system/sw/bin/python2

import subprocess
import json
import sys
import os

MIN = 1
MAX = 10


def usage():
    return "Usage: {0} {{left|right}}".format(os.path.basename(sys.argv[0]))

if len(sys.argv) != 2:
    print usage()
    exit(1)

direction = sys.argv[1].lower()
if direction not in ('left', 'right'):
    print usage()
    exit(1)

output = subprocess.check_output(["i3-msg", "-t", "get_workspaces"])

workspaces = json.loads(output)

for workspace in workspaces:
    if workspace[u'focused'] == True:

        if direction == 'left':
            if workspace[u'num'] <= MIN:
                print MIN
                break
            print workspace[u'num'] - 1
        else:
            if workspace[u'num'] >= MAX:
                print MAX
                break
            print workspace[u'num'] + 1
        break

exit(0)
