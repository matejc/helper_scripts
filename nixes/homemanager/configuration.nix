{ inputs, contextFile }:
{ pkgs, lib, config, ... }:
with pkgs;
let
  helper_scripts = ../..;

  nixosConfig = config;

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
      dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK SSH_AUTH_SOCK XDG_CURRENT_DESKTOP=sway
      systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK SSH_AUTH_SOCK XDG_CURRENT_DESKTOP=sway
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
      ${pkgs.glib}/bin/gsettings set $gnome_schema gtk-theme 'Breeze-Dark'
      ${pkgs.glib}/bin/gsettings set $gnome_schema color-scheme 'prefer-dark'
      ${pkgs.glib}/bin/gsettings set $gnome_schema font-name '${context.variables.font.family} ${toString context.variables.font.size}'
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

  chooserCmd = pkgs.writeShellScript "sway-output-chooser" ''
    export PATH="${pkgs.sway}/bin:${pkgs.jq}/bin:${pkgs.wofi}/bin:${pkgs.coreutils}/bin:$PATH"
    export SWAYSOCK="$(ls /run/user/"$(id -u)"/sway-ipc.* | head -n 1)"
    swaymsg -t get_outputs | jq -r '.[]|.name' | wofi -d
  '';
in {
  imports = [
    inputs.niri.nixosModules.niri
  ];
  config = lib.mkMerge ([{
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
      config.common.default = pkgs.lib.mkDefault "*";
      config.common."org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      config.sway = {
        default = "wlr;";
        "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
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
    services.dbus.packages = [ pkgs.gcr ];  # gpg-entry.pinentryFlavor = "gnome3"
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
          #GTK_USE_PORTAL = "1";
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
              { command = "${dbus-sway-environment}/bin/dbus-sway-environment"; always = true; }
              { command = "${configure-gtk}/bin/configure-gtk"; always = true; }
              { command = "${context.variables.profileDir}/bin/service-group-always restart"; always = true; }
              { command = "${context.variables.profileDir}/bin/service-group-once start"; }
              #{ command = "${mako}/bin/mako"; always = true; }
              { command = "${swaynotificationcenter}/bin/swaync"; always = true; }
              { command = "${swayest}/bin/sworkstyle"; always = true; }
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
          pinentryFlavor = "gnome3";
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

        programs.niri.config = pkgs.lib.mkIf (nixosConfig.programs.niri.enable) ''
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
                  tap
                  // dwt
                  natural-scroll
                  // accel-speed 0.2
                  // accel-profile "flat"
                  // tap-button-map "left-middle-right"
              }

              mouse {
                  // natural-scroll
                  accel-speed 0.2
                  accel-profile "flat"
              }

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

          ${lib.concatMapStringsSep "\n" (o:
          ''
          output "${o.output}" {
            scale ${toString o.scale}
            ${if o.mode == null then "" else "mode \"${o.mode}\""}
            ${let
              pos = lib.splitString "," o.position;
              x = builtins.elemAt pos 0;
              y = builtins.elemAt pos 1;
            in ''
            position x=${x} y=${y}
            ''
            }
          }
          ''
          ) context.variables.outputs}

          layout {
              // You can change how the focus ring looks.
              focus-ring {
                  // Uncomment this line to disable the focus ring.
                  off

                  // How many logical pixels the ring extends out from the windows.
                  width 1

                  // Color of the ring on the active monitor: red, green, blue, alpha.
                  active-color 127 200 255 255

                  // Color of the ring on inactive monitors: red, green, blue, alpha.
                  inactive-color 80 80 80 255
              }

              // You can also add a border. It's similar to the focus ring, but always visible.
              border {
                  // The settings are the same as for the focus ring.
                  // If you enable the border, you probably want to disable the focus ring.
                  // off

                  width 2
                  active-color 127 200 255 255
                  inactive-color 80 80 80 255
              }

              // You can customize the widths that "switch-preset-column-width" (Mod+R) toggles between.
              preset-column-widths {
                  // Proportion sets the width as a fraction of the output width, taking gaps into account.
                  // For example, you can perfectly fit four windows sized "proportion 0.25" on an output.
                  // The default preset widths are 1/3, 1/2 and 2/3 of the output.
                  proportion 0.33333
                  proportion 0.5
                  proportion 0.66667

                  // Fixed sets the width in logical pixels exactly.
                  // fixed 1920
              }

              // You can change the default width of the new windows.
              default-column-width { proportion 0.5; }
              // If you leave the brackets empty, the windows themselves will decide their initial width.
              // default-column-width {}

              // Set gaps around windows in logical pixels.
              gaps 0

              // Struts shrink the area occupied by windows, similarly to layer-shell panels.
              // You can think of them as a kind of outer gaps. They are set in logical pixels.
              // Left and right struts will cause the next window to the side to always be visible.
              // Top and bottom struts will simply add outer gaps in addition to the area occupied by
              // layer-shell panels and regular gaps.
              struts {
                  // left 64
                  // right 64
                  // top 64
                  // bottom 64
              }

              // When to center a column when changing focus, options are:
              // - "never", default behavior, focusing an off-screen column will keep at the left
              //   or right edge of the screen.
              // - "on-overflow", focusing a column will center it if it doesn't fit
              //   together with the previously focused column.
              // - "always", the focused column will always be centered.
              center-focused-column "never"
          }

          // Add lines like this to spawn processes at startup.
          // Note that running niri as a session supports xdg-desktop-autostart,
          // which may be more convenient to use.
          spawn-at-startup "${configure-gtk}/bin/configure-gtk"
          spawn-at-startup "${pkgs.stdenv.shell}" "-c" "${swaybg}/bin/swaybg -o '*' -m stretch -i '${context.variables.wallpaper}'"
          spawn-at-startup "${pkgs.stdenv.shell}" "-c" "${swaynotificationcenter}/bin/swaync"

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

          binds {
              // Keys consist of modifiers separated by + signs, followed by an XKB key name
              // in the end. To find an XKB name for a particular key, you may use a program
              // like wev.
              //
              // "Mod" is a special modifier equal to Super when running on a TTY, and to Alt
              // when running as a winit window.

              // Mod-Shift-/, which is usually the same as Mod-?,
              // shows a list of important hotkeys.
              Mod+Shift+Slash { show-hotkey-overlay; }

              // Suggested binds for running programs: terminal, app launcher, screen locker.
              Ctrl+Alt+T { spawn "${context.variables.programs.terminal}"; }
              Ctrl+Alt+Space { spawn "${context.variables.binDir}/launcher"; }
              Ctrl+Alt+L { spawn "${context.variables.binDir}/lockscreen"; }
              Ctrl+Alt+Delete { spawn "${pkgs.nwg-bar}/bin/nwg-bar"; }
              Ctrl+Alt+M { spawn "${pkgs.nwg-displays}/bin/nwg-displays"; }
              Ctrl+Alt+N { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw"; }

              // You can also use a shell:
              // Mod+T { spawn "bash" "-c" "notify-send hello && exec alacritty"; }

              XF86AudioMute { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
              XF86AudioRaiseVolume { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 3%+"; }
              XF86AudioLowerVolume { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-"; }
              XF86AudioMicMute { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
              XF86MonBrightnessUp { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.brillo}/bin/brillo -A 10"; }
              XF86MonBrightnessDown { spawn "${pkgs.stdenv.shell}" "-c" "${pkgs.brillo}/bin/brillo -U 10"; }

              Mod+K { close-window; }

              Mod+Left  { focus-column-left; }
              Mod+Down  { focus-window-down; }
              Mod+Up    { focus-window-up; }
              Mod+Right { focus-column-right; }

              Ctrl+Alt+Left  { focus-column-left; }
              Ctrl+Alt+Right { focus-column-right; }
              Ctrl+Alt+Shift+Left  { move-column-left; }
              Ctrl+Alt+Shift+Right { move-column-right; }

              Mod+Shift+Left  { move-column-left; }
              Mod+Shift+Down  { move-window-down; }
              Mod+Shift+Up    { move-window-up; }
              Mod+Shift+Right { move-column-right; }

              // Alternative commands that move across workspaces when reaching
              // the first or last window in a column.
              // Mod+J     { focus-window-or-workspace-down; }
              // Mod+K     { focus-window-or-workspace-up; }
              // Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
              // Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }

              Mod+Home { focus-column-first; }
              Mod+End  { focus-column-last; }
              Mod+Shift+Home { move-column-to-first; }
              Mod+Shift+End  { move-column-to-last; }

              Mod+Ctrl+Left  { focus-monitor-left; }
              Mod+Ctrl+Down  { focus-monitor-down; }
              Mod+Ctrl+Up    { focus-monitor-up; }
              Mod+Ctrl+Right { focus-monitor-right; }

              Ctrl+Alt+Page_Up  { focus-monitor-left; }
              Ctrl+Alt+Page_Down { focus-monitor-right; }
              Ctrl+Shift+Alt+Page_Up  { move-window-to-monitor-left; }
              Ctrl+Shift+Alt+Page_Down { move-window-to-monitor-right; }

              Mod+Shift+Ctrl+Left  { move-window-to-monitor-left; }
              Alt+Shift+Ctrl+Left  { move-window-to-monitor-left; }
              Mod+Shift+Ctrl+Down  { move-window-to-monitor-down; }
              Mod+Shift+Ctrl+Up    { move-window-to-monitor-up; }
              Mod+Shift+Ctrl+Right { move-window-to-monitor-right; }
              Alt+Shift+Ctrl+Right { move-window-to-monitor-right; }

              Ctrl+Alt+Up        { focus-workspace-up; }
              Ctrl+Alt+Down      { focus-workspace-down; }
              Ctrl+Alt+Shift+Up   { move-window-to-workspace-up; }
              Ctrl+Alt+Shift+Down { move-window-to-workspace-down; }

              Mod+1 { focus-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+6 { focus-workspace 6; }
              Mod+7 { focus-workspace 7; }
              Mod+8 { focus-workspace 8; }
              Mod+9 { focus-workspace 9; }
              Mod+Shift+1 { move-window-to-workspace 1; }
              Mod+Shift+2 { move-window-to-workspace 2; }
              Mod+Shift+3 { move-window-to-workspace 3; }
              Mod+Shift+4 { move-window-to-workspace 4; }
              Mod+Shift+5 { move-window-to-workspace 5; }
              Mod+Shift+6 { move-window-to-workspace 6; }
              Mod+Shift+7 { move-window-to-workspace 7; }
              Mod+Shift+8 { move-window-to-workspace 8; }
              Mod+Shift+9 { move-window-to-workspace 9; }

              Mod+Comma  { consume-window-into-column; }
              Mod+Period { expel-window-from-column; }

              Mod+R { switch-preset-column-width; }
              Mod+F { maximize-column; }
              Mod+Ctrl+F { fullscreen-window; }
              Mod+C { center-column; }

              // Finer width adjustments.
              // This command can also:
              // * set width in pixels: "1000"
              // * adjust width in pixels: "-5" or "+5"
              // * set width as a percentage of screen width: "25%"
              // * adjust width as a percentage of screen width: "-10%" or "+10%"
              // Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
              // set-column-width "100" will make the column occupy 200 physical screen pixels.
              Mod+Minus { set-column-width "-10%"; }
              Mod+Equal { set-column-width "+10%"; }

              // Finer height adjustments when in column with other windows.
              Mod+Ctrl+Minus { set-window-height "-10%"; }
              Mod+Ctrl+Equal { set-window-height "+10%"; }

              // Actions to switch layouts.
              // Note: if you uncomment these, make sure you do NOT have
              // a matching layout switch hotkey configured in xkb options above.
              // Having both at once on the same hotkey will break the switching,
              // since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
              // Mod+Space       { switch-layout "next"; }
              // Mod+Shift+Space { switch-layout "prev"; }

              Ctrl+Print { screenshot; }
              Alt+Print { screenshot-window; }

              Mod+Shift+E { quit; }
              // Mod+Shift+P { power-off-monitors; }

              // Mod+Shift+Ctrl+T { toggle-debug-tint; }
          }

          // Settings for debugging. Not meant for normal use.
          // These can change or stop working at any point with little notice.
          debug {
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
      }] ++ [ context.home-configuration ]);
    };
  }] ++ [ context.nixos-configuration ]);
}
