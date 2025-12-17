#!/usr/bin/env bash
#
# Usage:
# 1. Run without arguments to run the "daemon" that listens on $SW_FIFO named pipe
# 2. Bind it to keybindings, example of usage:
#    Ctrl+Alt+Up        { spawn "${pkgs.niri-switcher}/bin/niri-switcher" "focus-workspace-up"; }
#    Ctrl+Alt+Down      { spawn "${pkgs.niri-switcher}/bin/niri-switcher" "focus-workspace-down"; }
#    Ctrl+Alt+Left      { spawn "${pkgs.niri-switcher}/bin/niri-switcher" "focus-column-left"; }
#    Ctrl+Alt+Right     { spawn "${pkgs.niri-switcher}/bin/niri-switcher" "focus-column-right"; }

set -e

SW_FIFO="$HOME/.niri-switch.fifo"

cleanup() {
  rm -f "$SW_FIFO"
}

reader() {
  mkfifo "$SW_FIFO"
  trap cleanup EXIT
  while IFS= read -r line <"$SW_FIFO"
  do
    echo "> $line"
    timer_cancel
    niri msg action open-overview
    sleep 0.05
    niri msg action "$line"
    timer_run
  done
}

timer_run() {
  if sleep 0.4
  then
    exec niri msg action close-overview
  fi &
}

timer_cancel() {
  kill "$(ps -o pid,cmd | awk '/sleep 0.4$/{printf $1}')" || true
}

if [ -n "$1" ]
then
  echo "$1" > "$SW_FIFO"
  exit 0
elif [ ! -e "$SW_FIFO" ]
then
  reader
else
  echo "Error: $SW_FIFO already exists!" >&2
  exit 1
fi
