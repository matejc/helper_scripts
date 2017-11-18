{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/polybar/config";
  source = pkgs.writeText "polybar.config" ''
  [colors]
  background = #e0202020
  background-alt = #444
  foreground = #dfdfdf
  foreground-alt = #555
  primary = #ffb52a
  secondary = #e60053
  alert = #bd2c40

  [bar/my]
  monitor = ${variables.monitorPrimary}
  width = 100%
  height = 27
  radius = 0.0
  fixed-center = false
  bottom = true

  background = ''${colors.background}
  foreground = ''${colors.foreground}

  line-size = 3
  line-color = #f00

  border-size = 0
  border-color = #00000000

  padding-left = 0
  padding-right = 2

  module-margin-left = 1
  module-margin-right = 2

  font-0 = "RobotoMonoNerdFont:style=bold:size=10"
  font-1 = "DejaVuSansMono:style=bold:size=10"
  font-2 = "FontAwesome:size=10"

  modules-left = i3
  modules-center = xwindow
  modules-right = filesystem xbacklight volume xkeyboard memory cpu ${pkgs.lib.concatImapStringsSep " " (i: v: ''wlan${toString i}'') variables.wirelessInterfaces} ${pkgs.lib.concatImapStringsSep " " (i: v: ''eth${toString i}'') variables.ethernetInterfaces} ${pkgs.lib.concatImapStringsSep " " (i: v: ''battery${toString i}'') variables.batteries} temperature date

  tray-position = right
  tray-padding = 2
  tray-background = ''${colors.background}

  [module/xwindow]
  type = internal/xwindow
  label = %title:0:50:...%

  [module/xkeyboard]
  type = internal/xkeyboard
  format = <label-indicator>

  ; List of indicators to ignore
  blacklist-0 = num lock
  blacklist-1 = scroll lock

  format-prefix-foreground = ''${colors.foreground-alt}
  format-prefix-underline = ''${colors.secondary}

  label-indicator-padding = 2
  label-indicator-margin = 1
  label-indicator-background = ''${colors.secondary}
  label-indicator-underline = ''${colors.secondary}

  [module/filesystem]
  type = internal/fs
  interval = 25

  ${lib.concatImapStringsSep "\n" (index: mount: ''
  mount-${toString index} = ${mount}
  '') variables.mounts}

  label-mounted = %{F#0a81f5}%mountpoint%%{F-}: %percentage_used%%
  label-unmounted = %mountpoint% not mounted
  label-unmounted-foreground = ''${colors.foreground-alt}

  [module/bspwm]
  type = internal/bspwm

  label-focused = %index%
  label-focused-background = ''${colors.background-alt}
  label-focused-underline= ''${colors.primary}
  label-focused-padding = 2

  label-occupied = %index%
  label-occupied-padding = 2

  label-urgent = %index%!
  label-urgent-background = ''${colors.alert}
  label-urgent-padding = 2

  label-empty = %index%
  label-empty-foreground = ''${colors.foreground-alt}
  label-empty-padding = 2

  [module/i3]
  type = internal/i3
  format = <label-state> <label-mode>
  index-sort = true
  wrapping-scroll = false

  ; Only show workspaces on the same output as the bar
  ;pin-workspaces = true

  label-mode-padding = 2
  label-mode-foreground = #000
  label-mode-background = ''${colors.primary}

  ; focused = Active workspace on focused monitor
  label-focused = %index%
  label-focused-background = ''${module/bspwm.label-focused-background}
  label-focused-underline = ''${module/bspwm.label-focused-underline}
  label-focused-padding = ''${module/bspwm.label-focused-padding}

  ; unfocused = Inactive workspace on any monitor
  label-unfocused = %index%
  label-unfocused-padding = ''${module/bspwm.label-occupied-padding}

  ; visible = Active workspace on unfocused monitor
  label-visible = %index%
  label-visible-background = ''${self.label-focused-background}
  ;label-visible-underline = ''${self.label-focused-underline}
  label-visible-padding = ''${self.label-focused-padding}

  ; urgent = Workspace with urgency hint set
  label-urgent = %index%
  label-urgent-background = ''${module/bspwm.label-urgent-background}
  label-urgent-padding = ''${module/bspwm.label-urgent-padding}

  [module/xbacklight]
  type = internal/xbacklight

  format = <label> <bar>
  label = 

  bar-width = 10
  bar-indicator = |
  bar-indicator-foreground = #ff
  bar-indicator-font = 2
  bar-fill = ─
  bar-fill-font = 2
  bar-fill-foreground = #9f78e1
  bar-empty = ─
  bar-empty-font = 2
  bar-empty-foreground = ''${colors.foreground-alt}

  [module/backlight-acpi]
  inherit = module/xbacklight
  type = internal/backlight
  card = intel_backlight

  [module/cpu]
  type = internal/cpu
  interval = 2
  format-prefix = " "
  format-prefix-foreground = ''${colors.foreground-alt}
  format-underline = #f90000
  label = %percentage%%

  [module/memory]
  type = internal/memory
  interval = 2
  format-prefix = " "
  format-prefix-foreground = ''${colors.foreground-alt}
  format-underline = #2bdfac
  label = %percentage_used%%

  ${lib.concatImapStringsSep "\n" (index: interface: ''
  [module/wlan${toString index}]
  type = internal/network
  interface = ${interface}
  interval = 3.0

  format-connected = <ramp-signal> <label-connected>
  format-connected-underline = #1b926c
  label-connected = %essid%

  format-disconnected = <label-disconnected>
  ;format-disconnected-underline = ''${self.format-connected-underline}
  label-disconnected = %ifname% disconnected
  label-disconnected-foreground = ''${colors.foreground-alt}

  ramp-signal-0 = 
  ramp-signal-1 = 
  ramp-signal-2 = 
  ramp-signal-0-foreground = #ff0000
  ramp-signal-1-foreground = #ffa500
  ramp-signal-2-foreground = #00ff00
  '') variables.wirelessInterfaces}

  ${lib.concatImapStringsSep "\n" (index: interface: ''
  [module/eth${toString index}]
  type = internal/network
  interface = ${interface}
  interval = 3.0

  format-connected-underline = #55aa55
  label-connected = %local_ip%

  format-disconnected =
  ;format-disconnected = <label-disconnected>
  ;format-disconnected-underline = ''${self.format-connected-underline}
  ;label-disconnected = %ifname% disconnected
  ;label-disconnected-foreground = ''${colors.foreground-alt}
  '') variables.ethernetInterfaces}

  [module/date]
  type = internal/date
  interval = 5

  date = "%a, %d.%m.%Y"

  time = %H:%M

  format-underline = #0a6cf5

  label = %time% %date%

  [module/volume]
  type = internal/volume

  master-mixer = Master

  format-volume = <label-volume> <bar-volume>
  label-volume = 
  label-volume-foreground = ''${root.foreground}

  format-muted-foreground = ''${colors.foreground-alt}
  label-muted = 

  bar-volume-width = 10
  bar-volume-foreground-0 = #55aa55
  bar-volume-foreground-1 = #55aa55
  bar-volume-foreground-2 = #55aa55
  bar-volume-foreground-3 = #55aa55
  bar-volume-foreground-4 = #55aa55
  bar-volume-foreground-5 = #f5a70a
  bar-volume-foreground-6 = #ff5555
  bar-volume-gradient = false
  bar-volume-indicator = |
  bar-volume-indicator-font = 2
  bar-volume-fill = ─
  bar-volume-fill-font = 2
  bar-volume-empty = ─
  bar-volume-empty-font = 2
  bar-volume-empty-foreground = ''${colors.foreground-alt}

  ${lib.concatImapStringsSep "\n" (index: battery: ''
  [module/battery${toString index}]
  type = internal/battery
  battery = BAT${battery}
  adapter = ADP1
  full-at = 96

  format-charging = <animation-charging> <label-charging>
  format-charging-underline = #ffb52a

  format-discharging = <ramp-capacity> <label-discharging>
  format-discharging-underline = ''${self.format-charging-underline}

  format-full-prefix = "  "
  format-full-prefix-foreground = #00ff00
  format-full-underline = ''${self.format-charging-underline}

  ramp-capacity-0 = " "
  ramp-capacity-1 = " "
  ramp-capacity-2 = " "
  ramp-capacity-3 = " "
  ramp-capacity-4 = " "
  ramp-capacity-foreground = #ffa500

  animation-charging-0 = " "
  animation-charging-1 = " "
  animation-charging-2 = " "
  animation-charging-3 = " "
  animation-charging-4 = " "
  animation-charging-foreground = #00ff00
  animation-charging-framerate = 750
  '') variables.batteries}

  [module/temperature]
  type = internal/temperature
  thermal-zone = 0
  warn-temperature = 70

  format = <ramp> <label>
  format-underline = #f50a4d
  format-warn = <ramp> <label-warn>
  format-warn-underline = ''${self.format-underline}

  label = %temperature%
  label-warn = %temperature%
  label-warn-foreground = ''${colors.secondary}

  ramp-0 = 
  ramp-1 = 
  ramp-2 = 
  ramp-3 = 
  ramp-4 = 
  ramp-0-foreground = #00ff00
  ramp-1-foreground = #00ff00
  ramp-2-foreground = #ffa500
  ramp-3-foreground = #ffa500
  ramp-4-foreground = #ff0000
  ramp-foreground = ''${colors.foreground-alt}

  [settings]
  screenchange-reload = true
  ;compositing-background = xor
  ;compositing-background = screen
  ;compositing-foreground = source
  ;compositing-border = over

  [global/wm]
  margin-top = 5
  margin-bottom = 5
  '';
}
