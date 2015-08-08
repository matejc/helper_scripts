#!/usr/bin/env python

import os
import sys
import random

IMAGE_EXTS = ['jpeg', 'jpg', 'png']


def get_rand_path(paths, exts):
    files = []
    for path in paths:
        for root, dlist, flist in os.walk(path):
            for f in flist:
                if os.path.splitext(f)[1][1:].lower() in exts:
                    files += [os.path.join(root, f)]

    if files:
        return random.choice(files)
    else:
        return ""

args = sys.argv[1:]

if len(args) == 0:
    paths = ['.']
else:
    paths = []

for a in args:
    if os.path.exists(a):
        paths += [os.path.abspath(a)]

print get_rand_path(paths, IMAGE_EXTS)

# xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s <imagepath>
