{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.i3/config";
  source = pkgs.writeText "i3config" ''
  # Please see http://i3wm.org/docs/userguide.html for a complete reference!

  #{{{ Main

  set $mod Mod4

  # monitors
  # LVDS1
  set $mon_lap ${variables.monitorPrimary}
  set $mon_ext ${variables.monitorTwo}
  set $mon_ext1 ${variables.monitorThree}
  set $snd_card ${variables.soundCard}

  # colors
  set $dark     #262a33
  set $grey     #666a73
  set $dblue    #2264a2
  set $blue     #5294e2
  set $lgrey    #3e424d
  set $white    #ffffff
  set $mgrey    #b9c2cd


  # > horizontal | vertical | auto
  default_orientation horizontal

  # > default | stacking | tabbed
  workspace_layout default

  # > normal | 1pixel | none
  new_window normal

  # Use Mouse+$mod to drag floating windows to their wanted position
  floating_modifier $mod

  #}}}
  #{{{ Modes
  #{{{   Monitor mode
  mode "monitor_select" {

    # only one
    bindsym 1 exec --no-startup-id xrandr --output $mon_ext --off --output $mon_ext1 --off --output $mon_lap --auto; mode "default"
    bindsym 2 exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext --auto --right-of $mon_lap; mode "default"
    bindsym 3 exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --right-of $mon_lap; mode "default"

    # left and right
    bindsym l exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --left-of $mon_lap ; mode "default"
    bindsym r exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --right-of $mon_lap ; mode "default"

    # up and down
    bindsym u exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --above $mon_lap ; mode "default"
    bindsym d exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --below $mon_lap ; mode "default"

    # clone
    bindsym c exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext --auto --same-as $mon_lap ; mode "default"

    # presentation
    bindsym p exec --no-startup-id xrandr --output $mon_lap --auto --output $mon_ext1 --auto --left-of $mon_lap ; mode "default"

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
  font ${variables.font}


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

  #workspace "$w1" output $mon_ext
  #workspace "$w2" output $mon_ext
  #workspace "$w3" output $mon_ext
  #workspace "$w4" output $mon_ext
  #workspace "$w5" output $mon_lap
  #workspace "$w6" output $mon_lap
  #workspace "$w7" output $mon_lap
  #workspace "$w8" output $mon_lap
  #workspace "$w9" output $mon_ext
  #workspace "$w10" output $mon_ext

  # switch to workspace
  #bindsym $mod+1 workspace $w1
  #bindsym $mod+2 workspace $w2
  #bindsym $mod+3 workspace $w3
  #bindsym $mod+4 workspace $w4
  #bindsym $mod+5 workspace $w5
  #bindsym $mod+6 workspace $w6
  #bindsym $mod+7 workspace $w7
  #bindsym $mod+8 workspace $w8
  #bindsym $mod+9 workspace $w9
  #bindsym $mod+0 workspace $w10

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

  bindsym $mod+m mode "monitor_select"

  #}}}
  #{{{ Windows
  #{{{   Change focus

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

  bindsym $mod+t border normal
  bindsym $mod+y border 1pixel
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
  bindsym $mod+Return exec i3-sensible-terminal

  # start gvim
  bindsym $mod+Shift+Return exec zed

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
  assign [class="chromium-browser"] $w3
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
  bindsym Ctrl+Mod1+Left exec WSNUM=$(~/workarea/helper_scripts/bin/i3_workspace.py left) && i3-msg workspace $WSNUM
  bindsym Ctrl+Mod1+Right exec WSNUM=$(~/workarea/helper_scripts/bin/i3_workspace.py right) && i3-msg workspace $WSNUM
  bindsym Ctrl+Mod1+Shift+Left exec WSNUM=$(~/workarea/helper_scripts/bin/i3_workspace.py left) && i3-msg move workspace $WSNUM && i3-msg workspace $WSNUM
  bindsym Ctrl+Mod1+Shift+Right exec WSNUM=$(~/workarea/helper_scripts/bin/i3_workspace.py right) && i3-msg move workspace $WSNUM && i3-msg workspace $WSNUM
  bindcode 179 exec /run/current-system/sw/bin/vlc /home/matejc/Dropbox/matej/workarea/radios/favorites.m3u8
  bindcode 121 exec ~/workarea/helper_scripts/bin/volume $snd_card toggle
  bindcode 122 exec ~/workarea/helper_scripts/bin/volume $snd_card decrease
  bindcode 123 exec ~/workarea/helper_scripts/bin/volume $snd_card increase
  bindcode 233 exec /run/current-system/sw/bin/xbacklight -inc 5
  bindcode 232 exec /run/current-system/sw/bin/xbacklight -dec 5
  #bindsym $mod+0 exec /run/current-system/sw/bin/xrandr --output LVDS1 --brightness 1.0
  #bindsym $mod+9 exec /run/current-system/sw/bin/xrandr --output LVDS1 --brightness 0.9
  #bindsym $mod+8 exec /run/current-system/sw/bin/xrandr --output LVDS1 --brightness 0.8
  #bindsym $mod+7 exec /run/current-system/sw/bin/xrandr --output LVDS1 --brightness 0.7
  #bindsym $mod+6 exec /run/current-system/sw/bin/xrandr --output LVDS1 --brightness 0.6
  #bindsym $mod+5 exec /run/current-system/sw/bin/xrandr --output LVDS1 --brightness 0.5
  #bindsym Ctrl+Mod1+space exec ~/workarea/helper_scripts/bin/dmenu-run.py
  bindsym Ctrl+Mod1+space exec /run/current-system/sw/bin/rofi -show run
  bindsym Ctrl+Mod1+s exec zsh -l /run/current-system/sw/bin/sublime
  bindsym Ctrl+Mod1+2 exec xrandr --output LVDS1 --primary --auto --output VGA1 --auto --right-of LVDS1
  bindsym Ctrl+Mod1+1 exec xrandr --output VGA1 --off --output LVDS1 --auto
  #bindsym Ctrl+Mod1+c exec /home/matejc/workarea/connman_dmenu/connman_dmenu
  bindsym Ctrl+Mod1+l exec ~/bin/lockscreen
  bindsym Ctrl+Mod1+h exec /run/current-system/sw/bin/thunar
  #bindsym Ctrl+Mod1+z exec /run/current-system/sw/bin/zed
  bindsym Ctrl+Mod1+t exec /run/current-system/sw/bin/xfce4-terminal
  bindsym F12 exec /run/current-system/sw/bin/xfce4-terminal --drop-down
  #bindsym F1 [title="flow"] move workspace current
  bindsym F2 exec /run/current-system/sw/bin/rofi
  #bindsym --release Print exec /run/current-system/sw/bin/scrot --select -e 'mv $f /home/matejc/Pictures/'
  bindsym --release Print exec /run/current-system/sw/bin/xfce4-screenshooter --region --save /home/matejc/Pictures
  #bindsym Ctrl+Mod1+w exec "/run/current-system/sw/bin/feh --bg-fill $(/run/current-system/sw/bin/python /home/matejc/Dropbox/matej/workarea/pys/randimage.py /home/matejc/Pictures/wallpapers/)"
  bindsym Ctrl+Mod1+w exec /run/current-system/sw/bin/rofi -show window
  bindsym F1 exec /run/current-system/sw/bin/rofi -show window
  bindsym Mod1+F4 kill
  bindsym Mod1+Tab focus right
  bindsym $mod+p move workspace to output left
  bindsym $mod+n move workspace to output right
  bindsym $mod+k kill

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
  client.focused              $dark        $dark         $white $lgrey
  client.unfocused            $dark        $dark         $grey $lgrey
  client.focused_inactive     $dark        $dark         $mgrey $lgrey
  client.urgent               $dark        $blue         $mgrey $lgrey



  #}}}
  #{{{ i3bar
  # Start i3bar to display a workspace bar (plus the system information i3status
  # finds out, if available)
  bar {
      status_command i3status
      position bottom
      #tray_output $mon_ext
      #tray_output $mon_lap
  #{{{ i3bar colors
      colors {
  #        background #0e0e0e
  #        statusline #c0c0c0
  #        focused_workspace #ffffff #0e3e9e
  #        inactive_workspace #a0a0a0 #0e0e0e
  #        urgent_workspace #000033 #ff4500
  #        active_workspace #696969 #0e0e0e

          # solarized
  #        background #073642
  #        statusline #eee8d5
  #        focused_workspace #cb4b16 #cb4b16 #eee8d5
  #        active_workspace #cb4b16 #cb4b16 #eee8d5
  #        inactive_workspace #b58900 #b58900 #eee8d5

            background          $dark
            statusline          $white
            separator           $dblue
                        #      border      background   text
            focused_workspace   $dblue       $dark        $white
            active_workspace    $dark       $dark        $mgrey
            inactive_workspace  $dark       $dark        $mgrey
            urgent_workspace    $dark       $blue        $white



      }
  #}}}
  }
  #}}}
  #{{{ Autostart

  exec --no-startup-id ${variables.startScript}
  exec --no-startup-id "~/bin/autolock"
  #exec --no-startup-id /bin/sh -c "sleep 1; /run/current-system/sw/bin/xrandr --output $mon_lap --primary --auto --output $mon_ext --off --output $mon_ext1 --off"
  #exec --no-startup-id /bin/sh -c "/run/current-system/sw/bin/feh --bg-fill /home/matejc/Pictures/simplave_by_voytecghost-d518thv.jpg; /run/current-system/sw/bin/i3-msg restart"
  exec --no-startup-id /bin/sh -c "/run/current-system/sw/bin/feh --bg-fill ${variables.wallpaper}; /run/current-system/sw/bin/i3-msg restart"
  exec --no-startup-id /bin/sh -c "/run/current-system/sw/bin/dunst" &
  exec --no-startup-id cmst --minimized

  # }}}
  '';
}
