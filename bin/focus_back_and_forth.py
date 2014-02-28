#!/usr/bin/env python

import subprocess

PREVWINFILE = "/tmp/i3_prev_win.dat"
PREV_WIN_MARK = "PREV_WIN_MARK"


def read_prev_win_mark():
    try:
        return open(PREVWINFILE).read()
    except:
        return None


def write_prev_win_mark(mark):
    try:
        with open(PREVWINFILE, "w") as f:
            f.write(str(mark))
    except:
        exit(1)


output1 = subprocess.check_output([
    "i3-input", "-F", "'mark {0}'".format(PREV_WIN_MARK)
])
output2 = subprocess.check_output([
    "i3-input", "-F", "'[con_mark={0}] focus'".format(PREV_WIN_MARK)
])

exit(0)
