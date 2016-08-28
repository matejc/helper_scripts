#!/usr/bin/env bash
app=$1
wmctrl -ia "$(wmctrl -lp | grep "$(pgrep "$app")" | tail -1 | awk '{ print $1 }')"
