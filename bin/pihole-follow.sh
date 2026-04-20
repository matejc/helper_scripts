#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq

set -e

pihole_base="$1"
pihole_password="$2"

sid="$(curl -k -s -X POST "$pihole_base/api/auth" --data "{\"password\":\"$pihole_password\"}" | jq -r '.session.sid')"

cleanup() {
    curl -k -s -X DELETE "$pihole_base/api/auth?sid=$sid"
}

trap cleanup EXIT

network_devices="$(curl -k -s "$pihole_base/api/network/devices?sid=$sid" -H 'Content-Type: application/json')"
devs="$(jq -n --argjson net "$network_devices" '[$net.devices[]|.hwaddr as $hwaddr|.ips[]|{"\(.ip)": $hwaddr}]|reduce .[] as $item ({}; . + $item)')"

prev_last="0"

while true
do
  output="$(curl -k -s "$pihole_base/api/queries?from=$(date -d '3 minutes ago' +%s)&until=$(date +%s)&sid=$sid" -H 'Content-Type: application/json')"
  queries="$(jq --argjson output "$output" -n '$output.queries|sort_by(.time|tonumber)')"

  last="$(jq --argjson queries "$queries" -n -r '$queries|last|.id')"

  if (( last != prev_last ))
  then
    echo >&2
    jq -n --argjson devs "$devs" --argjson queries "$queries" --argjson last "$prev_last" -c '$queries[]|select(.id>$last)|{time:.time|tonumber|todate,type:.type,domain:.domain,client:.client.ip,status:.status,hwaddr:$devs[.client.ip]}'
  else
    echo -n . >&2
  fi

  prev_last="$last"

  sleep 5
done
