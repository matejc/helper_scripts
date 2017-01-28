#!/usr/bin/env bash

# export ACCEPT="ACCEPT"
export ACCEPT="nixos-fw-accept"
export CHROMECAST_IP=192.168.88.254 # Adjust to the Chromecast IP in your local network

set -e

add_rules() {
    iptables -I INPUT -p udp -m udp --dport 32768:61000 -j ${ACCEPT}
    # iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ${ACCEPT}
    # iptables -A INPUT -s ${CHROMECAST_IP}/32 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -m comment --comment "Allow Chromecast UDP data (inbound)" -j ${ACCEPT}
    # iptables -A OUTPUT -d ${CHROMECAST_IP}/32 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -m comment --comment "Allow Chromecast UDP data (outbound)" -j ${ACCEPT}
    # iptables -A OUTPUT -d ${CHROMECAST_IP}/32 -p tcp -m multiport --dports 8008:8009 -m comment --comment "Allow Chromecast TCP data (outbound)" -j ${ACCEPT}
    # iptables -A OUTPUT -d 239.255.255.250/32 -p udp --dport 1900 -m comment --comment "Allow Chromecast SSDP" -j ${ACCEPT}
    echo "added"
}

remove_rules() {
    iptables -D INPUT -p udp -m udp --dport 32768:61000 -j ${ACCEPT}
    # iptables -D INPUT -m state --state ESTABLISHED,RELATED -j ${ACCEPT}
    # iptables -D INPUT -s ${CHROMECAST_IP}/32 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -m comment --comment "Allow Chromecast UDP data (inbound)" -j ${ACCEPT}
    # iptables -D OUTPUT -d ${CHROMECAST_IP}/32 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -m comment --comment "Allow Chromecast UDP data (outbound)" -j ${ACCEPT}
    # iptables -D OUTPUT -d ${CHROMECAST_IP}/32 -p tcp -m multiport --dports 8008:8009 -m comment --comment "Allow Chromecast TCP data (outbound)" -j ${ACCEPT}
    # iptables -D OUTPUT -d 239.255.255.250/32 -p udp --dport 1900 -m comment --comment "Allow Chromecast SSDP" -j ${ACCEPT}
    echo "removed"
}

remove_all_rules() {
    iptables -F
    echo "[remove_all_rules] done"
}

save_all_rules() {
    iptables-save > /tmp/current_ip_tables_rules
    # cat /tmp/current_ip_tables_rules
    echo "[save_all_rules] to /tmp/current_ip_tables_rules"
    echo "[save_all_rules] done"
}

reinstate_all_rules() {
    iptables-restore < /tmp/current_ip_tables_rules
    echo "[reinstate_all_rules] done"
}

pause_and_reinstate() {
    trap 'reinstate_all_rules' SIGINT
    echo "To reinstate iptables rules press Ctrl+C"
    tail -f &>/dev/null
}

pause_and() {
    trap "$1" SIGINT
    echo "To reinstate iptables rules press Ctrl+C"
    tail -f &>/dev/null
}

if [ "$1" == "all" ]
then
    save_all_rules && remove_all_rules && pause_and reinstate_all_rules
else
    add_rules && pause_and remove_rules
fi
