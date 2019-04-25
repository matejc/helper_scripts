{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/bluetooth-connect";
  source = pkgs.writeScript "bluetooth-connect.sh" ''
    #!${pkgs.stdenv.shell}

    function entries()
    {
        ${pkgs.bluez}/bin/bluetoothctl -- devices | ${pkgs.gawk}/bin/awk '{$1=""; print "Connect "$0}'
    }

    entry=$( (echo Disconnect; entries)  | ${pkgs.rofi}/bin/rofi -dmenu -p "Select bluetooth action")

    if [ x"Disconnect" = x"$entry" ]
    then
        ${pkgs.bluez}/bin/bluetoothctl -- disconnect
    else
        echo "$entry" | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.findutils}/bin/xargs -i ${pkgs.bluez}/bin/bluetoothctl -- connect '{}'
    fi
  '';
} {
  target = "${variables.homeDir}/bin/xrandr-change";
  source = pkgs.writeScript "xrandr-change.sh" ''
    #!${pkgs.stdenv.shell}

    export PATH="${pkgs.xorg.xrandr}/bin:${pkgs.gawk}/bin:${pkgs.findutils}/bin:${pkgs.rofi}/bin:${pkgs.coreutils}/bin:${pkgs.python3Packages.python}/bin:${pkgs.gnugrep}/bin"

    set -e

    state="$(xrandr)";
    outputs="$(awk '{if ($2 == "connected") print $1}' <<< "$state")"

    function getModes() {
        awk -v output=$1 '{if ($1 == output) {getline; while ($0 ~ /^\ \ /) {print $1; getline;}}}' <<< "$state"
    }

    function getMode() {
        echo "$((echo auto; getModes "$1";) | rofi -dmenu -p "Select mode for $1 output")"
    }

    function getPosition() {
        output="$1"
        relationTo="$2"
        echo "$((echo -e "$output same-as $relationTo\n$output left-of $relationTo\n$output right-of $relationTo\n$output above $relationTo\n$output below $relationTo";) | rofi -dmenu -p "Select $output output relation to $relationTo output")"
    }

    function permutations() {
        python -c "import sys, itertools; a=sys.argv[1:]; print('\n'.join('\n'.join(' '.join(str(i) for i in c) for c in itertools.permutations(a, i)) for i in range(1, len(a)+1)))" "$@";
    }

    entries="$(permutations $outputs | rofi -dmenu -p "Select output combination (first one is primary)" | tr ' ' '\n')"

    flags=""
    primary="$(head -n 1 <<< "$entries")"

    if [[ -z "$entries" ]]
    then
        echo "No Selection" >&2
        exit 1
    fi

    for output in $outputs
    do
        if echo "$entries" | grep -Eq "^''${output}$"
        then
            mode="$(getMode $output)"
            if [ "$mode" == "auto" ] || [ -z "$mode" ]
            then
                modeFlag="--auto"
            else
                modeFlag="--mode $mode"
            fi

            if [ "$primary" == "$output" ]
            then
                flags="$flags --output $output --primary $modeFlag"
            else
                positionFlag="$(getPosition $output $primary | awk '{printf "--"$2" "$3}')"
                flags="$flags --output $output $modeFlag $positionFlag"
            fi
        else
            flags="$flags --output $output --off"
        fi
    done

    xrandr $flags
  '';
} {
  target = "${variables.homeDir}/bin/keyboard-layout-change";
  source = pkgs.writeScript "keyboard-layout-change.sh" ''
    #!${pkgs.stdenv.shell}
    export PATH="${pkgs.systemd}/bin:${pkgs.rofi}/bin:${pkgs.xorg.setxkbmap}/bin"
    setxkbmap "$(rofi -dmenu -p "Select keyboard layout" < <(localectl list-x11-keymap-layouts))"
  '';
}]
