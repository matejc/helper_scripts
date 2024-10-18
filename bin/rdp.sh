#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=/home/matejc/workarea/nixpkgs -i bash -p bash freerdp3 gnugrep chromedriver jq

# Used for unattended (afk) logins
# My usecase:
#   when machine locks its screen,
#   there is no way to paste to paste longer password to login,
#   so just close it and run this script again
#
# Conditions:
#   - for xfreerdp v3
#   - access through ARM gateway
#   - need to be logged in with SSO in the browser

set -e

# Script need to set following variables, example contents:
#
# export RDPW_FILE="$HOME/Downloads/file.rdpw"
# export RDP_USERNAME='your@email'
# export RDP_PASSWORD='your password'
#
# Run:
# $BROWSER --user-data-dir="$USER_DATA_DIR" --remote-debugging-port=$DEBUGGER_PORT --enable-features=UseOzonePlatform --ozone-platform=wayland
# DISPLAY=:0 ./bin/rdp.sh
source "$PWD/secrets.sh"

debuggerPort=${DEBUGGER_PORT:-9222}
driverPort=${DRIVER_PORT:-9223}
rdpPidFile="$(mktemp)"
rdpInStream="$(mktemp --dry-run)"
# profileDir="${USER_DATA_DIR}"

mkfifo "$rdpInStream"
trap 'kill $driverPid; kill $(cat "$rdpPidFile"); rm $rdpPidFile' EXIT SIGINT

while read -r line
do
  echo "$line"
  if [[ $line = Browse?to:* ]]
  then
    # geckodriver --port=$driverPort & driverPid=$!
    chromedriver --port="$driverPort" & driverPid=$!
    sleep 1
    sessionId=$(curl -H"Content-Type: application-json" -d "{ \"desiredCapabilities\": { \"goog:chromeOptions\": { \"debuggerAddress\": \"localhost:$debuggerPort\" } } }" "http://localhost:$driverPort/session" | jq -r '.sessionId')
    rdpLoginUrl="$(echo "$line" | grep -o "https://.*")"

    curl -H"Content-Type: application-json" -d "{\"url\":\"$rdpLoginUrl\"}" "http://localhost:$driverPort/session/$sessionId/url"
    sleep 0.3

    while true
    do
      rdpUrl="$(curl "http://localhost:$driverPort/session/$sessionId/url" | jq -r '.value')";
      if [[ $rdpUrl = */nativeclient* ]]
      then
        break 1
      else
        sleep 1
      fi
    done
  elif [[ $line = Paste?redirect?URL?here: ]]
  then
    echo "$rdpUrl" >> "$rdpInStream"
    curl -XDELETE "http://localhost:$driverPort/session/$sessionId"
  fi
done < <(tail -f "$rdpInStream" | stdbuf -o0 -i0 "${1:-xfreerdp}" "$RDPW_FILE" /u:"$RDP_USERNAME" /p:"$RDP_PASSWORD" /cert:ignore +clipboard /gateway:type:arm /network:auto /gfx:AVC444 /rfx /f "${@:2}" 2>&1 & rdpPid=$!; echo -n $rdpPid > "$rdpPidFile"; wait $rdpPid)
