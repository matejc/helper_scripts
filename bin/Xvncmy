#!/usr/bin/env bash

# requirements: pkgs.tightvnc, pkgs.xorg.fontmiscmisc, pkgs.xorg.fontcursormisc


function attr2path {
    echo "let pkgs = import <nixpkgs> {}; in (toString $1)+\"$2\"" | nix-instantiate --eval-only --strict - | cut -d "\"" -f 2
}

VNCFONTS=`attr2path pkgs.xorg.fontmiscmisc /lib/X11/fonts/misc`,`attr2path pkgs.xorg.fontcursormisc /lib/X11/fonts/misc`
export DISPLAY=:99.0

`attr2path pkgs.tightvnc /bin/Xvnc` :99 -localhost -alwaysshared -fp $VNCFONTS &
echo $! > $HOME/.Xvncmy${DISPLAY}.pid

sleep 1

$@ &
echo $! > $HOME/.runmy${DISPLAY}.pid

test -f $HOME/.runmy${DISPLAY}.pid &&
PID=`cat $HOME/.runmy${DISPLAY}.pid` &&
wait $PID
STATUS_CODE=`echo $?`
rm $HOME/.runmy${DISPLAY}.pid

test -f $HOME/.Xvncmy${DISPLAY}.pid && kill -15 `cat $HOME/.Xvncmy${DISPLAY}.pid` && rm $HOME/.Xvncmy${DISPLAY}.pid &&
echo "Xvnc terminated successfully! (${DISPLAY})"
exit $STATUS_CODE
