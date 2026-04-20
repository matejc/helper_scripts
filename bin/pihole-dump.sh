#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq

set -e

pihole_base="$1"
pihole_password="$2"
pihole_from="$3"

sid="$(curl -k -s -X POST "$pihole_base/api/auth" --data "{\"password\":\"$pihole_password\"}" | jq -r '.session.sid')"

cleanup() {
    curl -k -s -X DELETE "$pihole_base/api/auth?sid=$sid"
}

trap cleanup EXIT

network_devices="$(curl -k -s "$pihole_base/api/network/devices?sid=$sid" -H 'Content-Type: application/json')"
devs="$(jq -n --argjson net "$network_devices" '[$net.devices[]|.hwaddr as $hwaddr|.ips[]|{"\(.ip)": $hwaddr}]|reduce .[] as $item ({}; . + $item)')"

output="$(curl -k -s "$pihole_base/api/queries?length=10000&from=$(date -d "$pihole_from" +%s)&until=$(date +%s)&sid=$sid" -H 'Content-Type: application/json')"
queries="$(echo -n "$output" | jq '.queries|sort_by(.time|tonumber)')"

echo -n "$queries" | jq --argjson devs "$devs" -c '.[]|{time:.time|tonumber|todate,type:.type,domain:.domain,client:.client.ip,status:.status,hwaddr:$devs[.client.ip]}'
