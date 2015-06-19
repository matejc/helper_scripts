#!/usr/bin/env bash

OUI=$(echo ${1//[:.- ]/} | tr "[a-f]" "[A-F]" | egrep -o "^[0-9A-F]{6}")


if [ ! -f /tmp/oui.txt ]; then
  wget -O /tmp/oui.txt http://standards-oui.ieee.org/oui.txt
fi
cat /tmp/oui.txt | grep $OUI
