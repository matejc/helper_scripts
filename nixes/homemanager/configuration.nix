{ inputs, contextFile }:
{ pkgs, lib, config, ... }:
with pkgs;
let
  helper_scripts = ../..;

  context = import contextFile { inherit pkgs lib config inputs dotFileAt helper_scripts; };

  nur = import inputs.nur { nurpkgs = pkgs; inherit pkgs; };

  dotfiles = import "${helper_scripts}/dotfiles/default.nix"
    { name = "homemanager"; exposeScript = true; inherit context; }
    { inherit pkgs lib config; };

  dotFileAt = file: at:
    (lib.elemAt (import "${helper_scripts}/dotfiles/${file}" { inherit lib pkgs; inherit (context) variables config; }) at).source;

  services-cmds = map (group: writeScriptBin "service-group-${group}" ''
    #!${context.variables.shell}
    source "${context.variables.shellRc}"
    ${lib.concatMapStringsSep "\n" (s: ''{ sleep ${toString s.delay} && systemctl --user "$1" "${s.name}"; } &'') context.services}
    wait
  '') (map (s: s.group) context.services);

  sway-workspace = rustPlatform.buildRustPackage {
    name = "sway-workspace";
    src = inputs.sway-workspace;
    cargoSha256 = "sha256-DRUd2nSdfgiIiCrBUiF6UTPYb6i8POQGo1xU5CdXuUY=";
  };

  swayest = rustPlatform.buildRustPackage {
    name = "swayest";
    src = inputs.swayest;
    cargoSha256 = "sha256-B1dRU3cqDuQi/kXDbRAvNf+wnut+wpFXf7Lq54Xav9A=";
  };

  sway-scratchpad = rustPlatform.buildRustPackage {
    name = "sway-scratchpad";
    src = inputs.sway-scratchpad;
    cargoSha256 = "sha256-7MVAXThypxXF2wp6hFirqQeb8al/NuW2E2xGPK2ewT0=";
  };

  swayncConfig = {
    "\$schema" = "${swaynotificationcenter}/etc/xdg/swaync/configSchema.json";
    control-center-height = 600;
    control-center-margin-bottom = 0;
    control-center-margin-left = 0;
    control-center-margin-right = 0;
    control-center-margin-top = 0;
    control-center-width = 500;
    cssPriority = "application";
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
    widgets = [ "title" "dnd" "notifications" "mpris" ];
  };

  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;
    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Breeze-Dark'
    '';
  };

  nixmyConfig = {
    nixpkgs = context.variables.nixmy.nixpkgs;
    remote = context.variables.nixmy.remote;
    backup = context.variables.nixmy.backup;
    nixosConfig = "/etc/nixos/configuration.nix";
    extraPaths = [ pkgs.gnumake ];
    nix = pkgs.nix;
  };

  setDefaultSink = pkgs.writeShellScript "set-default-sink" ''
    ${pkgs.pulseaudio}/bin/pactl set-default-sink $(${pkgs.pulseaudio}/bin/pactl list short sinks | ${pkgs.gawk}/bin/awk -v def_sink="$(${pkgs.pulseaudio}/bin/pactl get-default-sink)" '{if ($2 == def_sink) {print $2" / "$NF" / DEFAULT"} else {print $2" / "$NF}}' | ${pkgs.wofi}/bin/wofi -W 70% -p Speaker -i --dmenu | ${pkgs.gawk}/bin/awk '{printf $1}')
  '';

  setDefaultSource = pkgs.writeShellScript "set-default-source" ''
    ${pkgs.pulseaudio}/bin/pactl set-default-source $(${pkgs.pulseaudio}/bin/pactl list short sources | ${pkgs.gawk}/bin/awk -v def_src="$(${pkgs.pulseaudio}/bin/pactl get-default-source)" '/source/ {if ($2 == def_src) {print $2" / "$NF" / DEFAULT"} else {print $2" / "$NF}}' | ${pkgs.wofi}/bin/wofi -W 70% -p Mic -i --dmenu | ${pkgs.gawk}/bin/awk '{printf $1}')
  '';

  wp_volume = pkgs.writeShellScript "wp_volume" ''
    set -e

    # https://blog.dhampir.no/content/sleeping-without-a-subprocess-in-bash-and-how-to-sleep-forever
    snore() {
        local IFS
        [[ -n "''${_snore_fd:-}" ]] || exec {_snore_fd}<> <(:)
        read -r ''${1:+-t "$1"} -u $_snore_fd || :
    }

    DELAY=0.2

    while snore $DELAY; do
        WP_OUTPUT=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)

        if [[ $WP_OUTPUT =~ ^Volume:[[:blank:]]([0-9]+)\.([0-9]{2})([[:blank:]].MUTED.)?$ ]]; then
            if [[ -n ''${BASH_REMATCH[3]} ]]; then
                printf "MUTE\n"
            else
                VOLUME=$((10#''${BASH_REMATCH[1]}''${BASH_REMATCH[2]}))
                ICON=(
                    ""
                    ""
                    ""
                )

                if [[ $VOLUME -gt 50 ]]; then
                    printf "%s" "''${ICON[0]} "
                elif [[ $VOLUME -gt 25 ]]; then
                    printf "%s" "''${ICON[1]} "
                elif [[ $VOLUME -ge 0 ]]; then
                    printf "%s" "''${ICON[2]} "
                fi

                printf "$VOLUME%%\n"
            fi
        fi
    done

    exit 0
  '';

  chooserCmd = pkgs.writeShellScriptBin "sway-wsshare-chooser" ''
    export PATH="${pkgs.sway}/bin:${pkgs.jq}/bin:${pkgs.wofi}/bin:${pkgs.coreutils}/bin:$PATH"
    export SWAYSOCK="$(ls /run/user/"$(id -u)"/sway-ipc.* | head -n 1)"
    swaymsg -t get_outputs | jq -r '.[]|.name' | wofi -d
  '';
in {
  config = lib.mkMerge ([{
    xdg.portal = {
      enable = true;
      wlr = {
        enable = true;
        settings.screencast = {
          max_fps = 30;
          chooser_type = pkgs.lib.mkDefault "dmenu";
          chooser_cmd = pkgs.lib.mkDefault "${chooserCmd}";
        };
      };
    };
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 90;
        STOP_CHARGE_THRESH_BAT0 = 95;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = false;
    home-manager.users.matejc = { config, ... }: {
      # imports = [
      #   inputs.hyprland.homeManagerModules.default
      # ];
      config = lib.mkMerge ([{
        nixpkgs.config = import "${helper_scripts}/dotfiles/nixpkgs-config.nix";

        home.file.default-cursor = {
          source = "${config.gtk.cursorTheme.package}/share/icons/${config.gtk.cursorTheme.name}";
          target = ".icons/default";
        };

        home.file.nixpkgs-config = {
          source = "${helper_scripts}/dotfiles/nixpkgs-config.nix";
          target = ".config/nixpkgs/config.nix";
        };

        xdg = {
          enable = true;
          #configFile."nixpkgs/config.nix".source = "nixpkgs-config.nix";
          configFile."swaync/config.json".text = builtins.toJSON swayncConfig;
          configFile."swaync/style.css".text = builtins.replaceStrings ["1.1rem" "1.25rem" "1.5rem" "font-size: 16px" "font-size: 15px"] ["0.9rem" "1.1rem" "1.2rem" "font-size: 13px" "font-size: 11px"] (lib.readFile "${swaynotificationcenter}/etc/xdg/swaync/style.css");
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
          systemDirs.config = [ "${swaynotificationcenter}/etc/xdg" ];
          mime.enable = true;
          mimeApps = {
            enable = true;
            defaultApplications = {
              "x-scheme-handler/https" = [ "browser.desktop" ];
              "x-scheme-handler/http" = [ "browser.desktop" ];
            };
          };
          desktopEntries = {
            browser = {
              name = "Web Browser";
              genericName = "Web Browser";
              exec = "${context.variables.binDir}/browser %U";
              terminal = false;
              categories = [ "Application" "Network" "WebBrowser" ];
              mimeType = [ "x-scheme-handler/https" "x-scheme-handler/http" ];
            };
          };
        };

        services.gnome-keyring = {
          enable = true;
        };
        #systemd.user.services.gnome-keyring.Service.ExecStart = mkForce "/wrappers/gnome-keyring-daemon --start --foreground --components=secrets";

        fonts.fontconfig.enable = lib.mkForce true;
        home.packages = [
          font-awesome
          config.gtk.font.package
          noto-fonts-emoji
          git git-crypt
          zsh
          wl-clipboard
          xdg-utils
          dconf
          rofi
          (import "${inputs.nixmy}/nixmy.nix" { inherit pkgs nixmyConfig; })
        ] ++ services-cmds;
        home.sessionVariables = {
          #NVIM_QT_PATH = "/mnt/c/tools/neovim-qt/bin/nvim-qt.exe";
          QT_PLUGIN_PATH = "${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}";
          QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}";
          SDL_VIDEODRIVER = "wayland";
          QT_QPA_PLATFORM = "wayland";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          _JAVA_AWT_WM_NONREPARENTING = "1";
          GTK_USE_PORTAL = "1";
          #NIXOS_XDG_OPEN_USE_PORTAL = "1";
          MOZ_ENABLE_WAYLAND = "1";
        };
        home.sessionPath = [ "${config.home.homeDirectory}/bin" ];

        gtk = {
          enable = true;
          font = {
            package = nerdfonts.override { fonts = [ "SourceCodePro" "FiraCode" "FiraMono" ]; };
            name = context.variables.font.family;
            size = builtins.floor context.variables.font.size;
          };
          iconTheme = {
            name = "breeze-dark";
            package = breeze-icons;
          };
          theme = {
            name = "Breeze-Dark";
            package = breeze-gtk;
          };
          cursorTheme = {
            name = "Vanilla-DMZ";
            package = vanilla-dmz;
            size = 16;
          };
        };

        programs.chromium = {
          extensions = [
            "gcbommkclmclpchllfjekcdonpmejbdp"  # https everywhere
            "cjpalhdlnbpafiamejdnhcphjbkeiagm"  # ublock origin
            "oboonakemofpalcgghocfoadofidjkkk"  # keepassxc
            "clpapnmmlmecieknddelobgikompchkk"  # disable automatic gain control
          ];
        };

        programs.firefox = {
          profiles = {
            default = {
              extensions = with nur.repos.rycee.firefox-addons; [
                ublock-origin keepassxc-browser translate-web-pages multi-account-containers
              ];
              settings = {
                "general.smoothScroll" = false;
                "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
                "ui.textScaleFactor" = 90;
              };
              userChrome = ''
                * {
                   font-size: ${toString context.variables.font.size}pt !important;
                }
                #TabsToolbar, .tabbrowser-tab { max-height: 36px !important; }
                #TabsToolbar > .toolbar-items > spacer { display: none; }
                #TabsToolbar .tabs-newtab-button,
                #TabsToolbar .tabbrowser-tab,
                #TabsToolbar .tabbrowser-tab .tab-stack,
                #TabsToolbar .tabbrowser-tab .tab-background,
                #TabsToolbar .tabbrowser-tab .tab-content {
                    border-top-left-radius: 0 !important;
                    border-top-right-radius: 0 !important;
                }
              '';
            };
          };
        };

        programs.htop.enable = true;

        programs.home-manager = {
          enable = true;
        };
        home.username = "matejc";
        home.homeDirectory = "/home/matejc";

        services.kanshi = {
          systemdTarget = context.variables.graphical.target;
          profiles.firstonly = {
            outputs = lib.imap0 (i: o: { inherit (o) criteria position mode scale; status = if i == 0 then "enable" else "disable"; }) context.variables.outputs;
          };
          profiles.default = {
            outputs = map (o: { inherit (o) criteria position mode scale status; }) context.variables.outputs;
          };
          profiles.all = {
            outputs = map (o: { inherit (o) criteria position mode scale; status = "enable"; }) context.variables.outputs;
          };
        };

        services.kdeconnect = {
          #enable = true;
          #indicator = true;
        };
        #systemd.user.services.kdeconnect.Install.WantedBy = mkForce [ "sway-session.target" ];
        #systemd.user.services.kdeconnect-indicator.Install.WantedBy = mkForce [ "sway-session.target" ];

        wayland.windowManager.sway = {
          systemd.enable = true;
          wrapperFeatures.gtk = true;
          config = let
            dropdown = "${sway-scratchpad}/bin/sway-scratchpad -c ${context.variables.binDir}/terminal -m terminal";
            passwords = "${sway-scratchpad}/bin/sway-scratchpad -c ${pkgs.keepassxc}/bin/keepassxc -m keepassxc --width 75 --height 70";
            resizeModeName = "Resize: arrow keys";
            mirrorModeName = "Mirror: s - sway-wsshare, c - create, f - toggle freeze";
            signalModeName = "Signal: s - stop, q - continue, k - terminate, 9 - kill";
            audioModeName = "Audio: s - speakers, m - mic, p - pavu, h - patchboard";
          in rec {
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
              focused = { background = "#272822"; border = "#272822"; childBorder = "#66D9EF"; indicator = "#66D9EF"; text = "#A6E22E"; };
              focusedInactive = { background = "#272822"; border = "#272822"; childBorder = "#272822"; indicator = "#272822"; text = "#66D9EF"; };
              unfocused = { background = "#1E1F1C"; border = "#1E1F1C"; childBorder = "#272822"; indicator = "#272822"; text = "#939393"; };
              urgent = { background = "#F92672"; border = "#F92672"; childBorder = "#F92672"; indicator = "#F92672"; text = "#FFFFFF"; };
            };
            fonts = {
              names = [ context.variables.font.family ];
              style = context.variables.font.style;
              size = context.variables.font.size;
            };
            keybindings = lib.mkOptionDefault {
                "${modifier}+Control+t" = "exec ${context.variables.programs.terminal}";
                "Mod1+Control+t" = "exec ${context.variables.programs.terminal}";
                "${modifier}+Control+h" = "exec ${context.variables.programs.filemanager} '${context.variables.homeDir}'";
                "Mod1+Control+h" = "exec ${context.variables.programs.filemanager} '${context.variables.homeDir}'";
                "F12" = "exec ${dropdown}";
                "XF86Favorites" = "exec ${dropdown}";
                "F9" = "exec ${passwords}";
                "XF86Messenger" = "exec ${passwords}";
                "Control+Mod1+p" = "exec ${passwords}";
                "${modifier}+k" = "kill";
                "Mod1+Control+space" = "exec ${context.variables.programs.launcher}";
                "${modifier}+Control+space" = "exec ${context.variables.programs.launcher}";
                "${modifier}+l" = "exec ${context.variables.binDir}/lockscreen";
                "Mod1+Control+l" = "exec ${context.variables.binDir}/lockscreen";
                "Control+Tab" = "workspace back_and_forth";
                "Mod1+Control+n" = "exec ${swaynotificationcenter}/bin/swaync-client -t -sw";
                "Mod1+Control+Up" = "exec ${sway-workspace}/bin/sway-workspace prev-output";
                "Mod1+Control+Down" = "exec ${sway-workspace}/bin/sway-workspace next-output";
                "Mod1+Control+Shift+Up" = "exec ${sway-workspace}/bin/sway-workspace --move prev-output";
                "Mod1+Control+Shift+Down" = "exec ${sway-workspace}/bin/sway-workspace --move next-output";
                "Mod1+Control+Left" = "exec ${sway-workspace}/bin/sway-workspace prev-on-output";
                "Mod1+Control+Right" = "exec ${sway-workspace}/bin/sway-workspace next-on-output";
                "Mod1+Control+Shift+Left" = "exec ${sway-workspace}/bin/sway-workspace --move prev-on-output";
                "Mod1+Control+Shift+Right" = "exec ${sway-workspace}/bin/sway-workspace --move next-on-output";
                "Print" = "exec ${grim}/bin/grim -g \"$(${slurp}/bin/slurp)\" ${context.variables.homeDir}/Pictures/Screenshot-$(date +%Y-%m-%d_%H-%M-%S).png";
                "Shift+Print" = "exec ${grim}/bin/grim -g \"$(${slurp}/bin/slurp)\" - | ${wl-clipboard}/bin/wl-copy --type image/png";
                "Control+Mod1+Delete" = "exec ${pkgs.nwg-bar}/bin/nwg-bar";
                "Control+Mod1+m" = "exec ${pkgs.nwg-displays}/bin/nwg-displays";
                "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 3%+";
                "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-";
                "XF86AudioMicMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                "XF86MonBrightnessUp" = "exec ${pkgs.brillo}/bin/brillo -A 10";
                "XF86MonBrightnessDown" = "exec ${pkgs.brillo}/bin/brillo -U 10";
                "${modifier}+p" = "output ${(lib.head context.variables.outputs).output} toggle";
                "${modifier}+m" = "mode \"${mirrorModeName}\"";
                "${modifier}+s" = "mode \"${signalModeName}\"";
                "${modifier}+r" = "mode \"${resizeModeName}\"";
                "${modifier}+a" = lib.mkForce "mode \"${audioModeName}\"";
                "${modifier}+c" = "exec ${grim}/bin/grim -g \"$(${slurp}/bin/slurp)\" - | ${tesseract5}/bin/tesseract stdin stdout | ${wl-clipboard}/bin/wl-copy";
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
                "c" = "exec env PATH=${rofi}/bin:$PATH ${wl-mirror}/bin/wl-present mirror, mode \"default\"";
                "f" = "exec env PATH=${rofi}/bin:$PATH ${wl-mirror}/bin/wl-present toggle-freeze, mode \"default\"";
                "Escape" = "mode default";
                "Return" = "mode default";
              };
              "${signalModeName}" = {
                "s" = "exec ${coreutils}/bin/kill -SIGSTOP $(${sway}/bin/swaymsg -t get_tree | ${jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid'), mode \"default\"";
                "q" = "exec ${coreutils}/bin/kill -SIGCONT $(${sway}/bin/swaymsg -t get_tree | ${jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid'), mode \"default\"";
                "k" = "exec ${coreutils}/bin/kill -SIGTERM $(${sway}/bin/swaymsg -t get_tree | ${jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid'), mode \"default\"";
                "9" = "exec ${coreutils}/bin/kill -SIGKILL $(${sway}/bin/swaymsg -t get_tree | ${jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid'), mode \"default\"";
                "Escape" = "mode default";
                "Return" = "mode default";
              };
              "${audioModeName}" = {
                "s" = "exec ${setDefaultSink}, mode \"default\"";
                "m" = "exec ${setDefaultSource}, mode \"default\"";
                "p" = "exec ${pkgs.pavucontrol}/bin/pavucontrol, mode \"default\"";
                "h" = "exec ${pkgs.helvum}/bin/helvum, mode \"default\"";
                "Escape" = "mode default";
                "Return" = "mode default";
              };
            };
            startup = [
              { command = "${context.variables.profileDir}/bin/service-group-always restart"; always = true; }
              { command = "${context.variables.profileDir}/bin/service-group-once start"; }
              #{ command = "${mako}/bin/mako"; always = true; }
              { command = "${swaynotificationcenter}/bin/swaync"; always = true; }
              { command = "${swayest}/bin/sworkstyle"; always = true; }
              #{ command = "${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK SSH_AUTH_SOCK XDG_CURRENT_DESKTOP=sway"; }
              #{ command = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK SSH_AUTH_SOCK XDG_CURRENT_DESKTOP=sway"; }
              { command = "${dbus-sway-environment}/bin/dbus-sway-environment"; always = true; }
              { command = "${configure-gtk}/bin/configure-gtk"; always = true; }
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
                { command = "floating enable, sticky enable, resize set 30 ppt 60 ppt, border pixel 10"; criteria = { app_id = "^launcher$"; }; }
                { command = "border pixel 1"; criteria = { con_mark = "SCRATCHPAD_terminal"; }; }
                { command = "kill"; criteria = { app_id = "firefox"; title = "Firefox — Sharing Indicator"; }; }
              ];
            };
            #seat = {
            #  "*" = {
            #    hide_cursor = "when-typing disable";
            #  };
            #};
            output = lib.listToAttrs (map (o: { name = o.output; value = ({ bg = "${o.wallpaper} fill"; scale = (toString o.scale); } // (lib.optionalAttrs (o.mode != null) { inherit (o) mode; })); }) context.variables.outputs);
            workspaceOutputAssign = lib.flatten (map (o: map (w: { workspace = w; inherit (o) output; }) o.workspaces) context.variables.outputs);
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

          bind = CTRL ALT, l, exec, ${context.variables.binDir}/lockscreen
          bind = $mod, l, exec, ${context.variables.binDir}/lockscreen

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

          bind = CTRL ALT, n, exec, ${swaynotificationcenter}/bin/swaync-client -t -sw
          bind = CTRL ALT, Delete, exec, ${pkgs.nwg-bar}/bin/nwg-bar

          binde=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 3%+
          bindl=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-
          bindl=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
          bindl=, XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

          binde = , XF86MonBrightnessUp, exec, ${pkgs.brillo}/bin/brillo -A 10
          binde = , XF86MonBrightnessDown, exec, ${pkgs.brillo}/bin/brillo -U 10

          bind = , Print, exec, ${grim}/bin/grim -g "$(${slurp}/bin/slurp)" ${context.variables.homeDir}/Pictures/Screenshot-$(date +%Y-%m-%d_%H-%M-%S).png
          bind = SHIFT, Print, exec, ${grim}/bin/grim -g "$(${slurp}/bin/slurp)" - | ${wl-clipboard}/bin/wl-copy --type image/png
          bind = $mod, c, exec, ${grim}/bin/grim -g "$(${slurp}/bin/slurp)" - | ${tesseract5}/bin/tesseract stdin stdout | ${wl-clipboard}/bin/wl-copy

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
          bind =, s, exec, ${coreutils}/bin/kill -SIGSTOP $(${sway}/bin/swaymsg -t get_tree | ${jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid')
          bind =, s, submap, reset
          bind =, q, exec, ${coreutils}/bin/kill -SIGCONT $(${sway}/bin/swaymsg -t get_tree | ${jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid')
          bind =, q, submap, reset
          bind =, k, exec, ${coreutils}/bin/kill -SIGTERM $(${sway}/bin/swaymsg -t get_tree | ${jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid')
          bind =, k, submap, reset
          bind =, 9, exec, ${coreutils}/bin/kill -SIGKILL $(${sway}/bin/swaymsg -t get_tree | ${jq}/bin/jq '.. | select(.type?) | select(.focused==true).pid')
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
          ${lib.concatMapStringsSep "\n" (o:
          lib.concatMapStringsSep "\n" (w:
          "workspace=${o.output},${w}"
          ) o.workspaces
          ) context.variables.outputs}

          monitor=,preferred,auto,1
          ${lib.concatMapStringsSep "\n" (o:
          ''monitor=${o.output},${if o.mode == null then "preferred" else o.mode},${lib.replaceStrings [","] ["x"] o.position},${toString o.scale}''
          ) context.variables.outputs}

          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          ${builtins.concatStringsSep "\n" (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in ''
              bind = $mod, ${ws}, workspace, ${toString (x + 1)}
              bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
            ''
          )
          10)}

          exec-once = ${swaybg}/bin/swaybg -o '*' -m fill -i '${context.variables.wallpaper}'
          exec-once = ${swaynotificationcenter}/bin/swaync
          exec-once = ${context.variables.profileDir}/bin/service-group-once start
          exec = ${context.variables.profileDir}/bin/service-group-always restart
          ${lib.concatMapStringsSep "\n" (e:
          ''exec-once = ${lib.optionalString (builtins.hasAttr "workspace" e) "[workspace ${toString e.workspace}] "}${e.command}''
          ) context.exec-once}
          ${lib.concatMapStringsSep "\n" (e:
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
          events = [
            { event = "before-sleep"; command = "${context.variables.binDir}/lockscreen"; }
            { event = "lock"; command = "${context.variables.binDir}/lockscreen"; }
            { event = "after-resume"; command = lib.concatMapStringsSep "; " (o: ''${context.variables.i3-msg} "output ${o.output} dpms on"'') context.variables.outputs; }
            { event = "unlock"; command = lib.concatMapStringsSep "; " (o: ''${context.variables.i3-msg} "output ${o.output} dpms on"'') context.variables.outputs; }
          ];
          timeouts = [
            { timeout = 120; command = "${context.variables.binDir}/lockscreen"; }
            {
              timeout = 300;
              command = lib.concatMapStringsSep "; " (o: ''${context.variables.i3-msg} "output ${o.output} dpms off"'') context.variables.outputs;
              resumeCommand = lib.concatMapStringsSep "; " (o: ''${context.variables.i3-msg} "output ${o.output} dpms on"'') context.variables.outputs;
            }
            { timeout = 3600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
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
              theme =  {
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

        #programs.waybar.enable = true;
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
              background: rgba(50, 48, 47, 0.9);
              border-bottom: 3px solid rgba(100, 90, 86, 0.9);
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

          #mode,#submap,#clock,#battery,#taskbar,#pulseaudio,#idle_inhibitor,#keyboard-state,#bluetooth,#battery,#cpu,#temperature,#tray,#network,#custom-dnd,#custom-notification,#disk,#custom-weather,#custom-pipewire {
              padding: 0 5px;
          }

          #custom-sep {
              color: rgba(100, 90, 86, 0.9);
          }

          #window {
              padding: 0 30px;
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
        '';
        programs.waybar.settings = {
          mainBar = {
            layer = "top";
            position = "bottom";
            height = 26;
            output = map (o: o.output) context.variables.outputs;
            modules-left = [
              "${context.variables.graphical.name}/workspaces"
              "${context.variables.graphical.name}/${if context.variables.graphical.name == "sway" then "mode" else "submap"}"
              "${context.variables.graphical.name}/window"
            ];
            modules-center = [ ];
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
              (lib.imap0 (i: _: [ "network#${toString i}" "custom/sep" ]) (context.variables.ethernetInterfaces ++ context.variables.wirelessInterfaces))
              (lib.imap0 (i: _: [ "disk#${toString i}" "custom/sep" ]) context.variables.mounts)
              "cpu"
              "custom/sep"
              "temperature"
              "custom/sep"
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
            "${context.variables.graphical.name}/workspaces" = {
              all-outputs = context.variables.graphical.name == "sway";
              show-special = lib.mkIf (context.variables.graphical.name == "hyprland") false;
              active-only = lib.mkIf (context.variables.graphical.name == "hyprland") true;
            };
            "${context.variables.graphical.name}/window" = {
              separate-outputs = lib.mkIf (context.variables.graphical.name == "hyprland") true;
            };
            clock = {
              format = "{:%a %d.%m.%Y, %H:%M}";
              tooltip-format = "<tt><small>{calendar}</small></tt>";
              calendar = {
                mode = "month";
                mode-mon-col = 3;
                weeks-pos = "left";
                on-scroll = 1;
                on-click-right = "mode";
                format = {
                  months = "<span color='#ffead3'><b>{}</b></span>";
                  days = "<span color='#FC9867'><b>{}</b></span>";
                  weeks = "<span color='#99ffdd'><b>{}</b></span>";
                  weekdays = "<span color='#FFD866'><b>{}</b></span>";
                  today = "<span color='#FF6188'><b>{}</b></span>";
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
                  default = ["" ""];
              };
              on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
              on-click-middle = "${pkgs.helvum}/bin/helvum";
              on-click-right = "${pkgs.easyeffects}/bin/easyeffects";
            };
            "custom/pipewire" = {
              exec = "${wp_volume}";
              tooltip = false;
              on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              on-click-middle = "${pkgs.helvum}/bin/helvum";
              on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
              on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 3%+";
              on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-";
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
              format-disabled = " {status}";
              format-connected = " {num_connections} connected";
              tooltip-format = "{controller_alias}\t{controller_address}";
              tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
              tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
              #on-click-right = "${blueman}/bin/blueman-manager";
              on-click-right = "${blueberry}/bin/blueberry";
            };
            cpu = {
              format = "{icon}";
              format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
            };
            temperature = {
              format = "{temperatureC}°C {icon}";
              format-icons = ["" "" "" "" ""];
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
              "exec" = "${swaynotificationcenter}/bin/swaync-client -swb";
              "on-click" = "${swaynotificationcenter}/bin/swaync-client -d -sw";
              "on-click-right" = "${swaynotificationcenter}/bin/swaync-client -t -sw";
              "escape" = true;
            };
            "custom/weather" = {
              format = "{}°C";
              tooltip = true;
              interval = 3600;
              exec = "${pkgs.wttrbar}/bin/wttrbar --date-format '%d.%m.%Y' --hide-conditions";
              return-type = "json";
            };
            battery = {
              interval = 60;
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{capacity}% {icon}";
              format-icons = ["" "" "" "" ""];
              max-length = 25;
            };
          } // lib.listToAttrs (lib.imap0 (i: v: { name = "disk#${toString i}"; value = { format = "${v}{percentage_used}%"; path = v; }; }) context.variables.mounts)
          // lib.listToAttrs (lib.imap0 (i: v: { name = "network#${toString i}"; value = {
              interface = v;
              format = "{ifname}";
              format-wifi = "{essid} ({signalStrength}%) ";
              format-ethernet = "{ipaddr}/{cidr} ";
              format-disconnected = "";
              tooltip-format = "{ifname} via {gwaddr} ";
              tooltip-format-wifi = "{essid} ({signalStrength}%) ";
              tooltip-format-ethernet = "{ifname} ";
              tooltip-format-disconnected = "Disconnected";
              max-length = 50;
              #on-click-right = "${connman-gtk}/bin/connman-gtk";
          }; }) (context.variables.ethernetInterfaces ++ context.variables.wirelessInterfaces));
        };
        programs.waybar.systemd.enable = true;
        programs.waybar.systemd.target = context.variables.graphical.target;
        systemd.user.services.waybar.Service.Environment = "PATH=${pkgs.jq}/bin:${pkgs.systemd}/bin";

        #services.nextcloud-client.enable = true;
        #services.nextcloud-client.startInBackground = true;
        #systemd.user.services.nextcloud-client.Service.ExecStart = mkForce (exec "${nextcloud-client}/bin/nextcloud --background");
        systemd.user.services.network-manager-applet.Service.ExecStart = lib.mkForce "${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
        systemd.user.services.network-manager-applet.Unit.Requires = lib.mkForce [ "graphical-session-pre.target" ];


        services.syncthing.extraOptions = [ "-gui-address=127.0.0.1:8384" ];

        home.activation.dotfiles = ''
          $DRY_RUN_CMD ${dotfiles}/bin/dot-files-apply-homemanager
        '';

        home.activation.checkLinkTargets = lib.mkForce "true";

        programs.gpg = {
          enable = true;
          settings."pinentry-mode" = "loopback";
        };
        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableZshIntegration = true;
        };

        programs.bash = {
          enable = true;
          enableVteIntegration = true;
          historyControl = [ "erasedups" "ignorespace" ];
        };

        programs.zsh = {
          enable = true;
          enableVteIntegration = true;
          initExtra = ''
            ${lib.readFile (dotFileAt "zsh.nix" 0)}

            . "${pkgs.nix}/etc/profile.d/nix.sh"

            unset __HM_SESS_VARS_SOURCED
            . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" || true
          '';
          loginExtra = ''
            ${lib.readFile (dotFileAt "zsh.nix" 1)}
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
          enableAutosuggestions = true;
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
        programs.gitui.enable = true;
        programs.broot = {
          enable = true;
          enableZshIntegration = true;
        };
        home.shellAliases = {
          ".." = "cd ..";
          "l" = "${pkgs.eza}/bin/eza -gal --git";
          "t" = "${pkgs.eza}/bin/eza -T --ignore-glob='.git' -L3";
          "z" = "${pkgs.zellij}/bin/zellij";
          "b" = "${pkgs.broot}/bin/broot";
        };
        programs.command-not-found = {
          enable = true;
          dbPath = "${inputs.nixexprs}/programs.sqlite";
        };
        programs.zellij = {
          enable = true;
          settings = {
            simplified_ui = true;
            default_layout = "compact";
            copy_command = "${pkgs.wl-clipboard}/bin/wl-copy";
            default_shell = "${context.variables.shell}";
            pane_frames = false;
            # keybinds = {
            #   unbind = [ "Ctrl t" "Ctrl s" "Ctrl g" "Ctrl n" "Ctrl q" "Ctrl o" "Ctrl p" "Ctrl h" "Ctrl b" ];
            # };
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
      }] ++ [ context.home-configuration ]);
    };
  }] ++ [ context.nixos-configuration ]);
}
