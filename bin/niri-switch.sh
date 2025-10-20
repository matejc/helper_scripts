#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq

SW_FIFO="$HOME/.niri-switch.fifo"

cleanup() {
  rm -f "$SW_FIFO"
}

reader() {
  mkfifo "$SW_FIFO"
  trap cleanup EXIT
  while IFS= read -r line <"$SW_FIFO"
  do
    case "$line" in
      UP)
        echo UP
        timer_cancel
        niri msg action open-overview
        niri msg action focus-workspace-up
        timer_run
        ;;
      DOWN)
        echo DOWN
        timer_cancel
        niri msg action open-overview
        niri msg action focus-workspace-down
        timer_run
        ;;
      LEFT)
        echo LEFT
        timer_cancel
        niri msg action open-overview
        niri msg action focus-column-left
        timer_run
        ;;
      RIGHT)
        echo RIGHT
        timer_cancel
        niri msg action open-overview
        niri msg action focus-column-right
        timer_run
        ;;
    esac
  done
}

timer_run() {
  if sleep 0.75
  then
    exec niri msg action close-overview
  fi &
}

timer_cancel() {
  kill "$(ps -o pid,cmd | awk '/sleep 0.75$/{printf $1}')"
}

if [ -n "$1" ]
then
  echo "$1" > "$SW_FIFO"
  exit 0
else
  reader
fi


