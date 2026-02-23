{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  niriSidebarConfigFile = pkgs.writeText "niri-sidebar.toml" ''
    [geometry]
    # Width of the sidebar in pixels
    width = 400
    # Height of the sidebar windows
    height = 300
    # Gap between windows in the stack
    gap = 10

    [margins]
    # Margins are default to 0 if left out
    # Space from the top of the screen
    top = 10
    # Space from the right edge of the screen
    right = 10
    # Space from the left edge of the screen
    left = 10
    # Space from the bottom of the screen
    bottom = 50

    [interaction]
    # Where to put the sidebar, can be "left", "right", "top" or "bottom"
    # Defaults to "right"
    position = "right"
    # Width of windows when sidebar is hidden in pixels
    peek = 10
    # Width of window when sidebar is hidden but window is focused in pixels
    # set this equal to peek to disable this feature
    # set this equal to sidebar_width + offset_right to make focused windows "unhide"
    # Optional and defaults to peek if ommitted
    focus_peek = 50
    # Whether the sidebar should follow if you switch workspaces
    sticky = false

    # Example window rule
    # all fields are optional if not given a default from other configs will be used
    # [[window_rule]]
    # app_id = "firefox"  # if not set will match all app_id's
    # title = "^Picture-in-Picture$"  # if not set will match no matter the title
    # width = 700
    # height = 400
    # focus_peek = 710
    # peek = 10
    # auto_add = true  # defaults to false
  '';
in
{
  config = lib.mkMerge [
    {
      nixpkgs.overlays = [
        inputs.niri.overlays.niri
        (final: prev: {
          niri-sidebar = prev.callPackage ../nixes/niri-sidebar.nix { };
          annotate-screenshot = prev.callPackage ../nixes/annotate-screenshot {
            niri = config.variables.graphical.package;
          };
          noctalia-shell = inputs.noctalia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;
          quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
        })
      ];

      xdg.portal = {
        enable = true;
        config = {
          common.default = "*";
          niri = {
            default = ["gnome" "gtk"];
            "org.freedesktop.impl.portal.Access" = ["gtk"];
            "org.freedesktop.impl.portal.Notification" = ["gtk"];
            "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
            "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
            "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          };
        };
        extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome ];
        xdgOpenUsePortal = true;
      };

      home.file.".config/niri-sidebar/config.toml".source = niriSidebarConfigFile;

      home.packages = with pkgs; [
        config.variables.graphical.package
        noctalia-shell
        quickshell
        bluez
        brightnessctl
        cava
        cliphist
        coreutils
        ddcutil
        file
        findutils
        gpu-screen-recorder
        libnotify
        matugen
        networkmanager
        wl-clipboard
        wlsunset
        app2unit
      ];

      programs.niri.config =
        let
          noctalia-shell = "${pkgs.noctalia-shell}/bin/noctalia-shell";
        in
        ''
          // This config is in the KDL format: https://kdl.dev
          // "/-" comments out the following node.

          input {
              keyboard {
                  xkb {
                      // You can set rules, model, layout, variant and options.
                      // For more information, see xkeyboard-config(7).

                      // For example:
                      // layout "us,ru"
                      // options "grp:win_space_toggle,compose:ralt,ctrl:nocaps"

                      options "caps:escape_shifted_capslock"
                  }

                  // You can set the keyboard repeat parameters. The defaults match wlroots and sway.
                  // Delay is in milliseconds before the repeat starts. Rate is in characters per second.
                  // repeat-delay 600
                  // repeat-rate 25

                  // Niri can remember the keyboard layout globally (the default) or per-window.
                  // - "global" - layout change is global for all windows.
                  // - "window" - layout is tracked for each window individually.
                  // track-layout "global"
              }

              // Next sections include libinput settings.
              // Omitting settings disables them, or leaves them at their default values.
              touchpad {
                  // tap
                  // dwt
                  // natural-scroll
                  accel-speed 0.2
                  // accel-profile "flat"
                  // tap-button-map "left-middle-right"
              }

              mouse {
                  // natural-scroll
                  accel-speed 0.2
                  accel-profile "flat"
              }
              focus-follows-mouse max-scroll-amount="0%"

              tablet {
                  // Set the name of the output (see below) which the tablet will map to.
                  // If this is unset or the output doesn't exist, the tablet maps to one of the
                  // existing outputs.
                  // map-to-output "eDP-1"
              }

              // By default, niri will take over the power button to make it sleep
              // instead of power off.
              // Uncomment this if you would like to configure the power button elsewhere
              // (i.e. logind.conf).
              // disable-power-key-handling

              trackpoint {
                  accel-speed -0.35
                  accel-profile "adaptive"
              }
          }

          // You can configure outputs by their name, which you can find
          // by running `niri msg outputs` while inside a niri instance.
          // The built-in laptop monitor is usually called "eDP-1".
          // Remember to uncommend the node by removing "/-"!
          /-output "eDP-1" {
              // Uncomment this line to disable this output.
              // off

              // Scale is a floating-point number, but at the moment only integer values work.
              scale 2.0

              // Resolution and, optionally, refresh rate of the output.
              // The format is "<width>x<height>" or "<width>x<height>@<refresh rate>".
              // If the refresh rate is omitted, niri will pick the highest refresh rate
              // for the resolution.
              // If the mode is omitted altogether or is invalid, niri will pick one automatically.
              // Run `niri msg outputs` while inside a niri instance to list all outputs and their modes.
              mode "1920x1080@144"

              // Position of the output in the global coordinate space.
              // This affects directional monitor actions like "focus-monitor-left", and cursor movement.
              // The cursor can only move between directly adjacent outputs.
              // Output scale has to be taken into account for positioning:
              // outputs are sized in logical, or scaled, pixels.
              // For example, a 3840×2160 output with scale 2.0 will have a logical size of 1920×1080,
              // so to put another output directly adjacent to it on the right, set its x to 1920.
              // It the position is unset or results in an overlap, the output is instead placed
              // automatically.
              position x=1280 y=0
          }

          ${lib.concatMapStringsSep "\n" (o: ''
            output "${o.output}" {
              scale ${toString o.scale}
              ${if o.mode == null then "" else "mode \"${o.mode}\""}
              ${
                let
                  pos = lib.splitString "," o.position;
                  x = builtins.elemAt pos 0;
                  y = builtins.elemAt pos 1;
                in
                ''
                  position x=${x} y=${y}
                ''
              }
            }
          '') config.variables.outputs}

          workspace "first" {
            open-on-output "${(builtins.head config.variables.outputs).output}"
          }
          window-rule {
            match app-id="org.keepassxc.KeePassXC"
            match app-id="Logseq"
            open-on-workspace "first"
          }

          workspace "second" {
            open-on-output "${(builtins.head config.variables.outputs).output}"
          }
          window-rule {
            match app-id="chromium-browser"
            match app-id="thorium-browser"
            match app-id="firefox"
            match app-id="Slack"
            match app-id="zen"
            open-on-workspace "second"
          }

          window-rule {
              match app-id="org.keepassxc.KeePassXC"
              match app-id="Logseq"
              match app-id="Slack"
              block-out-from "screencast"
          }

          window-rule {
              draw-border-with-background true
              geometry-corner-radius 3
          }

          layout {
              // You can change how the focus ring looks.
              focus-ring {
                  // Uncomment this line to disable the focus ring.
                  // off

                  // How many logical pixels the ring extends out from the windows.
                  width 3

                  // Color of the ring on the active monitor: red, green, blue, alpha.
                  // active-color 127 200 255 255

                  // Color of the ring on inactive monitors: red, green, blue, alpha.
                  // inactive-color 80 80 80 255

                  active-color 255 255 255 100
                  inactive-color 80 80 80 100
              }

              // You can also add a border. It's similar to the focus ring, but always visible.
              border {
                  // The settings are the same as for the focus ring.
                  // If you enable the border, you probably want to disable the focus ring.
                  off

                  width 1
                  active-color 127 200 255 255
                  inactive-color 80 80 80 255
              }

              // You can customize the widths that "switch-preset-column-width" (Mod+R) toggles between.
              preset-column-widths {
                  // Proportion sets the width as a fraction of the output width, taking gaps into account.
                  // For example, you can perfectly fit four windows sized "proportion 0.25" on an output.
                  // The default preset widths are 1/3, 1/2 and 2/3 of the output.
                  proportion 0.5
                  proportion 1.0

                  // Fixed sets the width in logical pixels exactly.
                  // fixed 1920
              }

              // You can change the default width of the new windows.
              default-column-width { proportion 1.0; }
              // If you leave the brackets empty, the windows themselves will decide their initial width.
              // default-column-width {}

              // Set gaps around windows in logical pixels.
              gaps 7

              // Struts shrink the area occupied by windows, similarly to layer-shell panels.
              // You can think of them as a kind of outer gaps. They are set in logical pixels.
              // Left and right struts will cause the next window to the side to always be visible.
              // Top and bottom struts will simply add outer gaps in addition to the area occupied by
              // layer-shell panels and regular gaps.
              struts {
                  left 18
                  right 18
                  top 0
                  bottom 0
              }

              // When to center a column when changing focus, options are:
              // - "never", default behavior, focusing an off-screen column will keep at the left
              //   or right edge of the screen.
              // - "on-overflow", focusing a column will center it if it doesn't fit
              //   together with the previously focused column.
              // - "always", the focused column will always be centered.
              // center-focused-column "on-overflow"
          }

          animations {
            slowdown 0.75
          }

          // Add lines like this to spawn processes at startup.
          // Note that running niri as a session supports xdg-desktop-autostart,
          // which may be more convenient to use.
          spawn-at-startup "${pkgs.stdenv.shell}" "-c" "${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_RUNTIME_DIR"
          spawn-at-startup "${pkgs.stdenv.shell}" "-c" "${pkgs.dbus}/bin/dbus-update-activation-environment WAYLAND_DISPLAY DISPLAY XDG_RUNTIME_DIR"
          spawn-at-startup "${pkgs.configure-gtk}/bin/configure-gtk"
          spawn-at-startup "${pkgs.stdenv.shell}" "-c" "${config.variables.profileDir}/bin/service-group-always restart"

          ${lib.concatMapStringsSep "\n" (i: ''
            spawn-at-startup "${pkgs.stdenv.shell}" "-c" "${i}"
          '') (pkgs.lib.optionals (config.variables ? startup) config.variables.startup)}

          cursor {
              // Change the theme and size of the cursor as well as set the
              // `XCURSOR_THEME` and `XCURSOR_SIZE` env variables.
              // xcursor-theme "default"
              // xcursor-size 24
          }

          // Uncomment this line to ask the clients to omit their client-side decorations if possible.
          // If the client will specifically ask for CSD, the request will be honored.
          // Additionally, clients will be informed that they are tiled, removing some rounded corners.
          prefer-no-csd

          // You can change the path where screenshots are saved.
          // A ~ at the front will be expanded to the home directory.
          // The path is formatted with strftime(3) to give you the screenshot date and time.
          screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

          // You can also set this to null to disable saving screenshots to disk.
          // screenshot-path null

          // Settings for the "Important Hotkeys" overlay.
          hotkey-overlay {
              // Uncomment this line if you don't want to see the hotkey help at niri startup.
              skip-at-startup
          }

          gestures {
              hot-corners {
                  off
              }
          }

          recent-windows {
              // off
              previews {
                  max-height 480
                  max-scale 0.5
              }

              highlight {
                  corner-radius 10
              }

              binds {
                  Super+Tab         { next-window scope="output"; }
                  Super+Shift+Tab   { previous-window scope="output"; }
              }
          }

          xwayland-satellite {
              path "${pkgs.xwayland-satellite-unstable}/bin/xwayland-satellite"
          }

          binds {
              // Keys consist of modifiers separated by + signs, followed by an XKB key name
              // in the end. To find an XKB name for a particular key, you may use a program
              // like wev.
              //
              // "Mod" is a special modifier equal to Super when running on a TTY, and to Alt
              // when running as a winit window.

              // Mod-Shift-/, which is usually the same as Mod-?,
              // shows a list of important hotkeys.
              Super+Shift+Slash { show-hotkey-overlay; }

              // Suggested binds for running programs: terminal, app launcher, screen locker.
              Ctrl+Alt+T { spawn "${config.variables.programs.terminal}"; }
              Ctrl+Alt+H { spawn "${config.variables.programs.filemanager}"; }
              Super+Space { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call launcher toggle"; }
              Ctrl+Alt+L { spawn "${config.variables.lockscreen}"; }
              Super+L { spawn "${config.variables.lockscreen}"; }
              Ctrl+Alt+Delete { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call sessionMenu toggle"; }
              Ctrl+Alt+N { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call notifications toggleHistory"; }

              XF86AudioRaiseVolume { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call volume increase"; }
              XF86AudioLowerVolume { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call volume decrease"; }
              XF86AudioMute allow-when-locked=true { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call volume muteOutput"; }
              Shift+XF86AudioRaiseVolume { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+"; }
              Shift+XF86AudioLowerVolume { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"; }
              Shift+XF86AudioMute allow-when-locked=true { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call volume muteInput"; }
              XF86AudioMicMute allow-when-locked=true { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call volume muteInput"; }
              XF86MonBrightnessUp { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call brightness increase"; }
              XF86MonBrightnessDown { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call brightness decrease"; }
              XF86AudioPlay { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.playerctl}/bin/playerctl play-pause"; }
              XF86AudioNext { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.playerctl}/bin/playerctl next"; }
              XF86AudioPrev { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.playerctl}/bin/playerctl previous"; }

              Super+K { close-window; }
              Super+Shift+K { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.coreutils}/bin/kill -9 $(niri msg -j focused-window | jq -r \".pid\")"; }

              Super+Left  { focus-column-left; }
              Super+Down  { focus-window-down; }
              Super+Up    { focus-window-up; }
              Super+Right { focus-column-right; }

              Ctrl+Alt+Left  { focus-column-left; }
              Ctrl+Alt+Right { focus-column-right; }
              Ctrl+Alt+Shift+Left  { move-column-left; }
              Ctrl+Alt+Shift+Right { move-column-right; }

              Super+Shift+Left  { move-column-left; }
              Super+Shift+Down  { move-window-down; }
              Super+Shift+Up    { move-window-up; }
              Super+Shift+Right { move-column-right; }

              // Alternative commands that move across workspaces when reaching
              // the first or last window in a column.
              // Mod+J     { focus-window-or-workspace-down; }
              // Mod+K     { focus-window-or-workspace-up; }
              // Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
              // Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }

              Super+Home { focus-column-first; }
              Super+End  { focus-column-last; }
              Super+Shift+Home { move-column-to-first; }
              Super+Shift+End  { move-column-to-last; }

              Super+Ctrl+Left  { focus-monitor-left; }
              Super+Ctrl+Down  { focus-monitor-down; }
              Super+Ctrl+Up    { focus-monitor-up; }
              Super+Ctrl+Right { focus-monitor-right; }

              Ctrl+Alt+Page_Up  { focus-monitor-left; }
              Ctrl+Alt+Page_Down { focus-monitor-right; }
              Ctrl+Shift+Alt+Page_Up  { move-window-to-monitor-left; }
              Ctrl+Shift+Alt+Page_Down { move-window-to-monitor-right; }

              Super+Shift+Ctrl+Left  { move-window-to-monitor-left; }
              Super+Shift+Ctrl+Down  { move-window-to-monitor-down; }
              Super+Shift+Ctrl+Up    { move-window-to-monitor-up; }
              Super+Shift+Ctrl+Right { move-window-to-monitor-right; }

              Ctrl+Alt+Up        { focus-workspace-up; }
              Ctrl+Alt+Down      { focus-workspace-down; }
              Ctrl+Alt+Shift+Up   { move-window-to-workspace-up; }
              Ctrl+Alt+Shift+Down { move-window-to-workspace-down; }

              Super+Comma  { consume-window-into-column; }
              Super+Period { expel-window-from-column; }

              Super+R { switch-preset-column-width; }
              Super+M { maximize-column; }
              Super+F { fullscreen-window; }

              // Finer width adjustments.
              // This command can also:
              // * set width in pixels: "1000"
              // * adjust width in pixels: "-5" or "+5"
              // * set width as a percentage of screen width: "25%"
              // * adjust width as a percentage of screen width: "-10%" or "+10%"
              // Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
              // set-column-width "100" will make the column occupy 200 physical screen pixels.
              Super+Minus { set-column-width "-25%"; }
              Super+Equal { set-column-width "+25%"; }

              // Finer height adjustments when in column with other windows.
              Super+Ctrl+Minus { set-window-height "-25%"; }
              Super+Ctrl+Equal { set-window-height "+25%"; }

              // Actions to switch layouts.
              // Note: if you uncomment these, make sure you do NOT have
              // a matching layout switch hotkey configured in xkb options above.
              // Having both at once on the same hotkey will break the switching,
              // since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
              // Mod+Space       { switch-layout "next"; }
              // Mod+Shift+Space { switch-layout "prev"; }

              Shift+Print { screenshot; }
              Alt+Print { spawn "${pkgs.annotate-screenshot}/bin/annotate-screenshot"; }

              Super+Shift+E { quit; }
              // Mod+Shift+P { power-off-monitors; }

              // Mod+Shift+Ctrl+T { toggle-debug-tint; }

              Super+P allow-when-locked=true { spawn "${config.variables.graphical.exec}" "msg" "output" "${(lib.head config.variables.outputs).output}" "on"; }
              Super+Shift+P { spawn "${config.variables.graphical.exec}" "msg" "output" "${(lib.head config.variables.outputs).output}" "off"; }

              Ctrl+Alt+C { spawn "bash" "-c" "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.tesseract5}/bin/tesseract stdin stdout | ${pkgs.wl-clipboard}/bin/wl-copy"; }
              Super+C { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call launcher clipboard"; }
              Super+Shift+C { spawn "bash" "-c" "env XDG_CACHE_HOME=${config.variables.homeDir}/.cache cliphist wipe"; }
              Ctrl+Alt+R { spawn "bash" "-c" "${pkgs.recordCmd}"; }
              Ctrl+Alt+M { spawn "bash" "-c" "${pkgs.wl-mirror}/bin/wl-mirror --fullscreen ${(lib.head config.variables.outputs).output}"; }
              Ctrl+Alt+Shift+M { spawn "bash" "-c" "${pkgs.procps}/bin/pkill wl-mirror"; }

              Super+O repeat=false { toggle-overview; }
              Ctrl+Alt+Space repeat=false { toggle-overview; }
              Super+grave repeat=false { switch-focus-between-floating-and-tiling; }

              Super+S { spawn-sh "${pkgs.niri-sidebar}/bin/niri-sidebar toggle-window"; }
              Super+Shift+S { spawn-sh "${pkgs.niri-sidebar}/bin/niri-sidebar toggle-visibility"; }
          }

          // Settings for debugging. Not meant for normal use.
          // These can change or stop working at any point with little notice.
          /-debug {
              // Make niri take over its DBus services even if it's not running as a session.
              // Useful for testing screen recording changes without having to relogin.
              // The main niri instance will *not* currently take back the services; so you will
              // need to relogin in the end.
              // dbus-interfaces-in-non-session-instances

              // Wait until every frame is done rendering before handing it over to DRM.
              // wait-for-frame-completion-before-queueing

              // Enable direct scanout into overlay planes.
              // May cause frame drops during some animations on some hardware.
              // enable-overlay-planes

              // Disable the use of the cursor plane.
              // The cursor will be rendered together with the rest of the frame.
              // disable-cursor-plane

              // Slow down animations by this factor.
              // animation-slowdown 3.0

              // Override the DRM device that niri will use for all rendering.
              // render-drm-device "/dev/dri/renderD129"
          }
        '';
      systemd.user.services.pre-sleep = {
        Unit = {
          Description = "Pre-sleep User Service";
          Before = [ "sleep.target" ];
        };
        Install.WantedBy = [ "sleep.target" ];
        Service = {
          Type = "simple";
          ExecStart = "${config.variables.profileDir}/bin/lockscreen";
        };
      };

      systemd.user.services.noctalia-shell = {
        Unit = {
          Description = "Noctalia Shell User Service";
          BindsTo = [ config.variables.graphical.target ];
          PartOf = [ config.variables.graphical.target ];
          After = [ config.variables.graphical.target ];
          Requisite = [ config.variables.graphical.target ];
        };
        Install.WantedBy = [ config.variables.graphical.target ];
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.noctalia-shell}/bin/noctalia-shell";
        };
      };
      services.swayidle = {
        systemdTarget = config.variables.graphical.target;
        events = {
          "before-sleep" = "${config.variables.lockscreen}";
          "after-resume" = "${config.variables.lockscreen}";
          "lock" = "${config.variables.lockscreen}";
          # { event = "after-resume"; command = lib.concatMapStringsSep "; " (o: ''${context.variables.graphical.exec} msg output ${o.output} on'') context.variables.outputs; }
          # { event = "unlock"; command = lib.concatMapStringsSep "; " (o: ''${context.variables.graphical.exec} msg output ${o.output} on'') context.variables.outputs; }
        };
        timeouts = lib.mkOverride 900 [
          {
            timeout = 100;
            command = "${pkgs.noctalia-shell}/bin/noctalia-shell ipc call brightness decrease";
            resumeCommand = "${pkgs.noctalia-shell}/bin/noctalia-shell ipc call brightness increase";
          }
          {
            timeout = 120;
            command = "${config.variables.lockscreen}";
          }
          {
            timeout = 300;
            command = ''${config.variables.graphical.exec} msg action power-off-monitors'';
            # resumeCommand = lib.concatMapStringsSep "; " (o: ''${context.variables.graphical.exec} msg output ${o.output} on'') context.variables.outputs;
          }
          {
            timeout = 3600;
            command = "${pkgs.sleepCmd}/bin/systemctl-sleep";
          }
        ];
      };

      # systemd.user.services.swayidle.Service.Environment = [ "WAYLAND_DISPLAY=wayland-1" ];
      systemd.user.services.swayidle.Unit.ConditionEnvironment = lib.mkForce [ ];

      systemd.user.services.niri-sidebar = {
        Unit = {
          Description = "Niri-Sidebar User Service";
          After = [ config.variables.graphical.target ];
        };
        Install.WantedBy = [ config.variables.graphical.target ];
        Service = {
          Type = "simple";
          Restart = "on-failure";
          ExecStart = "${pkgs.niri-sidebar}/bin/niri-sidebar listen";
        };
      };
    }
    {
      systemd.user.services = builtins.listToAttrs (
        map (o: {
          name = "wallpaper-${o.output}";
          value = {
            Unit = {
              Description = "Wallpaper for ${o.output} User Service";
              BindsTo = [ config.variables.graphical.target ];
              PartOf = [ config.variables.graphical.target ];
              After = [
                config.variables.graphical.target
                "noctalia-shell.service"
              ];
              Requisite = [ config.variables.graphical.target ];
            };
            Install.WantedBy = [ config.variables.graphical.target ];
            Service = {
              Type = "oneshot";
              ExecStart = "${pkgs.noctalia-shell}/bin/noctalia-shell ipc call wallpaper set ${o.wallpaper} ${o.output}";
            };
          };
        }) config.variables.outputs
      );
    }
  ];
}
