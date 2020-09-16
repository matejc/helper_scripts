#!/usr/bin/env bash

set -e

name="$1"

if [ -z "$name" ]
then
  echo "Usage: $0 <name>" 1>&2
  exit 1
fi

vpn_all="$(systemctl list-unit-files | grep -oE 'openvpn-.+\.service')"
names="$(sed -Ee 's/openvpn-(.+)\.service/\1/g' <<< "$vpn_all")"

if ! grep -qE "^${name}$" <<< "$names" && [ "$name" != "none" ]
then
  echo -e "$name is not available:\nnone\n$names" 1>&2
  exit 1
fi

for n in $names
do
  echo "Stopping $n ..."
  sudo systemctl stop "openvpn-$n.service"
done

if [ "none" != "$name" ]
then
  echo "Starting $name ..."
  sleep 3
  sudo systemctl start "openvpn-$name.service"
  journalctl -fu "openvpn-$name.service"
fi
