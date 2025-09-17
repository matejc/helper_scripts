{
  pkgs,
  lib,
  config,
  inputs,
  contextFile,
  helper_scripts,
  defaultUser,
  ...
}:
let
  context = import contextFile {
    inherit
      pkgs
      lib
      config
      inputs
      dotFileAt
      helper_scripts
      ;
  };

  nur = import inputs.nur {
    nurpkgs = pkgs;
    inherit pkgs;
  };

  dotFileFun =
    nixFilePath:
    let
      dotNixFiles = lib.toList (
        import nixFilePath {
          inherit config pkgs lib;
          inherit (context) variables;
        }
      );
      dotFiles = map (nix: {
        source = nix.source;
        target = lib.replaceStrings [ "${context.variables.homeDir}/" ] [ "" ] nix.target;
      }) dotNixFiles;
    in
    dotFiles;

  binFiles =
    let
      dotFiles = lib.flatten (map dotFileFun context.dotFilePaths);
      binDotFiles = builtins.filter (d: (builtins.substring 0 4 d.target) == "bin/") dotFiles;
    in
    pkgs.runCommand "dot-bins" { } ''
      mkdir -p $out/bin
      ${lib.concatMapStringsSep "\n" (b: ''ln -vs "${b.source}" "$out/${b.target}"'') binDotFiles}
    '';

  dotFiles =
    let
      dots = (lib.flatten (map dotFileFun context.dotFilePaths));
    in
    builtins.listToAttrs (
      map (n: {
        name = n.target;
        value.target = n.target;
        value.source = n.source;
        value.force = true;
      }) (builtins.filter (d: (builtins.substring 0 4 d.target) != "bin/") dots)
    );

  dotFileAt =
    file: at:
    (lib.elemAt (import "${helper_scripts}/dotfiles/${file}" {
      inherit lib pkgs;
      inherit (context) variables config;
    }) at).source;

  services-cmds = map (
    group:
    pkgs.writeScriptBin "service-group-${group}" ''
      #!${context.variables.shell}
      source "${context.variables.shellRc}"
      export WAYLAND_DISPLAY=wayland-1
      export DISPLAY=:0
      ${pkgs.dbus}/bin/dbus-update-activation-environment WAYLAND_DISPLAY DISPLAY
      ${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY WAYLAND_DISPLAY
      ${lib.concatMapStringsSep "\n" (
        s: ''{ sleep ${toString s.delay} && systemctl --user "$1" "${s.name}"; } &''
      ) context.services}
      wait
    ''
  ) (map (s: s.group) context.services);

  dbus-environment = pkgs.writeTextFile {
    name = "dbus-environment";
    destination = "/bin/dbus-environment";
    executable = true;
    text = ''
      dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK SSH_AUTH_SOCK XDG_CURRENT_DESKTOP=${context.variables.graphical.name}
      systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK SSH_AUTH_SOCK XDG_CURRENT_DESKTOP=${context.variables.graphical.name} XDG_SESSION_DESKTOP=${context.variables.graphical.name} DESKTOP_SESSION=${context.variables.graphical.name} XDG_SESSION_TYPE=wayland
      systemctl --user stop pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        ${pkgs.glib}/bin/gsettings set $gnome_schema gtk-theme 'Breeze-Dark'
        ${pkgs.glib}/bin/gsettings set $gnome_schema color-scheme 'prefer-dark'
        ${pkgs.glib}/bin/gsettings set $gnome_schema font-name '${context.variables.font.family} ${toString context.variables.font.size}'
      '';
  };

  setDefaultSink = pkgs.writeShellScript "set-default-sink" ''
    pajson="$(${pkgs.pulseaudio}/bin/pactl -f json list sinks | ${pkgs.jq}/bin/jq '.|[.[]|select(.properties."media.class"=="Audio/Sink")]')"
    paindex="$(echo -n "$pajson" | ${pkgs.jq}/bin/jq --arg def "$(${pkgs.pulseaudio}/bin/pactl get-default-sink)" -r '.|sort_by(.index)[]|"\(.index)\(if ($def == .name) then " [DEFAULT]" else "" end) \(.description)"' | ${pkgs.wofi}/bin/wofi -W 70% -p Speaker -i --dmenu | ${pkgs.gawk}/bin/awk '{printf $1}')"
    paname="$(echo -n "$pajson" | ${pkgs.jq}/bin/jq --arg index "$paindex" -r '.[]|select(($index|tonumber)==.index)|.name')"
    if [ ! -z "$paname" ]
    then
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "$paname"
    fi
  '';

  setDefaultSource = pkgs.writeShellScript "set-default-source" ''
    pajson="$(${pkgs.pulseaudio}/bin/pactl -f json list sources | ${pkgs.jq}/bin/jq '.|[.[]|select(.properties."media.class"=="Audio/Source")]')"
    paindex="$(echo -n "$pajson" | ${pkgs.jq}/bin/jq --arg def "$(${pkgs.pulseaudio}/bin/pactl get-default-source)" -r '.|sort_by(.index)[]|"\(.index)\(if ($def == .name) then " [DEFAULT]" else "" end) \(.description)"' | ${pkgs.wofi}/bin/wofi -W 70% -p Mic -i --dmenu | ${pkgs.gawk}/bin/awk '{printf $1}')"
    paname="$(echo -n "$pajson" | ${pkgs.jq}/bin/jq --arg index "$paindex" -r '.[]|select(($index|tonumber)==.index)|.name')"
    if [ ! -z "$paname" ]
    then
      ${pkgs.pulseaudio}/bin/pactl set-default-source "$paname"
    fi
  '';

  wp_volume = pkgs.writeShellScript "wp_volume" ''
    set -e

    if [ -f $HOME/.rec.pid ]
    then
        printf "<span color='#ff0000'>%s</span>" " "
    fi

    WP_OUTPUT_SOURCE=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    if [[ $WP_OUTPUT_SOURCE =~ ^Volume:[[:blank:]]([0-9]+)\.([0-9]{2})([[:blank:]].MUTED.)?$ ]]; then
        if [[ -n ''${BASH_REMATCH[3]} ]]; then
            printf "<span color='#ff6666'></span> "
        else
            VOLUME=$((10#''${BASH_REMATCH[1]}''${BASH_REMATCH[2]}))

            printf "<span color='#ff6666'> $VOLUME%%</span> "
        fi
    fi
    WP_OUTPUT_SINK=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)
    if [[ $WP_OUTPUT_SINK =~ ^Volume:[[:blank:]]([0-9]+)\.([0-9]{2})([[:blank:]].MUTED.)?$ ]]; then
        if [[ -n ''${BASH_REMATCH[3]} ]]; then
            printf "<span color='#abffff'></span> "
        else
            VOLUME=$((10#''${BASH_REMATCH[1]}''${BASH_REMATCH[2]}))
            ICON=(
                ""
                ""
                ""
            )

            if [[ $VOLUME -gt 50 ]]; then
                printf "<span color='#abffff'>%s $VOLUME%%</span>" "''${ICON[0]}"
            elif [[ $VOLUME -gt 25 ]]; then
                printf "<span color='#abffff'>%s $VOLUME%%</span>" "''${ICON[1]}"
            elif [[ $VOLUME -ge 0 ]]; then
                printf "<span color='#abffff'>%s $VOLUME%%</span>" "''${ICON[2]}"
            fi
        fi
    fi
    printf "\n"
  '';

  chooserCmd = pkgs.writeShellScript "sway-output-chooser" ''
    export PATH="${pkgs.sway}/bin:${pkgs.jq}/bin:${pkgs.wofi}/bin:${pkgs.coreutils}/bin:$PATH"
    export SWAYSOCK="$(ls /run/user/"$(id -u)"/sway-ipc.* | head -n 1)"
    swaymsg -t get_outputs | jq -r '.[]|.name' | wofi -d
  '';

  recordCmd = pkgs.writeShellScript "record.sh" ''
    if [ -f "$HOME/.rec.pid" ]
    then
      rec_pid="$(cat "$HOME/.rec.pid")"
      kill -INT "$rec_pid"
      wait "$rec_pid"
      rm "$HOME/.rec.pid"
    else
      export GST_PLUGIN_SYSTEM_PATH_1_0="${
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
          pkgs.gst_all_1.gstreamer
          pkgs.gst_all_1.gst-plugins-base
          pkgs.gst_all_1.gst-plugins-good
        ]
      }"
      export PATH="${
        lib.makeBinPath [
          pkgs.gst_all_1.gstreamer
          pkgs.pulseaudio
        ]
      }:$PATH"
      mkdir -p "$HOME/Audio"
      rec_path="$HOME/Audio/recording_$(date +%Y-%m-%d_%H-%M-%S).wav"
      gst-launch-1.0 -e audiomixer name=mixer ! queue ! audioconvert ! wavenc ! filesink location="$rec_path" pulsesrc device="$(pactl get-default-source)" ! queue ! audioconvert ! mixer.  pulsesrc device="$(pactl get-default-sink).monitor" ! queue ! audioconvert ! mixer. &
      rec_pid="$!"
      echo -n "$rec_pid" > "$HOME/.rec.pid"
    fi
  '';

  niriWorkspaces = pkgs.writeShellScript "niri_workspaces.sh" ''
    export PATH="$PATH:${context.variables.profileDir}/bin:${
      lib.makeBinPath [
        pkgs.jq
        pkgs.procps
      ]
    }"
    case "$1" in
    action)
        niri msg action "''${@:2}" && pkill -SIGRTMIN+9 waybar;;
    *)
        tree="$(niri msg -j workspaces | jq -jc --argjson wins "$(niri msg -j windows)" --arg output "$1" '[.[] | select(.output == $output) | . += {"windows": [. as $ws | $wins[] | select(.workspace_id == $ws.id)]} | .] | sort_by(.idx)')"
        workspace_str="$(jq -jnr --argjson tree "$tree" '"\($tree[] | "<b><span color=\"\(if .is_active then "#1793d1" else "#cccccc" end)\"> \(.idx)<sup>\(.windows|length)</sup></span></b>")"')"
        title="$(jq -jnr --argjson tree "$tree" '$tree[] | select(.is_active) as $ws | $ws.windows[] | select(.id == $ws.active_window_id) as $win | if $win.title == null then "" elif $win.title|length > 110 then $win.title[0:110]+"..." else $win.title end')"
        jq -jcn --arg title "$title" --arg ws_str "$workspace_str" '{text: "\($ws_str)\t\($title)"}'
    esac
  '';

  getTemperature =
    device: group: field_prefix:
    pkgs.writeShellScript "temperature.sh" ''
      export PATH="$PATH:${
        lib.makeBinPath [
          pkgs.jq
          pkgs.lm_sensors
          pkgs.coreutils
        ]
      }"
      prev_temp="0"
      while true
      do
        tempdata="$(sensors -j "${device}" | jq --unbuffered -c '."${device}"."${group}"')"
        tempp="$(jq --unbuffered -n --argjson data "$tempdata" -r '($data."${field_prefix}_input" / ($data | ."${field_prefix}_crit" // 90) * 100)|tonumber|floor' | cut -d "." -f 1)"
        if (( prev_tempp != tempp ))
        then
          cssclass="normal"
          if (( tempp > 90 ))
          then
            cssclass="critical"
          elif (( tempp > 75 ))
          then
            cssclass="high"
          fi
          jq --unbuffered -nc --argjson data "$tempdata" --arg cssclass "$cssclass" '{text: $data."${field_prefix}_input"|tonumber|floor|tostring, percentage: ($data."${field_prefix}_input" / ($data | ."${field_prefix}_crit" // 90) * 100)|tonumber|floor, alt: "", tooltip: "${device}", class: $cssclass}'
        fi
        prev_tempp="$tempp"
        sleep 5
      done
    '';

  tempstatus_all =
    let
      temp_list = "${lib.concatMapStringsSep "; " (t: ''${getTempstatus t.device t.group t.field_prefix}'') context.variables.temperatures}";
    in
      pkgs.writeShellScriptBin "tempstatus" ''
        ${pkgs.gawk}/bin/awk '{i=$1}i>max{max=i}END{print max}' <(${temp_list})
      '';

  getTempstatus =
    device: group: field_prefix:
    pkgs.writeShellScript "tempstatus-${device}-${group}-${field_prefix}.sh" ''
      export PATH="$PATH:${
        lib.makeBinPath [
          pkgs.jq
          pkgs.lm_sensors
          pkgs.coreutils
        ]
      }"
      sensors -j "${device}" | jq --unbuffered -c '."${device}"."${group}"."${field_prefix}_input"|tonumber|floor'
    '';

  programs = lib.mapAttrsToList (
    name: exec:
    pkgs.writeShellScriptBin name ''
      exec ${exec} "$@"
    ''
  ) context.variables.programs;

  noctaliaShellDefaultSettings = pkgs.writeText "noctalia-shell-settings.json" ''
{
    "appLauncher": {
        "backgroundOpacity": 0.98,
        "enableClipboardHistory": true,
        "pinnedExecs": [
        ],
        "position": "center"
    },
    "audio": {
        "cavaFrameRate": 30,
        "mprisBlacklist": [
        ],
        "preferredPlayer": "mpv",
        "showMiniplayerAlbumArt": false,
        "showMiniplayerCava": false,
        "visualizerType": "linear",
        "volumeStep": 5
    },
    "bar": {
        "alwaysShowBatteryPercentage": true,
        "backgroundOpacity": 0.98,
        "monitors": [
        ],
        "position": "bottom",
        "showActiveWindowIcon": true,
        "showNetworkStats": false,
        "showWorkspaceLabel": "index",
        "useDistroLogo": false,
        "widgets": {
            "center": [
                {
                    "id": "Workspace"
                }
            ],
            "left": [
                {
                    "id": "SystemMonitor"
                },
                {
                    "id": "MediaMini"
                },
                {
                    "id": "ActiveWindow"
                }
            ],
            "right": [
                {
                    "id": "ScreenRecorderIndicator"
                },
                {
                    "id": "KeepAwake"
                },
                {
                    "id": "NotificationHistory"
                },
                {
                    "id": "WiFi"
                },
                {
                    "id": "Bluetooth"
                },
                {
                    "id": "Battery"
                },
                {
                    "id": "Volume"
                },
                {
                    "id": "Microphone"
                },
                {
                    "id": "Brightness"
                },
                {
                    "id": "NightLight"
                },
                {
                    "id": "Tray"
                },
                {
                    "id": "Clock"
                },
                {
                    "id": "SidePanelToggle"
                }
            ]
        }
    },
    "brightness": {
        "brightnessStep": 5
    },
    "colorSchemes": {
        "darkMode": true,
        "predefinedScheme": "${pkgs.noctalia-shell}/share/noctalia-shell/Assets/ColorScheme/Gruvbox.json",
        "useWallpaperColors": false
    },
    "dock": {
        "autoHide": true,
        "exclusive": false,
        "monitors": [
        ]
    },
    "general": {
        "animationSpeed": 0.5,
        "avatarImage": "/home/matejc/.face",
        "dimDesktop": true,
        "radiusRatio": 1,
        "showScreenCorners": false
    },
    "hooks": {
        "darkModeChange": "",
        "enabled": false,
        "wallpaperChange": ""
    },
    "location": {
        "name": "Helsinki",
        "reverseDayMonth": false,
        "showDateWithClock": true,
        "use12HourClock": false,
        "useFahrenheit": false
    },
    "matugen": {
        "enableUserTemplates": false,
        "foot": false,
        "fuzzel": false,
        "ghostty": false,
        "gtk3": true,
        "gtk4": true,
        "kitty": false,
        "qt5": true,
        "qt6": true,
        "vesktop": false
    },
    "network": {
        "bluetoothEnabled": true,
        "wifiEnabled": true
    },
    "nightLight": {
        "autoSchedule": true,
        "dayTemp": "6500",
        "enabled": true,
        "manualSunrise": "06:30",
        "manualSunset": "18:30",
        "nightTemp": "4000"
    },
    "notifications": {
        "monitors": [
        ]
    },
    "screenRecorder": {
        "audioCodec": "opus",
        "audioSource": "both",
        "colorRange": "limited",
        "directory": "/home/matejc/Videos",
        "frameRate": 60,
        "quality": "very_high",
        "showCursor": true,
        "videoCodec": "h264",
        "videoSource": "portal"
    },
    "settingsVersion": 1,
    "ui": {
        "fontBillboard": "Roboto Medium",
        "fontDefault": "Roboto",
        "fontFixed": "SauceCodePro Nerd Font Mono",
        "idleInhibitorEnabled": false,
        "monitorsScaling": [
        ]
    },
    "wallpaper": {
        "directory": "/home/matejc/Pictures/Wallpapers",
        "enableMultiMonitorDirectories": false,
        "enabled": true,
        "fillColor": "#000000",
        "fillMode": "crop",
        "monitors": [
        ],
        "randomEnabled": false,
        "randomIntervalSec": 300,
        "setWallpaperOnAllMonitors": true,
        "transitionDuration": 1500,
        "transitionEdgeSmoothness": 0.05,
        "transitionType": "random"
    }
}
  '';

  noctaliaShellStartPreSh = pkgs.writeShellScript "noctalia-shell-start-pre.sh" ''
    mkdir -p ${context.variables.homeDir}/.config/noctalia

    if [ ! -e "${context.variables.homeDir}/.config/noctalia/settings.json" ]
    then
      cat "${noctaliaShellDefaultSettings}" > "${context.variables.homeDir}/.config/noctalia/settings.json"
    fi
  '';

  sleepCmd = pkgs.writeShellScriptBin "systemctl-sleep" ''
    exec ${pkgs.systemd}/bin/systemctl ${if context.variables ? "hibernate" && context.variables.hibernate then "hibernate" else "suspend"}
  '';
in
{
  imports = [
    "${inputs.nixmy}/default.nix"
  ];
  config = lib.mkMerge (
    [
      {
        nixpkgs.overlays = [
          (final: prev: {
            sway-workspace = pkgs.callPackage ../nixes/sway-workspace.nix { };
            sway-scratchpad = pkgs.callPackage ../nixes/sway-scratchpad.nix { };
            cproxy = pkgs.callPackage ../nixes/cproxy.nix { };
            graftcp = pkgs.callPackage ../nixes/graftcp.nix { };
            sway-wsshare = pkgs.callPackage ../nixes/sway-wsshare/default.nix { };
            thorium = pkgs.callPackage ../nixes/thorium.nix { };
            swiftpoint = pkgs.callPackage ../nixes/swiftpoint.nix { };
            logseq = pkgs.callPackage ../nixes/logseq.nix { };
            cinny-desktop = pkgs.callPackage ../nixes/cinny-desktop.nix { pkgs = prev; };
            nix-index = inputs.nix-index-database.packages.${pkgs.system}.nix-index-with-db; # for nixmy
            mpv = prev.mpv.override {
              scripts = [ prev.mpvScripts.mpris ];
            };
            noctalia-shell = inputs.noctalia.packages.${pkgs.system}.default;
            quickshell = inputs.quickshell.packages.${pkgs.system}.default;
            /*
              freerdp3 = (prev.freerdp3.override {
                SDL2 = pkgs.callPackage ../nixes/SDL3/default.nix { };
                SDL2_ttf = pkgs.callPackage ../nixes/SDL3/SDL_ttf.nix { };
                SDL2_image = pkgs.callPackage ../nixes/SDL3/SDL_image.nix { };
                openssl = pkgs.openssl_1_1;
              }).overrideAttrs (old: {
                version = "unstable-2024-11-21";
                src = pkgs.fetchFromGitHub {
                  owner = "akallabeth";
                  repo = "FreeRDP";
                  rev = "4cbdd2c1761571d2d5bb30012f977ce329f7745f";
                  hash = "sha256-y5cyi/qeroXkwzuXPqWuADObfPRlxoSUF0lQymV1vNU=";
                };
                # src = pkgs.fetchFromGitHub {
                #   owner = "FreeRDP";
                #   repo = "FreeRDP";
                #   rev = "c4559c39c3e044e69b022e4759f2a670a0cb0f51";
                #   hash = "sha256-cLXgyh4khjycxvhCedhQus8BPIrQuO0+srjsL3z8Lqw=";
                # };
              });
            */
            notion-desktop = inputs.notion-desktop.packages.${pkgs.system}.default;
          })
          inputs.niri.overlays.niri
        ];

        environment.systemPackages = [ sleepCmd ];

        systemd.sleep.extraConfig = lib.mkIf (context.variables ? "hibernate" && context.variables.hibernate) ''
          AllowHibernation=yes
        '';
        services.logind.settings.Login = lib.mkIf (context.variables ? "hibernate" && context.variables.hibernate) {
          HandleSuspendKey = "hibernate";
          HandleLidSwitch = "hibernate";
        };

        xdg.portal = {
          enable = true;
          wlr = {
            # enable = true;
            settings.screencast = {
              max_fps = 30;
              chooser_type = pkgs.lib.mkDefault "dmenu";
              chooser_cmd = pkgs.lib.mkDefault "${chooserCmd}";
            };
          };
          # config.common.default = pkgs.lib.mkDefault "*";
          config.sway = {
            default = "gtk";
            "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
            "org.freedesktop.impl.portal.ScreenCast" = "wlr";
            "org.freedesktop.impl.portal.Screenshot" = "wlr";
          };
          config.niri = {
            default = "gnome;gtk;";
            "org.freedesktop.impl.portal.Access" = "gtk";
            "org.freedesktop.impl.portal.Notification" = "gtk";
            "org.freedesktop.impl.portal.OpenURI" = "gtk";
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
            "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
          };
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          xdgOpenUsePortal = true;
        };
        fonts.packages = [
          pkgs.font-awesome
          pkgs.corefonts
          pkgs.nerd-fonts.sauce-code-pro
          pkgs.nerd-fonts.fira-code
          pkgs.nerd-fonts.fira-mono
        ];

        services.tlp = {
          enable = true;
          settings = {
            START_CHARGE_THRESH_BAT0 = 90;
            STOP_CHARGE_THRESH_BAT0 = 95;
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            PLATFORM_PROFILE_ON_AC = "performance";
            PLATFORM_PROFILE_ON_BAT = "low-power";
          };
        };
        programs.nix-ld.enable = true;
        programs.dconf.enable = true;
        services.dbus.packages = [ pkgs.gcr ]; # gpg-entry.pinentryFlavor = "gnome3"

        programs.nix-index-database.comma.enable = true;

        nix = {
          channel.enable = false;
          settings = {
            nix-path = "nixpkgs=${inputs.nixpkgs}";
            experimental-features = [
              "nix-command"
              "flakes"
            ];
          };
          gc = {
            automatic = true;
            dates = "weekly";
          };
        };

        programs.nixmy = {
          nixpkgsLocalPath = context.variables.nixmy.nixpkgs;
          nixpkgsRemote = context.variables.nixmy.remote;
          backupRemote = context.variables.nixmy.backup;
          extraPaths = [ pkgs.gnumake ];
          nix = config.nix.package;
        };

        # powerManagement.resumeCommands = ''
        #   export XDG_RUNTIME_DIR="/run/user/$(${pkgs.stdenv.cc.libc.getent}/bin/getent passwd "${defaultUser}" | ${pkgs.coreutils}/bin/cut -d: -f3)"
        #   ${pkgs.sudo}/bin/sudo -iu "${defaultUser}" env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR WAYLAND_DISPLAY=wayland-1 ${context.variables.homeDir}/bin/lockscreen
        # '';

        services.udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
        '';
        users.users.${defaultUser}.extraGroups = [ "video" ];

        services.upower.enable = true;

        home-manager.useGlobalPkgs = true;
        nixpkgs.config = import "${helper_scripts}/dotfiles/nixpkgs-config.nix";
        home-manager.useUserPackages = false;
        home-manager.backupFileExtension = "backup";
        home-manager.users.${defaultUser} =
          { config, ... }:
          {
            imports = [
              # inputs.hyprland.homeManagerModules.default
              inputs.niri.homeModules.niri
            ];
            config = lib.mkMerge (
              [
                {

                  home.file = {
                    default-cursor = {
                      source = "${config.gtk.cursorTheme.package}/share/icons/${config.gtk.cursorTheme.name}";
                      target = ".icons/default";
                    };
                    nixpkgs-config = {
                      source = "${helper_scripts}/dotfiles/nixpkgs-config.nix";
                      target = ".config/nixpkgs/config.nix";
                    };
                  } // dotFiles;

                  nix.settings.experimental-features = [ "configurable-impure-env" "nix-command" "flakes" ];

                  xdg = {
                    enable = true;
                    #configFile."nixpkgs/config.nix".source = "nixpkgs-config.nix";
                    configFile."sworkstyle/config.toml".text = ''
                      fallback = ''

                      [matching]
                      'vlc' = ''
                      'pavucontrol' = ''
                      'org.gnome.Nautilus' = ''
                      'Thunderbird' = ''
                      'thunderbird' = ''
                      'Google-chrome' = ''
                      '/Chromium.*/' = ''
                      'Slack' = ''
                      'Code' = ''
                      'code-oss' = ''
                      'Emacs' = ''
                      'jetbrains-studio' = ''
                      '/(?i)^Github.*Firefox/' = ''
                      'firefox' = ''
                      'Nightly' = ''
                      'firefoxdeveloperedition' = ''
                      'nvim-qt' = ''
                      '/npm/' = ''
                      '/node/' = ''
                      '/yarn/' = ''
                      '/KeePassXC/' = ''
                      'Alacritty' = ''
                      'kitty' = ''
                      'org.wezfurlong.wezterm' = ''
                      'ScratchTerm' = ''
                    '';
                    systemDirs.config = [ "${pkgs.swaynotificationcenter}/etc/xdg" ];
                    mime.enable = true;
                    mimeApps = {
                      enable = true;
                      defaultApplications = {
                        "x-scheme-handler/https" = [ "browser.desktop" ];
                        "x-scheme-handler/http" = [ "browser.desktop" ];
                        "x-scheme-handler/file" = [ "browser.desktop" ];
                        "application/pdf" = [ "browser.desktop" ];
                      };
                    };
                    desktopEntries = {
                      browser = {
                        name = "Web Browser";
                        genericName = "Web Browser";
                        exec = "${context.variables.profileDir}/bin/browser %U";
                        terminal = false;
                        categories = [
                          "Application"
                          "Network"
                          "WebBrowser"
                        ];
                        mimeType = [
                          "x-scheme-handler/https"
                          "x-scheme-handler/http"
                          "x-scheme-handler/file"
                          "application/pdf"
                        ];
                      };
                    };
                  };

                  services.gnome-keyring = {
                    enable = true;
                  };
                  #systemd.user.services.gnome-keyring.Service.ExecStart = mkForce "/wrappers/gnome-keyring-daemon --start --foreground --components=secrets";

                  fonts.fontconfig.enable = lib.mkForce true;
                  home.packages =
                    [
                      pkgs.font-awesome
                      config.gtk.font.package
                      pkgs.noto-fonts-emoji
                      pkgs.git
                      pkgs.git-crypt
                      pkgs.zsh
                      pkgs.wl-clipboard
                      pkgs.xdg-utils
                      pkgs.dconf
                      pkgs.rofi
                      pkgs.qt6.qtwayland
                      pkgs.file
                      pkgs.jq
                      pkgs.devenv
                      binFiles
                      tempstatus_all
                    ]
                    ++ services-cmds
                    ++ programs;
                  home.sessionVariables = {
                    #NVIM_QT_PATH = "/mnt/c/tools/neovim-qt/bin/nvim-qt.exe";
                    # QT_PLUGIN_PATH = "${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}";
                    # QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}";
                    QT_QPA_PLATFORM = "wayland";
                    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
                    _JAVA_AWT_WM_NONREPARENTING = "1";
                    #GTK_USE_PORTAL = "1";
                    #NIXOS_XDG_OPEN_USE_PORTAL = "1";
                    MOZ_ENABLE_WAYLAND = "1";
                    NIXOS_OZONE_WL = "1";
                    NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
                    XDG_CURRENT_DESKTOP = context.variables.graphical.name;
                  };
                  home.sessionPath = [ "${config.home.homeDirectory}/bin" ];

                  gtk = {
                    enable = true;
                    font = {
                      package = pkgs.nerd-fonts.sauce-code-pro;
                      name = context.variables.font.family;
                      size = builtins.floor context.variables.font.size;
                    };
                    iconTheme = {
                      name = "breeze-dark";
                      package = pkgs.kdePackages.breeze-icons;
                    };
                    theme = {
                      name = "Breeze-Dark";
                      package = pkgs.kdePackages.breeze-gtk;
                    };
                    cursorTheme = {
                      name = "Vanilla-DMZ";
                      package = pkgs.vanilla-dmz;
                      size = 16;
                    };
                  };

                  qt = {
                    enable = true;
                    platformTheme.name = "adwaita";
                  };

                  programs.chromium = {
                    dictionaries = [
                      pkgs.hunspellDictsChromium.en_US
                    ];
                    extensions = [
                      # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
                      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # ublock origin lite
                      { id = "gcbommkclmclpchllfjekcdonpmejbdp"; } # https everywhere
                      { id = "oboonakemofpalcgghocfoadofidjkkk"; } # keepassxc
                      { id = "clpapnmmlmecieknddelobgikompchkk"; } # disable automatic gain control
                    ];
                  };

                  programs.firefox = {
                    profiles = {
                      default = {
                        extensions.packages = with nur.repos.rycee.firefox-addons; [
                          keepassxc-browser
                          multi-account-containers
                          tree-style-tab
                          adnauseam
                        ];
                        settings = {
                          "general.smoothScroll" = false;
                          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
                          "ui.textScaleFactor" = 90;
                          "browser.tabs.drawInTitlebar" = false;
                          "browser.toolbars.bookmarks.visibility" = "never";
                          "browser.startup.page" = 3;
                        };
                        userChrome = ''
                          * {
                             font-size: ${toString context.variables.font.size}pt !important;
                          }

                          /* Hide main tabs toolbar */

                          #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
                              opacity: 0;
                              pointer-events: none;
                          }

                          #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
                              visibility: collapse !important;
                          }

                          /* Sidebar min and max width removal */

                          #sidebar-box {
                              max-width: none !important;
                              min-width: 0px !important;
                          }
                          /* Hide splitter, when using Tree Style Tab. */

                          #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] + #sidebar-splitter {
                              display: none !important;
                          }
                          /* Hide sidebar header, when using Tree Style Tab. */

                          #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
                              visibility: collapse;
                          }

                          /* Shrink sidebar until hovered, when using Tree Style Tab. */
                          :root {
                              --thin-tab-width: 100px;
                              --wide-tab-width: 350px;
                          }

                          #sidebar-box:not([sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"]) {
                              min-width: var(--wide-tab-width) !important;
                              max-width: none !important;
                          }

                          #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] {
                              position: relative !important;
                              transition: all 200ms !important;
                              min-width: var(--thin-tab-width) !important;
                              max-width: var(--thin-tab-width) !important;
                              z-index: calc(var(--browser-area-z-index-tabbox, 10000) + 1) !important;
                          }

                          #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"]:hover {
                              transition: all 200ms !important;
                              min-width: var(--wide-tab-width) !important;
                              max-width: var(--wide-tab-width) !important;
                              margin-right: calc((var(--wide-tab-width) - var(--thin-tab-width)) * -1) !important;
                          }
                        '';
                      };
                    };
                  };

                  programs.htop.enable = true;

                  programs.home-manager = {
                    enable = true;
                  };
                  home.username = defaultUser;
                  home.homeDirectory = "/home/${defaultUser}";

                  services.kanshi = {
                    systemdTarget = context.variables.graphical.target;
                    settings = [
                      {
                        profile.name = "default";
                        profile.outputs = map (o: {
                          inherit (o)
                            criteria
                            position
                            mode
                            scale
                            status
                            ;
                        }) context.variables.outputs;
                      }
                      {
                        profile.name = "firstonly";
                        profile.outputs = lib.imap0 (i: o: {
                          inherit (o)
                            criteria
                            position
                            mode
                            scale
                            ;
                          status = if i == 0 then "enable" else "disable";
                        }) context.variables.outputs;
                      }
                      {
                        profile.name = "all";
                        profile.outputs = map (o: {
                          inherit (o)
                            criteria
                            position
                            mode
                            scale
                            ;
                          status = "enable";
                        }) context.variables.outputs;
                      }
                    ];
                  };

                  services.kdeconnect = {
                    #enable = true;
                    #indicator = true;
                  };
                  systemd.user.services.kdeconnect.Install.WantedBy = lib.mkForce [
                    context.variables.graphical.target
                  ];
                  systemd.user.services.kdeconnect-indicator.Install.WantedBy = lib.mkForce [
                    context.variables.graphical.target
                  ];
                  systemd.user.services.kdeconnect-indicator.Unit.Requires = lib.mkForce [ ];

                  wayland.windowManager.sway = {
                    systemd.enable = true;
                    wrapperFeatures.gtk = true;
                    config =
                      let
                        dropdown = "${pkgs.sway-scratchpad}/bin/sway-scratchpad -c ${context.variables.binDir}/terminal -m terminal";
                        passwords = "${pkgs.sway-scratchpad}/bin/sway-scratchpad -c ${pkgs.keepassxc}/bin/keepassxc -m keepassxc --width 75 --height 70";
                        journal = "${pkgs.sway-scratchpad}/bin/sway-scratchpad -c ${pkgs.logseq}/bin/logseq -m journal --width 75 --height 70";
                        resizeModeName = "Resize: arrow keys";
                        mirrorModeName = "Mirror: s - sway-wsshare, c - create, f - toggle freeze";
                        signalModeName = "Signal: s - stop, q - continue, k - terminate, 9 - kill";
                        audioModeName = "Audio: s - speakers, m - mic, r - toggle recording";
                      in
                      rec {
                        assigns = lib.mkDefault {
                          #"workspace number 1" = [{ app_id = "^org.keepassxc.KeePassXC$"; }];
                          # "workspace number 4" = [{ class = "^Firefox$"; } { class = "^Chromium-browser$"; } { class = "^Google-chrome$"; }];
                        };
                        bars = [ ];
                        #bars = [ {
                        #  fonts = {
                        #    names = [ context.variables.font.family ];
                        #    style = context.variables.font.style;
                        #    size = context.variables.font.size;
                        #  };
                        #  colors.background = "#32302f";
                        #  statusCommand = "i3status-rs ${context.variables.homeDir}/.config/i3status-rust/config-default.toml";
                        #} ];
                        colors = {
                          background = "#ff0000";
                          focused = {
                            background = "#272822";
                            border = "#272822";
                            childBorder = "#66D9EF";
                            indicator = "#66D9EF";
                            text = "#A6E22E";
                          };
                          focusedInactive = {
                            background = "#272822";
                            border = "#272822";
                            childBorder = "#272822";
                            indicator = "#272822";
                            text = "#66D9EF";
                          };
                          unfocused = {
                            background = "#1E1F1C";
                            border = "#1E1F1C";
                            childBorder = "#272822";
                            indicator = "#272822";
                            text = "#939393";
                          };
                          urgent = {
                            background = "#F92672";
                            border = "#F92672";
                            childBorder = "#F92672";
                            indicator = "#F92672";
                            text = "#FFFFFF";
                          };
                        };
                        fonts = {
                          names = [ context.variables.font.family ];
                          style = context.variables.font.style;
                          size = context.variables.font.size;
                        };
                        keybindings = lib.mkOptionDefault {
                          "${modifier}+Control+t" = "exec ${context.variables.programs.terminal}";
                          "Mod1+Control+t" = "exec ${context.variables.programs.terminal}";
                          "${modifier}+Control+h" =
                            "exec ${context.variables.programs.filemanager} '${context.variables.homeDir}'";
                          "Mod1+Control+h" = "exec ${context.variables.programs.filemanager} '${context.variables.homeDir}'";
                          "F12" = "exec ${dropdown}";
                          "XF86Favorites" = "exec ${dropdown}";
                          "F9" = "exec ${passwords}";
                          "XF86Messenger" = "exec ${passwords}";
                          "Control+Mod1+p" = "exec ${passwords}";
                          "Control+Mod1+j" = "exec ${journal}";
                          "${modifier}+k" = "kill";
                          "Mod1+Control+space" = "exec ${context.variables.programs.launcher}";
                          "${modifier}+Control+space" = "exec ${context.variables.programs.launcher}";
                          "${modifier}+l" = "exec ${context.variables.profileDir}/bin/lockscreen";
                          "Mod1+Control+l" = "exec ${context.variables.profileDir}/bin/lockscreen";
                          "Control+Tab" = "workspace back_and_forth";
                          "Mod1+Control+n" = "exec ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
                          "Mod1+Control+Up" = "exec ${pkgs.sway-workspace}/bin/sway-workspace prev-output";
                          "Mod1+Control+Down" = "exec ${pkgs.sway-workspace}/bin/sway-workspace next-output";
                          "Mod1+Control+Shift+Up" = "exec ${pkgs.sway-workspace}/bin/sway-workspace --move prev-output";
                          "Mod1+Control+Shift+Down" = "exec ${pkgs.sway-workspace}/bin/sway-workspace --move next-output";
                          "Mod1+Control+Left" = "exec ${pkgs.sway-workspace}/bin/sway-workspace prev-on-output --skip-empty";
                          "Mod1+Control+Right" = "exec ${pkgs.sway-workspace}/bin/sway-workspace next-on-output --skip-empty";
                          "Mod1+Control+Shift+Left" = "exec ${pkgs.sway-workspace}/bin/sway-workspace --move prev-on-output";
                          "Mod1+Control+Shift+Right" = "exec ${pkgs.sway-workspace}/bin/sway-workspace --move next-on-output";
                          "Print" =
                            "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" ${context.variables.homeDir}/Pictures/Screenshot-$(date +%Y-%m-%d_%H-%M-%S).png";
                          "Shift+Print" =
                            "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png";
                          "Control+Mod1+Delete" = "exec ${pkgs.nwg-bar}/bin/nwg-bar";
                          "Control+Mod1+m" = "exec ${pkgs.nwg-displays}/bin/nwg-displays";
                          "XF86AudioMute" =
                            "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle, exec ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar";
                          "XF86AudioRaiseVolume" =
                            "exec ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 3%+, exec ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar";
                          "XF86AudioLowerVolume" =
                            "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-, exec ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar";
                          "XF86AudioMicMute" =
                            "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle, exec ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar";
                          "XF86MonBrightnessUp" = "exec ${pkgs.brillo}/bin/brillo -A 10";
                          "XF86MonBrightnessDown" = "exec ${pkgs.brillo}/bin/brillo -U 10";
                          "${modifier}+p" = "output ${(lib.head context.variables.outputs).output} toggle";
                          "${modifier}+m" = "mode \"${mirrorModeName}\"";
                          "${modifier}+s" = "mode \"${signalModeName}\"";
                          "${modifier}+r" = "mode \"${resizeModeName}\"";
                          "${modifier}+a" = lib.mkForce "mode \"${audioModeName}\"";
                          "${modifier}+c" =
                            "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.tesseract5}/bin/tesseract stdin stdout | ${pkgs.wl-clipboard}/bin/wl-copy";
                        };
                        modifier = "Mod4";
                        modes = lib.mkOptionDefault {
                          "${resizeModeName}" = {
                            "Left" = "resize shrink width 10 px";
                            "Down" = "resize grow height 10 px";
                            "Up" = "resize shrink height 10 px";
                            "Right" = "resize grow width 10 px";
                            "Escape" = "mode default";
                            "Return" = "mode default";
                          };
                          "${mirrorModeName}" = {
                            "s" = "exec sway-wsshare, mode \"default\"";
                            "c" =
                              "exec env PATH=${pkgs.rofi}/bin:$PATH ${pkgs.wl-mirror}/bin/wl-present mirror, mode \"default\"";
                            "f" =
                              "exec env PATH=${pkgs.rofi}/bin:$PATH ${pkgs.wl-mirror}/bin/wl-present toggle-freeze, mode \"default\"";
                            "Escape" = "mode default";
                            "Return" = "mode default";
                          };
                          "${signalModeName}" = {
                            "s" =
                              "exec ${pkgs.coreutils}/bin/kill -SIGSTOP $(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid'), mode \"default\"";
                            "q" =
                              "exec ${pkgs.coreutils}/bin/kill -SIGCONT $(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid'), mode \"default\"";
                            "k" =
                              "exec ${pkgs.coreutils}/bin/kill -SIGTERM $(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid'), mode \"default\"";
                            "9" =
                              "exec ${pkgs.coreutils}/bin/kill -SIGKILL $(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid'), mode \"default\"";
                            "Escape" = "mode default";
                            "Return" = "mode default";
                          };
                          "${audioModeName}" = {
                            "s" = "exec ${setDefaultSink}, exec ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar, mode \"default\"";
                            "m" =
                              "exec ${setDefaultSource}, exec ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar, mode \"default\"";
                            "r" = "exec ${recordCmd}, exec ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar, mode \"default\"";
                            "Escape" = "mode default";
                            "Return" = "mode default";
                          };
                        };
                        startup = [
                          {
                            command = "${dbus-environment}/bin/dbus-environment";
                            always = true;
                          }
                          {
                            command = "${configure-gtk}/bin/configure-gtk";
                            always = true;
                          }
                          {
                            command = "${context.variables.profileDir}/bin/service-group-always restart";
                            always = true;
                          }
                          { command = "${context.variables.profileDir}/bin/service-group-once start"; }
                          #{ command = "${mako}/bin/mako"; always = true; }
                          {
                            command = "${pkgs.swayest-workstyle}/bin/sworkstyle";
                            always = true;
                          }
                          # { command = "${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK SSH_AUTH_SOCK XDG_CURRENT_DESKTOP=sway"; }
                          # { command = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK SSH_AUTH_SOCK XDG_CURRENT_DESKTOP=sway"; }
                        ];
                        window = {
                          border = 1;
                          commands = [
                            #{ command = "mark I3WM_SCRATCHPAD"; criteria = { app_id = "ScratchTerm"; }; }
                            #{ command = "border pixel 1"; criteria = { class = "Xfce4-terminal"; }; }
                            #{ command = "border pixel 1"; criteria = { class = ".nvim-qt-wrapped"; }; }
                            #{ command = "border pixel 1"; criteria = { class = "Firefox"; }; }
                            #{ command = "border pixel 1"; criteria = { class = "Chromium-browser"; }; }
                            # { command = "inhibit_idle visible"; criteria = { title = "YouTube"; }; }
                            #{ command = "inhibit_idle fullscreen"; criteria = { shell = ".*"; }; }
                            {
                              command = "floating enable, sticky enable, resize set 30 ppt 60 ppt, border pixel 10";
                              criteria = {
                                app_id = "^launcher$";
                              };
                            }
                            {
                              command = "border pixel 1";
                              criteria = {
                                con_mark = "SCRATCHPAD_terminal";
                              };
                            }
                            {
                              command = "kill";
                              criteria = {
                                app_id = "firefox";
                                title = "Firefox — Sharing Indicator";
                              };
                            }
                            {
                              command = "opacity 0.95";
                              criteria = {
                                app_id = "Logseq";
                              };
                            }
                          ];
                        };
                        #seat = {
                        #  "*" = {
                        #    hide_cursor = "when-typing disable";
                        #  };
                        #};
                        output = lib.listToAttrs (
                          map (o: {
                            name = o.output;
                            value = (
                              {
                                bg = "${o.wallpaper} fill";
                                scale = (toString o.scale);
                              }
                              // (lib.optionalAttrs (o.mode != null) { inherit (o) mode; })
                            );
                          }) context.variables.outputs
                        );
                        workspaceOutputAssign = lib.flatten (
                          map (
                            o:
                            map (w: {
                              workspace = w;
                              inherit (o) output;
                            }) o.workspaces
                          ) context.variables.outputs
                        );
                        window.titlebar = false;
                      };
                    extraConfig = ''
                      focus_wrapping yes
                    '';
                  };

                  wayland.windowManager.hyprland.xwayland.enable = true;
                  wayland.windowManager.hyprland.systemd.enable = true;
                  wayland.windowManager.hyprland.extraConfig = ''
                    $mod = SUPER

                    bind = CTRL ALT, b, exec, ${context.variables.programs.browser}
                    bind = CTRL ALT, Space, exec, ${context.variables.programs.launcher}
                    bind = CTRL ALT, t, exec, ${context.variables.programs.terminal}
                    bind = CTRL ALT, h, exec, ${context.variables.programs.filemanager}

                    bind = CTRL ALT, l, exec, ${context.variables.profileDir}/bin/lockscreen
                    bind = $mod, l, exec, ${context.variables.profileDir}/bin/lockscreen

                    bind = $mod, Up, movefocus, u
                    bind = $mod, Down, movefocus, d
                    bind = $mod, Right, movefocus, r
                    bind = $mod, Left, movefocus, l

                    bind = $mod SHIFT, Up, movewindow, u
                    bind = $mod SHIFT, Down, movewindow, d
                    bind = $mod SHIFT, Right, movewindow, r
                    bind = $mod SHIFT, Left, movewindow, l

                    bind = CTRL ALT, Left,  workspace, m-1
                    bind = CTRL ALT, Right, workspace, m+1

                    bind = CTRL ALT SHIFT, Left,  movetoworkspace, r-1
                    bind = CTRL ALT SHIFT, Right, movetoworkspace, r+1

                    bind = CTRL ALT, Up,  focusmonitor, -1
                    bind = CTRL ALT, Down, focusmonitor, +1

                    bind = CTRL ALT SHIFT, Up,  movewindow, mon:-1
                    bind = CTRL ALT SHIFT, Down, movewindow, mon:+1

                    bind = $mod, Tab, cyclenext
                    bind = $mod SHIFT, Tab, cyclenext, prev

                    bind = $mod, f, fullscreen,
                    bind = $mod, k, killactive,
                    bind = $mod SHIFT, E, exit,
                    bind = $mod SHIFT, R, exec, hyprctl reload
                    bind = $mod SHIFT, R, forcerendererreload,

                    bind = CTRL ALT, n, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw
                    bind = CTRL ALT, Delete, exec, ${pkgs.nwg-bar}/bin/nwg-bar

                    binde=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 3%+
                    bindl=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-
                    bindl=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
                    bindl=, XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

                    binde = , XF86MonBrightnessUp, exec, ${pkgs.brillo}/bin/brillo -A 10
                    binde = , XF86MonBrightnessDown, exec, ${pkgs.brillo}/bin/brillo -U 10

                    bind = , Print, exec, ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" ${context.variables.homeDir}/Pictures/Screenshot-$(date +%Y-%m-%d_%H-%M-%S).png
                    bind = SHIFT, Print, exec, ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png
                    bind = $mod, c, exec, ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.tesseract5}/bin/tesseract stdin stdout | ${pkgs.wl-clipboard}/bin/wl-copy

                    bindl = $mod, p, exec, ${pkgs.kanshi}/bin/kanshictl switch firstonly
                    bind = $mod SHIFT, p, exec, ${pkgs.kanshi}/bin/kanshictl switch default

                    bindm = $mod, mouse:272, movewindow
                    bindm = $mod, mouse:273, resizewindow

                    bind = $mod, r, submap, resize
                    submap=resize
                    binde=,right,resizeactive,10 0
                    binde=,left,resizeactive,-10 0
                    binde=,up,resizeactive,0 -10
                    binde=,down,resizeactive,0 10
                    bind=,escape,submap,reset
                    submap=reset

                    bind = $mod, s, submap, signal
                    submap=signal
                    bind =, s, exec, ${pkgs.coreutils}/bin/kill -SIGSTOP $(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid')
                    bind =, s, submap, reset
                    bind =, q, exec, ${pkgs.coreutils}/bin/kill -SIGCONT $(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid')
                    bind =, q, submap, reset
                    bind =, k, exec, ${pkgs.coreutils}/bin/kill -SIGTERM $(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid')
                    bind =, k, submap, reset
                    bind =, 9, exec, ${pkgs.coreutils}/bin/kill -SIGKILL $(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid')
                    bind =, 9, submap, reset
                    bind=,escape,submap,reset
                    submap=reset

                    bind = $mod, a, submap, audio
                    submap=audio
                    bind =, s, exec, ${setDefaultSink}
                    bind =, s, submap, reset
                    bind =, m, exec, ${setDefaultSource}
                    bind =, m, submap, reset
                    bind =, p, exec, ${pkgs.pavucontrol}/bin/pavucontrol
                    bind =, p, submap, reset
                    bind =, h, exec, ${pkgs.helvum}/bin/helvum
                    bind =, h, submap, reset
                    bind=,escape,submap,reset
                    submap=reset

                    # workspaces
                    ${lib.concatMapStringsSep "\n" (
                      o: lib.concatMapStringsSep "\n" (w: "workspace=${o.output},${w}") o.workspaces
                    ) context.variables.outputs}

                    monitor=,preferred,auto,1
                    ${lib.concatMapStringsSep "\n" (
                      o:
                      ''monitor=${o.output},${if o.mode == null then "preferred" else o.mode},${
                        lib.replaceStrings [ "," ] [ "x" ] o.position
                      },${toString o.scale}''
                    ) context.variables.outputs}

                    # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
                    ${builtins.concatStringsSep "\n" (
                      builtins.genList (
                        x:
                        let
                          ws =
                            let
                              c = (x + 1) / 10;
                            in
                            builtins.toString (x + 1 - (c * 10));
                        in
                        ''
                          bind = $mod, ${ws}, workspace, ${toString (x + 1)}
                          bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
                        ''
                      ) 10
                    )}

                    exec-once = ${pkgs.swaybg}/bin/swaybg -o '*' -m fill -i '${context.variables.wallpaper}'
                    exec-once = ${context.variables.profileDir}/bin/service-group-once start
                    exec = ${context.variables.profileDir}/bin/service-group-always restart
                    ${lib.concatMapStringsSep "\n" (
                      e:
                      ''exec-once = ${lib.optionalString (builtins.hasAttr "workspace" e) "[workspace ${toString e.workspace}] "}${e.command}''
                    ) context.exec-once}
                    ${lib.concatMapStringsSep "\n" (
                      e:
                      ''exec = ${lib.optionalString (builtins.hasAttr "workspace" e) "[workspace ${toString e.workspace}] "}${e.command}''
                    ) context.exec}

                    windowrulev2 = nofullscreenrequest,floating:0
                    windowrulev2 = nomaximizerequest,floating:0
                    windowrulev2 = noshadow,floating:0

                    ${lib.concatMapStringsSep "\n" (p: ''
                      workspace = current, special:${p.name}
                      windowrulev2 = workspace special:${p.name}, class:(${p.class})
                      bind = ${toString p.mods}, ${p.key}, exec, ${p.exec}
                      bind = ${toString p.mods}, ${p.key}, togglespecialworkspace, ${p.name}
                    '') context.popups}

                    general {
                      gaps_in = 0
                      gaps_out = 0
                      col.active_border = rgba(66D9EFFF)
                    }

                    animations {
                      enabled = true
                      bezier = myBezier, 0.05, 0.9, 0.1, 1.05
                      animation = windows, 1, 3, myBezier
                      animation = windowsOut, 1, 3, default, popin 80%
                      animation = border, 1, 5, default
                      animation = borderangle, 1, 4, default
                      animation = fade, 1, 3, default
                      animation = workspaces, 1, 2, default
                      animation = specialWorkspace, 1, 2, default, slidefadeverty 20%
                    }

                    decoration {
                      blur {
                        enabled = false
                      }
                      drop_shadow = false
                    }

                    misc {
                      disable_hyprland_logo = true
                      key_press_enables_dpms = true
                    }
                  '';

                  services.swayidle = {
                    systemdTarget = context.variables.graphical.target;
                    #enable = true;
                    events = lib.mkDefault [
                      {
                        event = "before-sleep";
                        command = "${context.variables.profileDir}/bin/lockscreen";
                      }
                      {
                        event = "lock";
                        command = "${context.variables.profileDir}/bin/lockscreen";
                      }
                      {
                        event = "after-resume";
                        command = lib.concatMapStringsSep "; " (
                          o: ''${context.variables.graphical.exec} "output ${o.output} dpms on"''
                        ) context.variables.outputs;
                      }
                      {
                        event = "unlock";
                        command = lib.concatMapStringsSep "; " (
                          o: ''${context.variables.graphical.exec} "output ${o.output} dpms on"''
                        ) context.variables.outputs;
                      }
                    ];
                    timeouts = lib.mkDefault [
                      {
                        timeout = 120;
                        command = "${context.variables.profileDir}/bin/lockscreen";
                      }
                      {
                        timeout = 300;
                        command = lib.concatMapStringsSep "; " (
                          o: ''${context.variables.graphical.exec} "output ${o.output} dpms off"''
                        ) context.variables.outputs;
                        resumeCommand = lib.concatMapStringsSep "; " (
                          o: ''${context.variables.graphical.exec} "output ${o.output} dpms on"''
                        ) context.variables.outputs;
                      }
                      {
                        timeout = 3600;
                        command = "${sleepCmd}/bin/systemctl-sleep";
                      }
                    ];
                  };

                  #services.blueman-applet.enable = true;

                  programs.i3status-rust = {
                    #enable = false;
                    bars.default = {
                      blocks = [
                        {
                          block = "disk_space";
                          path = "/";
                          alias = "/";
                          info_type = "available";
                          unit = "GB";
                          interval = 60;
                          warning = 20.0;
                          alert = 10.0;
                        }
                        {
                          block = "memory";
                          display_type = "memory";
                          format_mem = "{mem_used_percents}";
                          format_swap = "{swap_used_percents}";
                        }
                        {
                          block = "cpu";
                          interval = 1;
                        }
                        {
                          block = "load";
                          interval = 1;
                          format = "{1m}";
                        }
                        { block = "sound"; }
                        {
                          block = "time";
                          interval = 60;
                          format = "%a %d.%m.%Y %R";
                        }
                      ];
                      settings = {
                        theme = {
                          name = "solarized-dark";
                          overrides = {
                            idle_bg = "#32302f";
                            idle_fg = "#abcdef";
                          };
                        };
                      };
                      icons = "material-nf";
                      theme = "gruvbox-dark";
                    };
                  };

                  # programs.waybar.enable = true;
                  programs.waybar.style = ''
                    * {
                        border: none;
                        border-radius: 0;
                        font-family: "${context.variables.font.family}", "Font Awesome 6 Free";
                        font-style: normal;
                        font-weight: bold;
                        font-size: 14px;
                        min-height: 0;
                        padding: 0;
                        color: white;
                    }

                    window#waybar {
                        background: rgba(50, 48, 47, 0.8);
                        border-bottom: 3px solid rgba(100, 90, 86, 0.8);
                        color: white;
                    }

                    tooltip {
                      background: rgba(50, 48, 47, 0.9);
                      border: 1px solid rgba(100, 90, 86, 0.9);
                    }
                    tooltip label {
                      color: white;
                    }

                    #workspaces button {
                        padding: 0 5px;
                        background: transparent;
                        border-bottom: 3px solid transparent;
                    }
                    #workspaces button.current_output label {
                        color: white;
                    }
                    #workspaces label {
                        color: gray;
                    }

                    #workspaces button.current_output.focused {
                        background: #666666;
                        border-bottom: 3px solid white;
                    }
                    #workspaces button.focused {
                        background: #444444;
                    }

                    #workspaces button.active label {
                        color: white;
                    }
                    #workspaces button.active {
                        background: #666666;
                        border-bottom: 3px solid white;
                    }

                    #workspaces button.current_output.visible {
                        border-bottom: 3px solid white;
                    }
                    #workspaces button.visible {
                        border-bottom: 3px solid #b3b3b3;
                    }

                    #workspaces button.urgent {
                        background: #F92672;
                    }

                    #mode,#submap,#clock,#battery,#taskbar,#pulseaudio,#idle_inhibitor,#keyboard-state,#bluetooth,#battery,#cpu,#temperature,#tray,#network,#custom-dnd,#custom-notification,#disk,#custom-weather,#custom-pipewire,#custom-temperature {
                        padding: 0 3px;
                    }

                    #custom-sep {
                        color: rgba(100, 90, 86, 0.6);
                    }

                    #window {
                        padding: 0 20px;
                    }

                    #battery {
                        color: white;
                    }

                    #battery.charging {
                        color: white;
                        background-color: #26A65B;
                    }

                    #battery.critical {
                         color: #e06c75;
                    }

                    #battery.full {
                        margin: 0px 0px 0px 0px;
                    }

                    @keyframes blink {
                        to {
                            background-color: #ffffff;
                            color: black;
                        }
                    }

                    #battery.warning:not(.charging) {
                        background: #f53c3c;
                        color: white;
                        animation-name: blink;
                        animation-duration: 0.5s;
                        animation-timing-function: linear;
                        animation-iteration-count: infinite;
                        animation-direction: alternate;
                    }

                    #temperature.critical {
                         color: #e06c75;
                    }

                    #custom-temperature.high {
                         color: #ffa500;
                    }
                    #custom-temperature.critical {
                         color: #ff0000;
                    }

                    #network.disconnected {
                      color: rgba(100, 90, 86, 1.0)
                    }
                    #bluetooth.on {
                      color: #008AD9
                    }
                    #bluetooth.connected {
                      color: #008AD9
                    }
                    #bluetooth.off {
                      color: rgba(100, 90, 86, 1.0)
                    }
                    #bluetooth.disabled {
                      color: rgba(100, 90, 86, 1.0)
                    }
                    #idle_inhibitor.activated {
                      color: #FEDD00
                    }
                    #idle_inhibitor.deactivated {
                      color: rgba(100, 90, 86, 1.0)
                    }
                  '';
                  programs.waybar.settings = {
                    mainBar =
                      {
                        layer = "top";
                        position = "bottom";
                        height = 26;
                        output = map (o: o.output) context.variables.outputs;
                        modules-left = [
                          "${context.variables.graphical.waybar.prefix}/workspaces"
                          "${context.variables.graphical.waybar.prefix}/${
                            if context.variables.graphical.name == "sway" then "mode" else "submap"
                          }"
                          "${context.variables.graphical.waybar.prefix}/window"
                        ];
                        modules-center = [
                        ];
                        modules-right = lib.flatten [
                          "custom/notification"
                          "custom/sep"
                          "idle_inhibitor"
                          "custom/sep"
                          "custom/pipewire"
                          "custom/sep"
                          "bluetooth"
                          "custom/sep"
                          "battery"
                          "custom/sep"
                          (lib.imap0 (i: _: [
                            "network#${toString i}"
                            "custom/sep"
                          ]) (context.variables.ethernetInterfaces ++ context.variables.wirelessInterfaces))
                          (lib.imap0 (i: _: [
                            "disk#${toString i}"
                            "custom/sep"
                          ]) context.variables.mounts)
                          "cpu"
                          "custom/sep"
                          (lib.imap0 (i: _: [
                            "custom/temperature#${toString i}"
                            "custom/sep"
                          ]) context.variables.temperatures)
                          "custom/weather"
                          "custom/sep"
                          "clock"
                          "custom/sep"
                          "tray"
                        ];
                        "custom/sep" = {
                          format = "";
                          interval = "once";
                          tooltip = false;
                        };
                        "custom/niri_workspaces" = {
                          format = "{}";
                          interval = 2;
                          return-type = "json";
                          exec = "${niriWorkspaces} \"$WAYBAR_OUTPUT_NAME\"";
                          on-scroll-up = "${niriWorkspaces} action focus-workspace-up";
                          on-scroll-down = "${niriWorkspaces} action focus-workspace-down";
                          signal = 9;
                        };
                        "${context.variables.graphical.waybar.prefix}/workspaces" = {
                          format = "{index}";
                          all-outputs = false;
                          show-special = lib.mkIf (context.variables.graphical.name == "hyprland") false;
                          active-only = lib.mkIf (context.variables.graphical.name == "hyprland") true;
                          on-scroll-up = "${niriWorkspaces} action focus-workspace-up";
                          on-scroll-down = "${niriWorkspaces} action focus-workspace-down";
                        };
                        "${context.variables.graphical.waybar.prefix}/window" = {
                          separate-outputs = true;
                        };
                        clock = {
                          format = "{:%a %d.%m.%Y, %H:%M}";
                          tooltip-format = "<tt><small>{calendar}</small></tt>";
                          calendar = {
                            mode = "year";
                            mode-mon-col = 3;
                            weeks-pos = "left";
                            on-scroll = 1;
                            on-click-right = "mode";
                            format = {
                              months = "<span color='#ffead3'><b>{}</b></span>";
                              days = "<span color='#FC9867'><b>{}</b></span>";
                              weeks = "<span color='#99ffdd'><b>{}</b></span>";
                              weekdays = "<span color='#FFD866'><b>{}</b></span>";
                              today = "<span color='#009933'><b>{}</b></span>";
                            };
                          };
                          actions = {
                            on-click-right = "mode";
                            on-click-forward = "tz_up";
                            on-click-backward = "tz_down";
                            on-scroll-up = "shift_up";
                            on-scroll-down = "shift_down";
                          };
                        };
                        pulseaudio = {
                          scroll-step = 3.0;
                          format = "{volume}% {icon}";
                          format-bluetooth = "{volume}% {icon}";
                          format-muted = "";
                          format-icons = {
                            headphone = "";
                            hands-free = "";
                            headset = "";
                            phone = "";
                            portable = "";
                            car = "";
                            default = [
                              ""
                              ""
                            ];
                          };
                          on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
                          on-click-middle = "${pkgs.helvum}/bin/helvum";
                          # on-click-right = "${pkgs.easyeffects}/bin/easyeffects";
                        };
                        "custom/pipewire" = {
                          exec = "${wp_volume}";
                          interval = 5;
                          tooltip = false;
                          on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar";
                          on-click-middle = "${pkgs.helvum}/bin/helvum";
                          on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
                          on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 3%+; ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar";
                          on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-; ${pkgs.procps}/bin/pkill -SIGRTMIN+8 waybar";
                          signal = 8;
                        };
                        keyboard-state = {
                          capslock = true;
                          format = "{name} {icon}";
                          format-icons = {
                            locked = "";
                            unlocked = "";
                          };
                        };
                        bluetooth = {
                          format = " {status}";
                          format-disabled = " off";
                          format-connected = " {num_connections}";
                          tooltip-format = "{controller_alias}\t{controller_address}";
                          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
                          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
                          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
                          #on-click-right = "${blueman}/bin/blueman-manager";
                          on-click-right = "${pkgs.blueberry}/bin/blueberry";
                        };
                        cpu = {
                          format = "{icon}";
                          format-icons = [
                            "<span color='#f8f8f2'>▁</span>"
                            "<span color='#f8f8f2'>▂</span>"
                            "<span color='#f8f8f2'>▃</span>"
                            "<span color='#f8f8f2'>▄</span>" # white
                            "<span color='#ffffa5'>▅</span>" # yellow
                            "<span color='#ffffa5'>▆</span>" # yellow
                            "<span color='#ff9977'>▇</span>" # orange
                            "<span color='#dd532e'>█</span>" # red
                          ];
                        };
                        temperature = {
                          format = "{temperatureC}°C {icon}";
                          format-icons = [
                            ""
                            ""
                            ""
                            ""
                            ""
                          ];
                          critical-threshold = 80;
                          hwmon-path = lib.mkIf (builtins.hasAttr "hwmonPath" context.variables) context.variables.hwmonPath;
                        };
                        idle_inhibitor = {
                          format = "{icon}";
                          format-icons = {
                            activated = "";
                            deactivated = "";
                          };
                        };
                        # "custom/dnd" = {
                        #   interval = "once";
                        #   return-type = "json";
                        #   format = "{}{icon}";
                        #   format-icons = {
                        #       default = "";
                        #       dnd = "ﮡ";
                        #   };
                        #   on-click = "${pkgs.mako}/bin/makoctl mode | ${pkgs.gnugrep}/bin/grep 'do-not-disturb' && ${pkgs.mako}/bin/makoctl mode -r do-not-disturb || ${pkgs.mako}/bin/makoctl mode -a do-not-disturb; ${pkgs.procps}/bin/pkill -RTMIN+11 waybar";
                        #   exec = ''${pkgs.coreutils}/bin/printf '{\"alt\":\"%s\",\"tooltip\":\"mode: %s\"}' $(${pkgs.mako}/bin/makoctl mode | ${pkgs.gnugrep}/bin/grep -q 'do-not-disturb' && echo dnd || echo default) $(${pkgs.mako}/bin/makoctl mode | ${pkgs.coreutils}/bin/tail -1)'';
                        #   signal = 11;
                        # };
                        "custom/notification" = {
                          "tooltip" = false;
                          "format" = "{} {icon}";
                          "format-icons" = {
                            "notification" = "<span foreground='red'><sup></sup></span>";
                            "none" = "";
                            "dnd-notification" = "<span foreground='red'><sup></sup></span>";
                            "dnd-none" = "";
                          };
                          "return-type" = "json";
                          "exec" = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
                          "on-click" = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
                          "on-click-right" = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
                          "escape" = true;
                        };
                        "custom/weather" = {
                          format = "{}°C";
                          tooltip = true;
                          interval = 3600;
                          exec = "${pkgs.wttrbar}/bin/wttrbar --date-format '%d.%m.%Y' --hide-conditions";
                          return-type = "json";
                        };
                        "custom/temperature" = {
                          format = "{icon} {}°C";
                          tooltip = false;
                          exec = "${getTemperature "coretemp-isa-0000" "Package id 0" "temp1"}";
                          format-icons = [
                            ""
                            ""
                            ""
                            ""
                            ""
                          ];
                          return-type = "json";
                        };
                        battery = {
                          interval = 60;
                          states = {
                            warning = 30;
                            critical = 15;
                          };
                          format = "{capacity}% {icon}";
                          format-icons = [
                            ""
                            ""
                            ""
                            ""
                            ""
                          ];
                          max-length = 25;
                        };
                      }
                      // lib.listToAttrs (
                        lib.imap0 (i: v: {
                          name = "disk#${toString i}";
                          value = {
                            format = "${v}:{percentage_used}%";
                            path = v;
                          };
                        }) context.variables.mounts
                      )
                      // lib.listToAttrs (
                        lib.imap0 (i: v: {
                          name = "custom/temperature#${toString i}";
                          value = {
                            format = "{icon} {}°C";
                            exec = "${getTemperature v.device v.group v.field_prefix}";
                            format-icons = [
                              ""
                              ""
                              ""
                              ""
                              ""
                            ];
                            return-type = "json";
                          };
                        }) context.variables.temperatures
                      )
                      // lib.listToAttrs (
                        lib.imap0 (i: v: {
                          name = "network#${toString i}";
                          value = {
                            interface = v;
                            format = "{ifname}";
                            format-wifi = "{essid} ({signalStrength}%) ";
                            format-ethernet = "{ifname} ";
                            format-disconnected = "{ifname}";
                            tooltip-format = "{ifname} via {gwaddr} ";
                            tooltip-format-wifi = "{essid} ({signalStrength}%) ";
                            tooltip-format-ethernet = "{ipaddr}/{cidr} ";
                            tooltip-format-disconnected = "Disconnected";
                            max-length = 50;
                            #on-click-right = "${connman-gtk}/bin/connman-gtk";
                          };
                        }) (context.variables.ethernetInterfaces ++ context.variables.wirelessInterfaces)
                      );
                  };
                  #programs.waybar.systemd.target = context.variables.graphical.target;
                  #systemd.user.services.waybar.Service.RestartSec = 1;
                  #systemd.user.services.waybar.Service.Environment = "PATH=${pkgs.jq}/bin:${pkgs.systemd}/bin";

                  #services.nextcloud-client.enable = true;
                  #services.nextcloud-client.startInBackground = true;
                  #systemd.user.services.nextcloud-client.Service.ExecStart = mkForce (exec "${nextcloud-client}/bin/nextcloud --background");
                  systemd.user.services.network-manager-applet.Service.ExecStart =
                    lib.mkForce "${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
                  systemd.user.services.network-manager-applet.Unit.Requires = lib.mkForce [
                    "graphical-session-pre.target"
                  ];

                  services.syncthing.extraOptions = [
                    "--gui-address=127.0.0.1:8384"
                    "--home=${context.variables.homeDir}/Syncthing/.config/syncthing"
                  ];

                  programs.gpg = {
                    enable = true;
                  };
                  services.gpg-agent = {
                    enable = true;
                    enableZshIntegration = true;
                    pinentry.package = pkgs.pinentry-curses;
                  };
                  services.ssh-agent.enable = true;
                  programs.ssh = {
                    enable = true;
                    enableDefaultConfig = false;
                    matchBlocks."*".addKeysToAgent = "10m";
                  };

                  programs.bash = {
                    enable = true;
                    enableVteIntegration = true;
                    historyControl = [
                      "erasedups"
                      "ignorespace"
                    ];
                  };

                  programs.zsh = {
                    enable = true;
                    enableVteIntegration = true;
                    initContent = ''
                      . "${dotFileAt "zsh.nix" 0}" || true

                      . "${pkgs.nix}/etc/profile.d/nix.sh"

                      unset __HM_SESS_VARS_SOURCED
                      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" || true
                    '';
                    loginExtra = ''
                      . "${dotFileAt "zsh.nix" 1}" || true
                    '';
                    envExtra = ''
                      setopt no_global_rcs
                      unset __HM_ZSH_SESS_VARS_SOURCED
                    '';
                    history = {
                      expireDuplicatesFirst = true;
                      extended = true;
                    };
                    historySubstringSearch = {
                      enable = true;
                      searchUpKey = "^[[A";
                      searchDownKey = "^[[B";
                    };
                    syntaxHighlighting.enable = true;
                    autosuggestion.enable = true;
                    autocd = true;
                    defaultKeymap = "emacs";
                  };
                  programs.starship = {
                    enable = true;
                    enableZshIntegration = true;
                    settings = {
                      command_timeout = 2000;
                      character.success_symbol = "[❯](bold green) ";
                      character.error_symbol = "[✗](bold red) ";
                      status.disabled = false;
                      status.style = "fg:red";
                      status.format = "[\\[$common_meaning$signal_name$maybe_int\\]]($style) ";
                    };
                  };
                  # programs.atuin = {
                  #   enable = true;
                  #   # enableZshIntegration = true;
                  #   settings = {
                  #     auto_sync = false;
                  #     sync_address = "";
                  #     update_check = false;
                  #     inline_height = 11;
                  #     style = "compact";
                  #     show_help = false;
                  #   };
                  # };
                  programs.fzf = {
                    enable = true;
                    enableZshIntegration = true;
                    defaultOptions = [
                      "--no-info"
                    ];
                    colors = {
                      hl = "#FC9867";
                      "hl+" = "#FC9867";
                    };
                  };
                  programs.direnv = {
                    enable = true;
                    enableZshIntegration = true;
                  };
                  home.shellAliases = {
                    ".." = "cd ..";
                    "l" = "${pkgs.eza}/bin/eza -gal --git";
                    "t" = "${pkgs.eza}/bin/eza -T --ignore-glob='.git' -L3";
                    "c" = "${pkgs.bat}/bin/bat";
                    "d" = "${pkgs.delta}/bin/delta";
                    "g" = "${pkgs.git-igitt}/bin/git-igitt";
                  };
                  programs.zellij = {
                    enable = true;
                    enableZshIntegration = false;
                    enableBashIntegration = false;
                    # settings = {
                    #   simplified_ui = true;
                    #   default_layout = "compact";
                    #   copy_command = "${pkgs.wl-clipboard}/bin/wl-copy";
                    #   default_shell = "${context.variables.shell}";
                    #   pane_frames = false;
                    #   copy_on_select = false;
                    #   keybinds = {
                    #     # unbind = [ "Ctrl t" "Ctrl s" "Ctrl g" "Ctrl n" "Ctrl q" "Ctrl o" "Ctrl p" "Ctrl h" "Ctrl b" ];
                    #     unbind = true;
                    #     normal = {
                    #       "bind \"Ctrl C\"" = "Copy;";
                    #     };
                    #   };
                    # };
                  };
                  programs.yazi = {
                    enable = true;
                    enableZshIntegration = true;
                  };
                  programs.broot = {
                    enableZshIntegration = true;
                    settings = {
                      default_flags = "--sort-by-date --show-git-info --git-ignored --sizes --hidden";
                      verbs = [
                        {
                          invocation = "open";
                          key = "enter";
                          execution = ":open_stay";
                          apply_to = "file";
                        }
                        {
                          key = "enter";
                          execution = ":focus";
                          apply_to = "directory";
                        }
                        {
                          key = "right";
                          execution = ":focus";
                          apply_to = "directory";
                        }
                        {
                          key = "left";
                          execution = ":parent";
                        }
                        {
                          invocation = "edit";
                          key = "ctrl-enter";
                          execution = "$EDITOR {file}";
                          apply_to = "text_file";
                          from_shell = true;
                        }
                      ];
                    };
                  };
                  programs.foot = {
                    settings = {
                      main = {
                        term = "xterm-256color";
                        font = "${context.variables.font.family}:size=${toString context.variables.font.size}";
                        dpi-aware = "no";
                        # shell="${context.variables.shell} -c 'sleep 0.1; ${pkgs.zellij}/bin/zellij'";
                      };
                      mouse = {
                        hide-when-typing = "no";
                      };
                      colors = {
                        alpha = 0.9;
                        background = "20211d";
                        foreground = "FCFCFA";
                        regular0 = "403E41";
                        regular1 = "FF6188";
                        regular2 = "A9DC76";
                        regular3 = "FFD866";
                        regular4 = "FC9867";
                        regular5 = "AB9DF2";
                        regular6 = "78DCE8";
                        regular7 = "FCFCFA";
                        bright0 = "727072";
                        bright1 = "FF6188";
                        bright2 = "A9DC76";
                        bright3 = "FFD866";
                        bright4 = "FC9867";
                        bright5 = "AB9DF2";
                        bright6 = "78DCE8";
                        bright7 = "FCFCFA";
                      };
                    };
                  };
                  # services.swayosd = {
                  #   enable = true;
                  # };
                  services.swaync = {
                    # enable = true;
                    settings = {
                      "\$schema" = "${pkgs.swaynotificationcenter}/etc/xdg/swaync/configSchema.json";
                      control-center-height = 600;
                      control-center-margin-bottom = 20;
                      control-center-margin-left = 20;
                      control-center-margin-right = 20;
                      control-center-margin-top = 20;
                      control-center-width = 600;
                      cssPriority = "user";
                      fit-to-screen = true;
                      hide-on-action = true;
                      hide-on-clear = false;
                      image-visibility = "when-available";
                      keyboard-shortcuts = true;
                      layer = "top";
                      notification-body-image-height = 100;
                      notification-body-image-width = 200;
                      notification-icon-size = 64;
                      notification-visibility = {
                        #example-name = {
                        #  app-name = "Spotify";
                        #  state = "muted";
                        #  urgency = "Low";
                        #};
                      };
                      notification-window-width = 500;
                      positionX = "right";
                      positionY = "top";
                      script-fail-notify = true;
                      scripts = {
                        #example-script = {
                        #  exec = "echo 'Do something...'";
                        #  urgency = "Normal";
                        #};
                      };
                      timeout = 10;
                      timeout-critical = 0;
                      timeout-low = 5;
                      transition-time = 200;
                      widget-config = {
                        dnd = {
                          text = "Do Not Disturb";
                        };
                        label = {
                          max-lines = 5;
                          text = "Label Text";
                        };
                        mpris = {
                          image-radius = 12;
                          image-size = 96;
                        };
                        title = {
                          button-text = "Clear All";
                          clear-all-button = true;
                          text = "Notifications";
                        };
                      };
                      widgets = [
                        "title"
                        "dnd"
                        "notifications"
                        "mpris"
                      ];
                    };
                    style =
                      builtins.replaceStrings
                        [ "1.1rem" "1.25rem" "1.5rem" "font-size: 16px" "font-size: 15px" ]
                        [ "0.9rem" "1.1rem" "1.2rem" "font-size: 13px" "font-size: 11px" ]
                        (lib.readFile "${pkgs.swaynotificationcenter}/etc/xdg/swaync/style.css");
                  };

                  # services.wpaperd = {
                  #   enable = true;
                  #   settings = builtins.listToAttrs (map (o: lib.nameValuePair o.output {
                  #     path = o.wallpaper;
                  #     mode = "center";
                  #   }) context.variables.outputs);
                  # };

                  # services.hyprpaper = {
                  #   enable = true;
                  #   settings = {
                  #     preload = map (o: o.wallpaper) context.variables.outputs;
                  #     wallpaper = map (o: "${o.output},${o.wallpaper}") context.variables.outputs;
                  #   };
                  # };

                  # services.wlsunset = {
                  #   enable = true;
                  #   # curl -s http://ip-api.com/json/
                  #   latitude = 60.2;
                  #   longitude = 24.9;
                  #   temperature = {
                  #     day = 5500;
                  #     night = 3700;
                  #   };
                  # };
                }
                (lib.optionalAttrs (context.variables.graphical.name == "niri") (lib.mkMerge [{
                  home.packages = with pkgs; [
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
                  ];
                  programs.niri.package = pkgs.niri;  # use in-nixpkgs niri, related to https://github.com/sodiboo/niri-flake/issues/990
                  programs.niri.config = let
                    noctalia-shell = "${pkgs.noctalia-shell}/bin/noctalia-shell";
                  in ''
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
                    '') context.variables.outputs}

                    workspace "first" {
                      open-on-output "${(builtins.head context.variables.outputs).output}"
                    }
                    window-rule {
                      match app-id="org.keepassxc.KeePassXC"
                      match app-id="Logseq"
                      open-on-workspace "first"
                    }

                    workspace "second" {
                      open-on-output "${(builtins.head context.variables.outputs).output}"
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
                    spawn-at-startup "${configure-gtk}/bin/configure-gtk"
                    spawn-at-startup "${pkgs.stdenv.shell}" "-c" "${context.variables.profileDir}/bin/service-group-always restart"

                    ${lib.concatMapStringsSep "\n" (i: ''
                      spawn-at-startup "${pkgs.stdenv.shell}" "-c" "${i}"
                    '') (pkgs.lib.optionals (context.variables ? startup) context.variables.startup)}

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
                    screenshot-path "~/Pictures/Screenshot from %Y-%m-%d %H-%M-%S.png"

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
                        Ctrl+Alt+T { spawn "${context.variables.programs.terminal}"; }
                        Ctrl+Alt+H { spawn "${context.variables.programs.filemanager}"; }
                        Ctrl+Alt+Space { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call launcher toggle"; }
                        Ctrl+Alt+L { spawn "${context.variables.lockscreen}"; }
                        Super+L { spawn "${context.variables.lockscreen}"; }
                        Ctrl+Alt+Delete { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call powerPanel toggle"; }
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
                        Super+Minus { set-column-width "-10%"; }
                        Super+Equal { set-column-width "+10%"; }

                        // Finer height adjustments when in column with other windows.
                        Super+Ctrl+Minus { set-window-height "-10%"; }
                        Super+Ctrl+Equal { set-window-height "+10%"; }

                        // Actions to switch layouts.
                        // Note: if you uncomment these, make sure you do NOT have
                        // a matching layout switch hotkey configured in xkb options above.
                        // Having both at once on the same hotkey will break the switching,
                        // since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
                        // Mod+Space       { switch-layout "next"; }
                        // Mod+Shift+Space { switch-layout "prev"; }

                        Shift+Print { screenshot; }
                        Alt+Print { screenshot-window; }

                        Super+Shift+E { quit; }
                        // Mod+Shift+P { power-off-monitors; }

                        // Mod+Shift+Ctrl+T { toggle-debug-tint; }

                        Super+P allow-when-locked=true { spawn "${context.variables.graphical.exec}" "msg" "output" "${(lib.head context.variables.outputs).output}" "on"; }
                        Super+Shift+P { spawn "${context.variables.graphical.exec}" "msg" "output" "${(lib.head context.variables.outputs).output}" "off"; }

                        Ctrl+Alt+C { spawn "bash" "-c" "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.tesseract5}/bin/tesseract stdin stdout | ${pkgs.wl-clipboard}/bin/wl-copy"; }
                        Super+C { spawn "${pkgs.stdenv.shell}" "-c" "${noctalia-shell} ipc call launcher clipboard"; }
                        Super+Shift+C { spawn "bash" "-c" "env XDG_CACHE_HOME=${context.variables.homeDir}/.cache cliphist wipe"; }
                        Ctrl+Alt+S { spawn "bash" "-c" "${setDefaultSink}"; }
                        Ctrl+Alt+Shift+S { spawn "bash" "-c" "${setDefaultSource}"; }
                        Ctrl+Alt+R { spawn "bash" "-c" "${recordCmd}"; }
                        Ctrl+Alt+M { spawn "bash" "-c" "${pkgs.wl-mirror}/bin/wl-mirror --fullscreen ${(lib.head context.variables.outputs).output}"; }
                        Ctrl+Alt+Shift+M { spawn "bash" "-c" "${pkgs.procps}/bin/pkill wl-mirror"; }

                        Super+O repeat=false { toggle-overview; }
                        Super+Tab repeat=false { switch-focus-between-floating-and-tiling; }
                    }

                    environment {
                        DISPLAY ":0"
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
                      ExecStart = "${context.variables.profileDir}/bin/lockscreen";
                    };
                  };
                  systemd.user.services.xwayland-satellite = {
                    Unit = {
                      Description = "XWayland Satellite User Service";
                      BindsTo = [ context.variables.graphical.target ];
                      PartOf = [ context.variables.graphical.target ];
                      After = [ context.variables.graphical.target ];
                      Requisite = [ context.variables.graphical.target ];
                    };
                    Install.WantedBy = [ context.variables.graphical.target ];
                    Service = {
                      Type = "notify";
                      NotifyAccess = "all";
                      ExecStart = "${pkgs.xwayland-satellite-unstable}/bin/xwayland-satellite";
                    };
                  };
                  systemd.user.services.noctalia-shell = {
                    Unit = {
                      Description = "Noctalia Shell User Service";
                      BindsTo = [ context.variables.graphical.target ];
                      PartOf = [ context.variables.graphical.target ];
                      After = [ context.variables.graphical.target ];
                      Requisite = [ context.variables.graphical.target ];
                    };
                    Install.WantedBy = [ context.variables.graphical.target ];
                    Service = {
                      Type = "simple";
                      ExecStartPre = "${noctaliaShellStartPreSh}";
                      ExecStart = "${pkgs.noctalia-shell}/bin/noctalia-shell";
                    };
                  };
                  services.swayidle = {
                    events = lib.mkOverride 900 [
                      {
                        event = "before-sleep";
                        command = "${context.variables.lockscreen}";
                      }
                      {
                        event = "after-resume";
                        command = "${context.variables.lockscreen}";
                      }
                      {
                        event = "lock";
                        command = "${context.variables.lockscreen}";
                      }
                      # { event = "after-resume"; command = lib.concatMapStringsSep "; " (o: ''${context.variables.graphical.exec} msg output ${o.output} on'') context.variables.outputs; }
                      # { event = "unlock"; command = lib.concatMapStringsSep "; " (o: ''${context.variables.graphical.exec} msg output ${o.output} on'') context.variables.outputs; }
                      # { event = "unlock"; command = "${pkgs.systemd}/bin/systemctl --user restart waybar"; }
                    ];
                    timeouts = lib.mkOverride 900 [
                      {
                        timeout = 100;
                        command = "${pkgs.noctalia-shell} ipc call brightness decrease";
                        resumeCommand = "${pkgs.noctalia-shell} ipc call brightness increase";
                      }
                      {
                        timeout = 120;
                        command = "${context.variables.lockscreen}";
                      }
                      {
                        timeout = 300;
                        command = ''${context.variables.graphical.exec} msg action power-off-monitors'';
                        # resumeCommand = lib.concatMapStringsSep "; " (o: ''${context.variables.graphical.exec} msg output ${o.output} on'') context.variables.outputs;
                      }
                      {
                        timeout = 3600;
                        command = "${sleepCmd}/bin/systemctl-sleep";
                      }
                    ];
                  };

                  programs.waybar.systemd.enable = false;

                  # systemd.user.services.swayidle.Service.Environment = [ "WAYLAND_DISPLAY=wayland-1" ];
                  systemd.user.services.swayidle.Unit.ConditionEnvironment = lib.mkForce [ ];

                  # systemd.user.services.cliphist-text = {
                  #   Unit = {
                  #     Description = "Cliphist (text) User Service";
                  #     After = [ context.variables.graphical.target ];
                  #   };
                  #   Install.WantedBy = [ context.variables.graphical.target ];
                  #   Service = {
                  #     Type = "simple";
                  #     ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
                  #   };
                  # };
                  # systemd.user.services.cliphist-image = {
                  #   Unit = {
                  #     Description = "Cliphist (image) User Service";
                  #     After = [ context.variables.graphical.target ];
                  #   };
                  #   Install.WantedBy = [ context.variables.graphical.target ];
                  #   Service = {
                  #     Type = "simple";
                  #     ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
                  #   };
                  # };
                } {
                  systemd.user.services = builtins.listToAttrs (map (o: {
                    name = "wallpaper-${o.output}";
                    value = {
                      Unit = {
                        Description = "Wallpaper for ${o.output} User Service";
                        After = [ "noctalia-shell.service" ];
                      };
                      Install.WantedBy = [ "noctalia-shell.service" ];
                      Service = {
                        Type = "oneshot";
                        ExecStart = "${inputs.noctalia.packages.${pkgs.system}.default}/bin/noctalia-shell ipc call wallpaper set ${o.wallpaper} ${o.output}";
                      };
                    };
                  }) context.variables.outputs);
                }]))
              ]
              ++ [ context.home-configuration ]
            );
          };
      }
    ]
    ++ [ context.nixos-configuration ]
  );
}
