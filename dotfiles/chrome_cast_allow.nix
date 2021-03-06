{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/chrome_cast_allow";
  source = pkgs.writeScript "chromecastallow.sh" ''
    #!${pkgs.stdenv.shell}

    export ACCEPT="ACCEPT"
    export CHROMECAST_IP="$1" # Adjust to the Chromecast IP in your local network

    # 1. chrome://flags/#load-media-router-component-extension >> enabled
    #    or run: chromium --load-media-router-component-extension
    # 2. sudo -E $0
    # 3. search for chromecast inside chromium
    # 4. remove rules (Ctrl+C for the 2. step)
    # 5. use chromecast
    # 6. repeat steps from 2. to 5. when you restart chromium

    set -e

    add_rules() {
        #iptables -I INPUT -s ''${CHROMECAST_IP}/32 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -m comment --comment "Allow Chromecast UDP data (inbound)" -j ''${ACCEPT}
        #iptables -I OUTPUT -d ''${CHROMECAST_IP}/32 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -m comment --comment "Allow Chromecast UDP data (outbound)" -j ''${ACCEPT}

        #iptables -I OUTPUT -d ''${CHROMECAST_IP}/32 -p tcp -m multiport --dports 8008:8009 -m comment --comment "Allow Chromecast TCP data (outbound)" -j ''${ACCEPT}
        #iptables -I OUTPUT -d 239.255.255.250/32 -p udp --dport 1900 -m comment --comment "Allow Chromecast SSDP" -j ''${ACCEPT}

        #iptables -I OUTPUT -d 224.0.0.0/24 -p udp --dport 5353 -m comment --comment "Allow Chromecast mDNS" -j ''${ACCEPT}
        iptables -I INPUT -d 224.0.0.0/24 -p udp --dport 5353 -m comment --comment "Allow Chromecast mDNS" -j ''${ACCEPT}

        echo "added"
    }

    remove_rules() {
        #iptables -D INPUT -s ''${CHROMECAST_IP}/32 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -m comment --comment "Allow Chromecast UDP data (inbound)" -j ''${ACCEPT}
        #iptables -D OUTPUT -d ''${CHROMECAST_IP}/32 -p udp -m multiport --sports 32768:61000 -m multiport --dports 32768:61000 -m comment --comment "Allow Chromecast UDP data (outbound)" -j ''${ACCEPT}

        #iptables -D OUTPUT -d ''${CHROMECAST_IP}/32 -p tcp -m multiport --dports 8008:8009 -m comment --comment "Allow Chromecast TCP data (outbound)" -j ''${ACCEPT}
        #iptables -D OUTPUT -d 239.255.255.250/32 -p udp --dport 1900 -m comment --comment "Allow Chromecast SSDP" -j ''${ACCEPT}

        #iptables -D OUTPUT -d 224.0.0.0/24 -p udp --dport 5353 -m comment --comment "Allow Chromecast mDNS" -j ''${ACCEPT}
        iptables -D INPUT -d 224.0.0.0/24 -p udp --dport 5353 -m comment --comment "Allow Chromecast mDNS" -j ''${ACCEPT}

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
  '';
}]
