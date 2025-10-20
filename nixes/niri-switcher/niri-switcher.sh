#!/usr/bin/env bash

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
    sleep 0.1
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
  kill "$(ps -o pid,cmd | awk '/sleep 0.4$/{printf $1}')"
}

if [ -n "$1" ]
then
  echo "$1" > "$SW_FIFO"
  exit 0
else
  reader
fi
