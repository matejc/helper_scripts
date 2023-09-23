{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/eww/eww.yuck";
  source = pkgs.writeText "eww.yuck" ''
    (deflisten workspaces :initial "[]" "${pkgs.stdenv.shell} ~/.config/eww/scripts/get-workspaces")
    (deflisten current_workspace :initial "1" "${pkgs.stdenv.shell} ~/.config/eww/scripts/get-active-workspace")
    (defwidget workspaces []
      (eventbox :onscroll "${pkgs.stdenv.shell} ~/.config/eww/scripts/change-active-workspace {} ''${current_workspace}" :class "workspaces-widget"
        (box :space-evenly false
          (label :text "''${workspaces}''${current_workspace}" :visible false)
          (for workspace in workspaces
            (eventbox :onclick "hyprctl dispatch workspace ''${workspace.id}"
              (box :class "workspace-entry ''${workspace.id == current_workspace ? "current" : ""} ''${workspace.windows > 0 ? "occupied" : "empty"}"
                (label :text "''${workspace.id}")
                )
              )
            )
          )
        )
      )

    (deflisten window :initial "..." "${pkgs.stdenv.shell} ~/.config/eww/scripts/get-window-title")
    (defwidget window_w []
      (box
        (label :text "''${window}")
        )
      )

    (defwidget bar []
      (centerbox :orientation "h"
        (workspaces)
        (window_w)
        (sidestuff)))

    (defwidget sidestuff []
      (box :class "sidestuff" :orientation "h" :space-evenly false :halign "end"
        (metric :label "🔊"
                :value volume
                :onchange "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ {}%")
        (metric :label ""
                :value {EWW_RAM.used_mem_perc}
                :onchange "")
        (metric :label "💾"
                :value {round((1 - (EWW_DISK["/"].free / EWW_DISK["/"].total)) * 100, 0)}
                :onchange "")
        time))

    (defwidget music []
      (box :class "music"
           :orientation "h"
           :space-evenly false
           :halign "center"
        {music != "" ? "🎵''${music}" : ""}))

    (defwidget metric [label value onchange]
      (box :orientation "h"
           :class "metric"
           :space-evenly false
        (box :class "label" label)
        (scale :min 0
               :max 101
               :active {onchange != ""}
               :value value
               :onchange onchange)))

    (deflisten music :initial ""
      "${pkgs.playerctl}/bin/playerctl --follow metadata --format '{{ artist }} - {{ title }}' || true")

    (defpoll volume :interval "1s"
      "${pkgs.stdenv.shell} ~/.config/eww/scripts/getvol")

    (defpoll time :interval "10s"
      "date '+%H:%M %b %d, %Y'")


    (defwindow bar
              :monitor 0
              :geometry (geometry :x "0%"
                              :y "20px"
                              :width "90%"
                              :height "30px"
                              :anchor "top center")
              :stacking "fg"
              :reserve (struts :distance "40px" :side "top")
              :windowtype "dock"
              :wm-ignore false
      (bar)
      )
  '';
} {
  target = "${variables.homeDir}/.config/eww/scripts/getvol";
  source = pkgs.writeShellScript "getvol" ''
    result="$(${pkgs.wireplumber}/bin/wpctl get-volume "@DEFAULT_AUDIO_SINK@" | ${pkgs.gnused}/bin/sed -E 's/.*\.([0-9]+)$/\1/')"
    if [[ "$result" =~ ".*MUTED.*" ]]
    then
        echo "0"
    else
        echo "$result"
    fi
  '';
} {
  target = "${variables.homeDir}/.config/eww/scripts/change-active-workspace";
  source = pkgs.writeShellScript "change-active-workspace" ''
    function clamp {
      min=$1
      max=$2
      val=$3
      ${pkgs.python3Packages.python}/bin/python -c "print(max($min, min($val, $max)))"
    }

    direction=$1
    current=$2
    if test "$direction" = "down"
    then
      target=$(clamp 1 10 $(($current+1)))
      echo "jumping to $target"
      hyprctl dispatch workspace $target
    elif test "$direction" = "up"
    then
      target=$(clamp 1 10 $(($current-1)))
      echo "jumping to $target"
      hyprctl dispatch workspace $target
    fi
  '';
} {
  target = "${variables.homeDir}/.config/eww/scripts/get-active-workspace";
  source = pkgs.writeShellScript "get-active-workspace" ''
    hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[] | select(.focused) | .activeWorkspace.id'

    ${pkgs.socat}/bin/socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - |
      stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' -e '/^workspace>>/ {print $2}' -e '/^focusedmon>>/ {print $3}'
  '';
} {
  target = "${variables.homeDir}/.config/eww/scripts/get-workspaces";
  source = pkgs.writeShellScript "get-workspaces" ''
    spaces (){
      hyprctl workspaces -j | ${pkgs.jq}/bin/jq -Mc '[.[]|select((.id|tonumber) > 0)]|sort_by(.id)'
    }

    spaces
    ${pkgs.socat}/bin/socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
      spaces
    done
  '';
} {
  target = "${variables.homeDir}/.config/eww/scripts/get-window-title";
  source = pkgs.writeShellScript "get-window-title" ''
    hyprctl activewindow -j | ${pkgs.jq}/bin/jq --raw-output .title
    ${pkgs.socat}/bin/socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | stdbuf -o0 ${pkgs.gawk}/bin/awk -F '>>|,' '/^activewindow>>/{print $3}'
  '';
} {
  target = "${variables.homeDir}/.config/eww/eww.scss";
  source = pkgs.writeText "eww.scss" ''
    * {
      all: unset; //Unsets everything so you can style everything from scratch
    }

    //Global Styles
    .bar {
      background-color: #3a3a3a;
      color: gray;
      padding: 15px;
      border-radius: 15px;
    }

    // Styles on classes (see eww.yuck for more information)

    .sidestuff slider {
      all: unset;
      color: #ffd5cd;
    }

    .metric scale trough highlight {
      all: unset;
      background-color: #D35D6E;
      color: #000000;
      border-radius: 10px;
    }
    .metric scale trough {
      all: unset;
      background-color: #4e4e4e;
      border-radius: 50px;
      min-height: 3px;
      min-width: 50px;
      margin-left: 10px;
      margin-right: 20px;
    }
    .metric scale trough highlight {
      all: unset;
      background-color: #D35D6E;
      color: #000000;
      border-radius: 10px;
    }
    .metric scale trough {
      all: unset;
      background-color: #4e4e4e;
      border-radius: 50px;
      min-height: 3px;
      min-width: 50px;
      margin-left: 10px;
      margin-right: 20px;
    }
    .label-ram {
      font-size: large;
    }
    .workspace-entry:hover {
      color: red;
    }

    .workspace-entry.current {
      border-radius: 50%;
      border: 2px solid gray;
      padding: 0px;
    }

    .workspace-entry {
      min-height: 30px;
      min-width: 30px;
      padding: 2px;
    }
  '';
}]
