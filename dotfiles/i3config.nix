{ variables, config, pkgs, lib }:
let
  xfce = pkgs.xfce4-14;
in
[{
  target = "${variables.homeDir}/.config/i3/config";
  source = pkgs.writeText "i3config" ''
  # Please see http://i3wm.org/docs/userguide.html for a complete reference!

  #{{{ Main

  set $mod Mod4

  # monitors
  # LVDS1
  set $snd_card ${variables.soundCard}

  # colors
  # set $dark     #262a33
  # set $grey     #666a73
  # set $dblue    #2264a2
  # set $blue     #5294e2
  # set $lgrey    #3e424d
  # set $white    #ffffff
  # set $mgrey    #b9c2cd


  # > horizontal | vertical | auto
  default_orientation horizontal

  # > default | stacking | tabbed
  workspace_layout tabbed

  # > normal | 1pixel | none
  new_window none

  # Use Mouse+$mod to drag floating windows to their wanted position
  floating_modifier $mod

  # default is 'smart' - stole focus on window activation if on same workspace
  # 'urgent' will not stole focus, just marked the window urgent
  #focus_on_window_activation urgent

  #}}}
  #{{{ Modes
  #{{{   Monitor mode
  mode "monitor_select" {

    # only one
    ${lib.concatImapStringsSep "\n" (index: v: ''
    bindsym ${toString index} exec --no-startup-id xrandr ${lib.concatImapStringsSep " " (i: v: "--output ${v.name} ${if index == i then (if v ? mode then "--mode ${v.mode}" else "--auto") else "--off"}") variables.monitors}; mode "default"
    '') variables.monitors}

    bindsym p mode "monitor_one";
    bindsym s mode "monitor_two";

    # back to normal: Enter or Escape
    bindsym Return mode "default"
    bindsym Escape mode "default"
  }

  mode "monitor_one" {
    # left and right
    bindsym l exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext --auto --left-of $mon_lap ; mode "default"
    bindsym r exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext --auto --right-of $mon_lap ; mode "default"

    # up and down
    bindsym u exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext --auto --above $mon_lap ; mode "default"
    bindsym d exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext --auto --below $mon_lap ; mode "default"

    # clone
    bindsym c exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext --auto --same-as $mon_lap ; mode "default"

    # back to normal: Enter or Escape
    bindsym Return mode "default"
    bindsym Escape mode "default"
  }

  mode "monitor_two" {
    # left and right
    bindsym l exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --left-of $mon_lap ; mode "default"
    bindsym r exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --right-of $mon_lap ; mode "default"

    # up and down
    bindsym u exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --above $mon_lap ; mode "default"
    bindsym d exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --below $mon_lap ; mode "default"

    # clone
    bindsym c exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --same-as $mon_lap ; mode "default"

    # back to normal: Enter or Escape
    bindsym Return mode "default"
    bindsym Escape mode "default"
  }
  #}}}
  #}}}
  #{{{ Fonts

  # font for window titles. ISO 10646 = Unicode
  # font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1
  #font -*-terminus-medium-r-normal-*-14-*-*-*-c-*-iso10646-1
  # font -*-terminus-medium-r-normal-*-12-120-72-72-c-60-iso10646-1
  #font pango:DejaVu Sans Mono 9
  #font pango:Bitstream Vera Sans Mono Roman 9
  font pango:${variables.font}

  #}}}
  #{{{ Workspaces
  set $w1 1
  set $w2 2
  set $w3 3
  set $w4 4
  set $w5 5
  set $w6 6
  set $w7 7
  set $w8 8
  set $w9 9
  set $w10 10

  # workspace "$w1" output $mon_lap
  # workspace "$w2" output $mon_lap
  # workspace "$w3" output $mon_lap
  # workspace "$w4" output $mon_lap
  # workspace "$w5" output $mon_lap
  # workspace "$w6" output $mon_lap
  # workspace "$w7" output $mon_lap
  # workspace "$w8" output $mon_lap
  # workspace "$w9" output $mon_ext
  # workspace "$w10" output $mon_ext1

  # switch to workspace
  bindsym $mod+1 workspace $w1
  bindsym $mod+2 workspace $w2
  bindsym $mod+3 workspace $w3
  bindsym $mod+4 workspace $w4
  bindsym $mod+5 workspace $w5
  bindsym $mod+6 workspace $w6
  bindsym $mod+7 workspace $w7
  bindsym $mod+8 workspace $w8
  bindsym $mod+9 workspace $w9
  bindsym $mod+0 workspace $w10

  # move focused container to workspace
  bindsym $mod+Shift+exclam move workspace $w1
  bindsym $mod+Shift+at move workspace $w2
  bindsym $mod+Shift+numbersign move workspace $w3
  bindsym $mod+Shift+dollar move workspace $w4
  bindsym $mod+Shift+percent move workspace $w5
  bindsym $mod+Shift+asciicircum move workspace $w6
  bindsym $mod+Shift+ampersand move workspace $w7
  bindsym $mod+Shift+asterisk move workspace $w8
  bindsym $mod+Shift+parenleft move workspace $w9
  bindsym $mod+Shift+parenright move workspace $w10

  bindsym $mod+Tab workspace back_and_forth

  bindsym $mod+grave workspace prev
  bindsym $mod+minus workspace prev
  bindsym $mod+equal workspace next

  #bindsym $mod+m mode "monitor_select"

  #}}}
  #{{{ Windows
  #{{{   Change focus

  for_window [class="^rambox$"] move container to workspace $w1
  for_window [class="^Franz$"] move container to workspace $w1
  for_window [class="^Pidgin$"] move container to workspace $w1
  for_window [class="^TelegramDesktop$"] move container to workspace $w1
  for_window [class="^Signal$"] move container to workspace $w1
  for_window [class="^Slack$"] move container to workspace $w1
  for_window [class="^ViberPC$"] move container to workspace $w1

  # for_window [class="^Alacritty$"] move container to workspace $w2
  for_window [class="^Xfce4-terminal$" window_role="xfce4-terminal-dropdown"] border pixel 1

  for_window [class="^jetbrains-idea$"] move container to workspace $w3
  for_window [class="^jetbrains-goland$"] move container to workspace $w3
  for_window [class="^Sublime_text$"] move container to workspace $w3
  for_window [class="^Atom$"] move container to workspace $w3
  for_window [class="^.nvim-qt-wrapped$"] move container to workspace $w3

  for_window [class="^Firefox$"] move container to workspace $w4
  for_window [class="^Firefox Developer Edition$"] move container to workspace $w4
  for_window [class="^Chromium.*"] move container to workspace $w4
  for_window [class="^Google-chrome.*"] move container to workspace $w4
  for_window [class="^keepassxc$"] move container to workspace $w4

  # change focus
  #bindsym $mod+h focus left
  #bindsym $mod+j focus down
  #bindsym $mod+k focus up
  #bindsym $mod+l focus right

  # alternatively, you can use the cursor keys:
  bindsym $mod+Left focus left
  bindsym $mod+Down focus down
  bindsym $mod+Up focus up
  bindsym $mod+Right focus right

  # focus the parent container
  #bindsym $mod+a focus parent

  # focus the child container
  #bindcode $mod+d focus child

  #}}}
  #{{{   Move

  # move focused window
  bindsym $mod+Shift+h move left
  bindsym $mod+Shift+j move down
  bindsym $mod+Shift+k move up
  bindsym $mod+Shift+l move right

  # alternatively, you can use the cursor keys:
  bindsym $mod+Shift+Left move left
  bindsym $mod+Shift+Down move down
  bindsym $mod+Shift+Up move up
  bindsym $mod+Shift+Right move right

  #}}}
  #{{{   Split

  #split in horizontal orientation
  bindsym $mod+x split h

  # split in vertical orientation
  bindsym $mod+z split v

  #}}}
  #{{{   Resize

  mode "resize" {
          # These bindings trigger as soon as you enter the resize mode

          # They resize the border in the direction you pressed, e.g.
          # when pressing left, the window is resized so that it has
          # more space on its left

  bindsym j resize shrink left 10 px or 10 ppt
  bindsym Shift+J resize grow left 10 px or 10 ppt

  bindsym k resize shrink down 10 px or 10 ppt
  bindsym Shift+K resize grow down 10 px or 10 ppt

  bindsym l resize shrink up 10 px or 10 ppt
  bindsym Shift+L resize grow up 10 px or 10 ppt

  bindsym semicolon resize shrink right 10 px or 10 ppt
  bindsym Shift+colon resize grow right 10 px or 10 ppt

          # same bindings, but for the arrow keys
  bindsym Left resize shrink left 10 px or 10 ppt
  bindsym Shift+Left resize grow left 10 px or 10 ppt

  bindsym Down resize shrink down 10 px or 10 ppt
  bindsym Shift+Down resize grow down 10 px or 10 ppt

  bindsym Up resize shrink up 10 px or 10 ppt
  bindsym Shift+Up resize grow up 10 px or 10 ppt

  bindsym Right resize shrink right 10 px or 10 ppt
  bindsym Shift+Right resize grow right 10 px or 10 ppt

          # back to normal: Enter or Escape
  bindsym Return mode "default"
  bindsym Escape mode "default"
  }

  bindsym $mod+r mode "resize"
  #}}}
  #{{{   Tiling / Floating / Fullscreen

  # toggle tiling / floating
  bindsym $mod+space floating toggle

  # change focus between tiling / floating windows
  #bindsym $mod+space focus mode_toggle

  # enter fullscreen mode for the focused container
  bindsym $mod+f fullscreen

  #}}}
  #{{{   Layout

  # change container layout (stacked, tabbed, default)
  bindsym $mod+e layout stacking
  bindsym $mod+w layout tabbed
  bindsym $mod+q layout default

  #}}}
  #{{{   Other

  bindsym $mod+t border normal 1
  bindsym $mod+y border pixel 1
  bindsym $mod+u border none

  #}}}
  #}}}
  #{{{ Applications
  #{{{   Shortcuts
  # start dmenu (a program launcher)
  #bindsym $mod+d exec dmenu_run
  #bindsym $mod+space exec --no-startup-id ~/workarea/helper_scripts/bin/dmenu-run.py
  #dmenu_run -l 7 -p ">>>" -fn "7x14"

  # start a terminal
  # bindsym $mod+Return exec i3-sensible-terminal

  # start gvim
  # bindsym $mod+Shift+Return exec zed

  # ipython
  #bindsym $mod+Shift+i [instance="ipython"] scratchpad show
  #for_window [instance="ipython"] move scratchpad
  #for_window [instance="ipython"] floating enable

  # alot
  #bindsym $mod+Shift+m [instance="alot"] scratchpad show
  #for_window [instance="alot"] move scratchpad
  #for_window [instance="alot"] floating enable

  # todo
  #bindsym $mod+Shift+t [instance="todo"] scratchpad show
  #for_window [instance="todo"] move scratchpad
  #for_window [instance="todo"] floating enable

  # calendar
  #bindsym $mod+Shift+y [instance="calendar"] scratchpad show
  #for_window [instance="calendar"] move scratchpad
  #for_window [instance="calendar"] floating enable

  # ncmpcpp
  #bindsym $mod+Shift+n [instance="ncmpcpp"] scratchpad show
  #for_window [instance="ncmpcpp"] move scratchpad
  #for_window [instance="ncmpcpp"] floating enable

  #mode "workspace_change_hook" {
  #  for_window [title="flow"] move workspace current
  #}

  #}}}
  #{{{   Assigns

  #assign [class="Opera"] $w3
  #assign [class="chromium-browser"] $w3
  #assign [class="Firefox"] $w3
  #assign [class="Nightly"] $w3
  #assign [class="Gvim"] $w2

  #assign [title="flow"] $w4

  #}}}
  #{{{ Other shortcuts

  # Make the currently focused window a scratchpad
  #bindsym $mod+Ctrl+BackSpace move scratchpad

  # Show the first scratchpad window
  #bindsym $mod+BackSpace scratchpad show

  # kill focused window
  bindsym $mod+Shift+Q kill

  # focus the parent container
  bindsym $mod+a focus parent

  # focus the child container
  #bindcode $mod+d focus child

  # reload the configuration file
  bindsym $mod+Shift+C reload

  # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
  bindsym $mod+Shift+R restart

  # exit i3 (logs you out of your X session)
  bindsym $mod+Shift+E exit

  # matejc's key bindings
  #bindsym Ctrl+Shift+Left focus output left
  #bindsym Ctrl+Right focus output right

  bindsym Ctrl+Mod1+Left exec --no-startup-id WSNUM=$(${variables.homeDir}/bin/i3_workspace --skip prev) && ${variables.i3-msg} workspace $WSNUM
  bindsym Ctrl+Mod1+Right exec --no-startup-id WSNUM=$(${variables.homeDir}/bin/i3_workspace --skip next) && ${variables.i3-msg} workspace $WSNUM

  bindsym Ctrl+Mod1+Shift+Left exec --no-startup-id WSNUM=$(${variables.homeDir}/bin/i3_workspace prev) && ${variables.i3-msg} move workspace $WSNUM && ${variables.i3-msg} workspace $WSNUM
  bindsym Ctrl+Mod1+Shift+Right exec --no-startup-id WSNUM=$(${variables.homeDir}/bin/i3_workspace next) && ${variables.i3-msg} move workspace $WSNUM && ${variables.i3-msg} workspace $WSNUM

  bindcode 121 exec --no-startup-id ${pkgs.alsaUtils}/bin/amixer -q set Master toggle
  bindcode 122 exec --no-startup-id ${pkgs.alsaUtils}/bin/amixer -q set Master 5%- unmute
  bindcode 123 exec --no-startup-id ${pkgs.alsaUtils}/bin/amixer -q set Master 5%+ unmute
  bindcode 198 exec --no-startup-id ${pkgs.alsaUtils}/bin/amixer -q set Capture toggle

  bindcode 233 exec --no-startup-id ${variables.homeDir}/bin/setxbacklight inc
  bindcode 232 exec --no-startup-id ${variables.homeDir}/bin/setxbacklight dec
  bindsym Ctrl+Mod1+space exec --no-startup-id "${variables.programs.launcher}"
  bindsym Ctrl+Mod1+b exec --no-startup-id "${variables.homeDir}/bin/bluetooth-connect"
  bindsym Ctrl+Mod1+a exec --no-startup-id "${pkgs.pavucontrol}/bin/pavucontrol"
  bindsym Ctrl+Mod1+0 exec --no-startup-id "${variables.homeDir}/bin/monitor"
  bindsym Ctrl+Mod1+m exec --no-startup-id "${variables.homeDir}/bin/usb-mount"
  bindsym Ctrl+Mod1+l exec --no-startup-id ${variables.lockscreen}
  bindsym Ctrl+Mod1+h exec --no-startup-id ${xfce.thunar}/bin/thunar
  bindsym Ctrl+Mod1+t exec --no-startup-id ${variables.terminal}
  bindsym Ctrl+Mod1+r exec --no-startup-id "${variables.homeDir}/bin/xrandr-change"

  bindcode 150 exec --no-startup-id "${variables.dropDownTerminal}"
  bindcode 152 exec --no-startup-id "${variables.dropDownTerminal}"
  bindsym F12 exec --no-startup-id "${variables.dropDownTerminal}"

  #bindsym F1 [title="flow"] move workspace current
  #bindsym --release Print exec /run/current-system/sw/bin/scrot --select -e 'mv $f /home/matejc/Pictures/'
  bindsym --release Print exec --no-startup-id ${variables.programs.screenshooter}
  #bindsym Ctrl+Mod1+w exec "/run/current-system/sw/bin/feh --bg-fill $(/run/current-system/sw/bin/python /home/matejc/Dropbox/matej/workarea/pys/randimage.py /home/matejc/Pictures/wallpapers/)"
  bindsym Mod1+F4 kill
  bindsym Mod1+Tab focus right
  bindsym $mod+p move workspace to output left
  bindsym $mod+n move workspace to output right
  bindsym $mod+k kill

  bindsym Ctrl+Mod1+u exec --no-startup-id "${variables.homeDir}/bin/mysync"

  # }}}
  #}}}
  #{{{ Colors

  # class border backgr. text
  #client.focused #c0c0c0 #c0c0c0 #191919
  #client.focused_inactive #292929 #292929 #c0c0c0
  #client.unfocused #292929 #292929 #c9c9c9
  #client.urgent #ff4500 #ff4500 #c0c0c0
  #client.background #000000

  # class                 border  backgr. text    indicator
  #client.focused          #859900 #859900 #fdf6e3 #2e9ef4
  #client.focused_inactive #268bd2 #268bd2 #fdf6e3 #484e50
  #client.unfocused        #333333 #93a1a1 #fdf6e3 #292d2e

  #                          border       backgr.       text   indicator
  #client.focused              $dark        $dark         $lgray $lgrey $grey
  #client.unfocused            $lgray       $lgray        $mgray $lgrey $grey
  #client.focused_inactive     $lgray       $lgray        $mgrey $lgrey $grey
  #client.urgent               $blue        $blue         $mgrey $lgrey $grey

  # colors
  set $black             #272822
  set $dark              #1E1F1C
  set $gray              #939393
  set $white             #FFFFFF
  set $pink              #F92672
  set $blue              #66D9EF
  set $green             #A6E22E
  set $orange            #FD971F
  set $yellow            #E6DB74
  set $purple            #AE81FF

  # class                 border  bg.    text    indicator child_border
  client.focused          $black  $black $green  $blue   $blue
  client.focused_inactive $black  $black $blue   $black  $black
  client.unfocused        $dark   $dark  $gray   $black  $black
  client.urgent           $pink   $pink  $white  $pink   $pink

  client.background #ff0000

  ${lib.optionalString variables.i3BarEnable ''
  bar {
    font pango:${variables.font}
    separator_symbol " • "
    #height 28
    status_command i3status

    #  statusbar colors       border      background   text
    colors {
      background          #272822DD
      statusline          $white
      separator           $gray
      focused_workspace   $blue        $black       $blue
      active_workspace    $black       $black       $yellow
      inactive_workspace  $dark        $dark        $white
      urgent_workspace    $pink        $pink        $white
    }
  }
  ''}

  #}}}
  #{{{ Autostart

  exec_always --no-startup-id ${variables.restartScript}
  exec --no-startup-id ${variables.startScript}

  # }}}

  for_window [class=".*"] title_format " <b>%title</b>"
  for_window [class=".*" con_id="__focused__"] border pixel 1

  #for_window [title="^ScratchTerm.*"] border pixel 1
  #for_window [con_mark="I3WM_SCRATCHPAD"] exec "${variables.i3-msg} resize set $(${variables.homeDir}/bin/window-size width 90) px $(${variables.homeDir}/bin/window-size height 90) px, move position center", move scratchpad, border pixel 1, sticky enable, focus
  '';
} {
  target = "${variables.homeDir}/bin/i3wm-dropdown";
  source = pkgs.writeScript "i3wm-dropdown.sh" ''
    #!${pkgs.stdenv.shell}

    ${pkgs.xdotool}/bin/xdotool search --name '^ScratchTerm.*' &>/dev/null
    if [ $? -gt 0 ]
    then
      TMUX_SESSION_NAME='ScratchTerm' ${variables.terminal}
    else
      ${variables.i3-msg} '[con_mark="I3WM_SCRATCHPAD"] scratchpad show'
    fi
  '';
} {
  target = "${variables.homeDir}/bin/termite-dropdown";
  source = pkgs.writeScript "termite-dropdown.sh" ''
    #!${pkgs.stdenv.shell}
    set -x
    if [[ "$(${variables.homeDir}/bin/i3_query name ScratchTerm)" = "null" ]]
    then
      ${pkgs.termite}/bin/termite --title=ScratchTerm "$@"
      sleep 0.2
      ${variables.i3-msg} "[title="^ScratchTerm.*"] move scratchpad, border pixel 1, sticky enable"
      sleep 0.1
      ${variables.i3-msg} "[title="^ScratchTerm.*"] $(${variables.homeDir}/bin/sway-window-center 95 90)"
    else
      ${variables.i3-msg} '[title="^ScratchTerm.*"] scratchpad show'
    fi
  '';
} {
  target = "${variables.homeDir}/bin/scratchterm";
  source = pkgs.writeScript "scratchterm.sh" ''
    #!${pkgs.stdenv.shell}
    set -x
    if [[ "$(${variables.homeDir}/bin/i3_query name ScratchTerm)" = "null" ]]
    then
      "$1" --title=ScratchTerm "''${@:2}" &
      sleep 0.2
      ${variables.i3-msg} "[title="^ScratchTerm.*"] move scratchpad, border pixel 1, sticky enable"
      sleep 0.1
      ${variables.i3-msg} "[title="^ScratchTerm.*"] $(${variables.homeDir}/bin/i3-window-center 95 90)"
    else
      ${variables.i3-msg} '[title="^ScratchTerm.*"] scratchpad show'
    fi
  '';
} {
  target = "${variables.homeDir}/bin/xfce-terminal-dropdown";
  source = pkgs.writeScript "xfce-terminal-dropdown.sh" ''
    #!${pkgs.stdenv.shell}
    set -x
    ${variables.i3-msg} '[con_mark="I3WM_SCRATCHPAD"] focus, scratchpad show' | ${pkgs.gnugrep}/bin/grep 'false'
    if [[ "$?" = "0" ]]
    then
      ${xfce.xfce4-terminal}/bin/xfce4-terminal --title=ScratchTerm "$@" &
      sleep 0.1
      ${variables.i3-msg} "[title="^ScratchTerm.*"] mark I3WM_SCRATCHPAD, resize set $(${variables.homeDir}/bin/window-size width 90) px $(${variables.homeDir}/bin/window-size height 90) px"
    else
      ${variables.i3-msg} '[con_mark="I3WM_SCRATCHPAD"] scratchpad show'
    fi
  '';
} {
  target = "${variables.homeDir}/bin/window-size";
  source = pkgs.writeScript "window-size.sh" ''
    #!${pkgs.stdenv.shell}

    IFS=" " read width height <<< "$(${pkgs.xdotool}/bin/xdotool getdisplaygeometry)"

    case "$1" in
      width) echo "$width * $2/100" | ${pkgs.bc}/bin/bc
      ;;
      height) echo "$height * $2/100" | ${pkgs.bc}/bin/bc
      ;;
    esac
  '';
} {
  target = "${variables.homeDir}/bin/i3-window-center";
  source = pkgs.writeScript "i3-window-center.sh" ''
    #!${pkgs.stdenv.shell}

    wp="$1"
    hp="$2"

    IFS=" " read width height <<< "$(${pkgs.xdotool}/bin/xdotool getdisplaygeometry)"

    w="$(($width * $wp/100))"
    h="$(($height * $hp/100))"

    echo "resize set $w px $h px, move position $(( ($width - $w) / 2 )) px $(( ($height - $h) / 2 )) px"
  '';
} {
  target = "${variables.homeDir}/bin/sway-window-center";
  source = pkgs.writeScript "sway-window-center.sh" ''
    #!${pkgs.stdenv.shell}

    wp="$1"
    hp="$2"

    width="$(${variables.i3-msg} -t get_outputs | ${pkgs.jq}/bin/jq '.[0].rect.width')"
    height="$(${variables.i3-msg} -t get_outputs | ${pkgs.jq}/bin/jq '.[0].rect.height')"

    w="$(($width * $wp/100))"
    h="$(($height * $hp/100))"

    echo "resize set $w px $h px, move position $(( ($width - $w) / 2 )) px $(( ($height - $h) / 2 )) px"
  '';
}]
