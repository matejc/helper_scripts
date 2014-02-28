#!/usr/bin/env python

import os
import string
import argparse


def quick():
    CURRENT_DIR = os.getcwd()

    for subdir, dirs, files in os.walk(CURRENT_DIR):
        for f in files:
            if string.lower(f[-4:]) == '.mp3':
                print "\n###########################"
                filepath = os.path.join(subdir, f)
                os.system("mp3gain -r \"%s\"" % (filepath,))
                os.system("id3v2 --delete-all \"%s\"" % (filepath,))
                #os.system("id3v2 -r TLEN \"%s\"" % (filepath,))


def full():
    TARGET_DIR = "/media/stuff/TARGET"
    CURRENT_DIR = os.getcwd()

    for subdir, dirs, files in os.walk(CURRENT_DIR):
        for f in files:
            if string.lower(f[-4:]) == '.mp3':
                print "\n###########################"
                filepath = os.path.join(TARGET_DIR, f)
                os.system("vbrfix -always \"%s\" \"%s\"" % (os.path.join(subdir, f), filepath))
                os.system("mp3gain -r \"%s\"" % (filepath,))
                os.system("id3v2 -r TLEN \"%s\"" % (filepath,))




parser = argparse.ArgumentParser(description="mp3gain & id3v2 & vbrfix and move (last one only in full mode)")
parser.add_argument("-f", "--full", action="store_true", help="vbrfix and move to TARGET_DIR")
args = parser.parse_args()


if args.full == True:
    full()
else:
    quick()
