#!/usr/bin/env bash

PRIMARY="LVDS1"
EXTERNAL="VGA1"


SCREENS_COUNT=$(xrandr -q | grep " connected" | wc -l)

if [ $SCREENS_COUNT = 1 ]; then
    xrandr --output $PRIMARY --auto --output $EXTERNAL --off
else
    xrandr --output $PRIMARY --auto --output $EXTERNAL --auto --right-of $PRIMARY
fi