{ pkgs ? import <nixpkgs> { }, ... }:
let
  wlvncc = import ./wlvncc.nix { inherit pkgs; };

  initializeScreenShare = pkgs.writeShellScriptBin "sway-wsshare" ''
    set -e
    export PATH="${pkgs.sway}/bin:${pkgs.jq}/bin:${pkgs.wofi}/bin:${pkgs.coreutils}/bin:${pkgs.wayvnc}/bin:${wlvncc}/bin:$PATH"

    getPort() {
      read LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
      for port in $(seq $LOWERPORT $UPPERPORT)
      do
        (echo "" >/dev/tcp/127.0.0.1/$port) >/dev/null 2>&1
        if [ $? -ne 0 ]
        then
            echo $port
            break
        fi
      done
    }

    if ! swaymsg -t get_outputs | jq -er '.[]|select(.name|startswith("HEADLESS-"))|.name'
    then
      swaymsg create_output
    fi

    export headlessOutput="$(swaymsg -t get_outputs | jq -er '.[]|select(.name|startswith("HEADLESS-"))|.name')"

    swaymsg output "$headlessOutput" resolution 1920x1080

    swaymsg workspace 100 output "$headlessOutput"

    port=$(getPort)

    wayvnc 127.0.0.1 $port -r -o "$headlessOutput" & wayvncPid="$!"

    trap "swaymsg output $headlessOutput unplug; kill $wayvncPid" EXIT SIGINT

    wlvncc 127.0.0.1 $port
  '';
in
  initializeScreenShare
