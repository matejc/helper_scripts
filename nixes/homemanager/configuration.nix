{ inputs, contextFile }:
{ pkgs, lib, config, ... }@args:
with lib;
with pkgs;
let
  context = import contextFile { inherit pkgs lib config inputs dotFileAt; };

  nur = import inputs.nur { nurpkgs = pkgs; inherit pkgs; };

  dotfiles = import "${inputs.helper_scripts}/dotfiles/default.nix"
    { name = "homemanager"; exposeScript = true; inherit context; }
    { inherit pkgs lib config; };

  dotFileAt = file: at:
    (elemAt (import "${inputs.helper_scripts}/dotfiles/${file}" { inherit lib pkgs; inherit (context) variables config; }) at).source;

  exec = { name, cmd, delay ? 0 }: "${writeScript "exec-${name}.sh" ''
    #!${context.variables.shell}
    ${pkgs.coreutils}/bin/sleep ${toString delay}
    source "${context.variables.shellRc}"
    exec ${cmd}
  ''}";

  services-cmds = map (group: writeScriptBin "service-group-${group}" ''
    #!${context.variables.shell}
    source "${context.variables.shellRc}"
    ${concatMapStringsSep "\n" (s: ''{ sleep ${toString s.delay} && systemctl --user "$1" "${s.name}"; } &'') context.services}
    wait
  '') (map (s: s.group) context.services);

  # https://nix-community.github.io/home-manager/options.html
in lib.mkMerge ([{
    nixpkgs.config = import "${inputs.helper_scripts}/dotfiles/nixpkgs-config.nix";
    xdg = {
      enable = true;
      #configFile."nixpkgs/config.nix".source = "nixpkgs-config.nix";
    };

    services.gnome-keyring = {
      enable = true;
    };
    #systemd.user.services.gnome-keyring.Service.ExecStart = mkForce "/wrappers/gnome-keyring-daemon --start --foreground --components=secrets";

    fonts.fontconfig.enable = mkForce true;
    home.packages = [
      font-awesome
      (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
      git
      qt5Full
      socat
      protonvpn-cli
      cinnamon.nemo
      zsh
      wl-clipboard
      xdg-utils
      wofi
      (import "${inputs.nixmy}/default.nix" { inherit pkgs lib; config = args.config; })
    ] ++ services-cmds;
    home.sessionVariables = {
      #NVIM_QT_PATH = "/mnt/c/tools/neovim-qt/bin/nvim-qt.exe";
      QT_PLUGIN_PATH = "${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}";
      QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}";
      SDL_VIDEODRIVER = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    gtk = {
      enable = true;
      font.name = "${context.variables.font.family} ${context.variables.font.style} ${toString context.variables.font.size}";
      iconTheme = {
        name = "breeze";
        package = breeze-icons;
      };
      theme = {
        name = "Breeze";
        package = breeze-gtk;
      };
    };

    programs.chromium = {
      enable = true;
      extensions = [
        "gcbommkclmclpchllfjekcdonpmejbdp"  # https everywhere
        "cjpalhdlnbpafiamejdnhcphjbkeiagm"  # ublock origin
        "oboonakemofpalcgghocfoadofidjkkk"  # keepassxc
        "clpapnmmlmecieknddelobgikompchkk"  # disable automatic gain control
      ];
    };

    programs.firefox = {
      enable = true;
      extensions = with nur.repos.rycee.firefox-addons; [
        https-everywhere ublock-origin keepassxc-browser
      ];
      profiles = {
        default = {
          settings = {
            "general.smoothScroll" = false;
          };
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
      #enable = true;
      profiles.default.outputs = map (o: { inherit (o) criteria position mode; }) context.variables.outputs;
    };

    services.kdeconnect = {
      #enable = true;
      #indicator = true;
    };
    #systemd.user.services.kdeconnect.Install.WantedBy = mkForce [ "sway-session.target" ];
    #systemd.user.services.kdeconnect-indicator.Install.WantedBy = mkForce [ "sway-session.target" ];

    wayland.windowManager.sway = {
      enable = true;
      systemdIntegration = true;
      config = rec {
        assigns = {
          "1" = [{ app_id = "^org.keepassxc.KeePassXC$"; }];
          "4" = [{ class = "^Firefox$"; } { class = "^Chromium-browser$"; }];
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
        keybindings =
          mkOptionDefault {
            "${modifier}+Control+t" = "exec ${context.variables.programs.terminal}";
            "Mod1+Control+t" = "exec ${context.variables.programs.terminal}";
            "${modifier}+Control+h" = "exec ${context.variables.programs.filemanager} '${context.variables.homeDir}'";
            "Mod1+Control+h" = "exec ${context.variables.programs.filemanager} '${context.variables.homeDir}'";
            "F12" = "exec ${context.variables.programs.dropdown}";
            "Mod1+F4" = "kill";
            "Mod1+Control+space" = "exec ${context.variables.programs.launcher}";
            "${modifier}+Control+space" = "exec ${context.variables.programs.launcher}";
            "${modifier}+l" = "exec ${context.variables.binDir}/lockscreen";
            "Mod1+Control+l" = "exec ${context.variables.binDir}/lockscreen";
            "Control+Tab" = "workspace back_and_forth";
            "Mod1+Tab" = "focus right";
            "Mod1+Shift+Tab" = "focus left";
            "Mod1+Control+Left" = "exec WSNUM=$(${dotFileAt "i3_workspace.nix" 0} prev_on_output) && ${context.variables.i3-msg} workspace $WSNUM";
            "Mod1+Control+Right" = "exec WSNUM=$(${dotFileAt "i3_workspace.nix" 0} next_on_output) && ${context.variables.i3-msg} workspace $WSNUM";
            "Mod1+Control+Shift+Left" = "exec WSNUM=$(${dotFileAt "i3_workspace.nix" 0} prev_on_output) && ${context.variables.i3-msg} move workspace $WSNUM && ${context.variables.i3-msg} workspace $WSNUM";
            "Mod1+Control+Shift+Right" = "exec WSNUM=$(${dotFileAt "i3_workspace.nix" 0} next_on_output) && ${context.variables.i3-msg} move workspace $WSNUM && ${context.variables.i3-msg} workspace $WSNUM";
            "Print" = "exec ${grim}/bin/grim -g \"$(${slurp}/bin/slurp)\" ${context.variables.homeDir}/Pictures/Screenshoot-$(date +%Y-%m-%d_%H-%M-%S).png";
            "Shift+Print" = "exec ${grim}/bin/grim -g \"$(${slurp}/bin/slurp)\" - | ${wl-clipboard}/bin/wl-copy --type image/png";
            "Control+Mod1+Delete" = "exec ${pkgs.nwg-launchers}/bin/nwgbar";
          };
        modifier = "Mod4";
        startup = [
          { command = "${context.variables.profileDir}/bin/service-group-always restart"; always = true; }
          { command = "${context.variables.profileDir}/bin/service-group-once start"; }
          { command = "${mako}/bin/mako"; always = true; }
        ];
        window = {
          border = 1;
          commands = [
            #{ command = "mark I3WM_SCRATCHPAD"; criteria = { app_id = "ScratchTerm"; }; }
            #{ command = "border pixel 1"; criteria = { class = "Xfce4-terminal"; }; }
            #{ command = "border pixel 1"; criteria = { class = ".nvim-qt-wrapped"; }; }
            #{ command = "border pixel 1"; criteria = { class = "Firefox"; }; }
            #{ command = "border pixel 1"; criteria = { class = "Chromium-browser"; }; }
            { command = "inhibit_idle visible"; criteria = { title = "YouTube"; }; }
            #{ command = "inhibit_idle fullscreen"; criteria = { shell = ".*"; }; }
            { command = "floating enable, sticky enable, resize set 30 ppt 60 ppt, border pixel 10"; criteria = { app_id = "^launcher$"; }; }
          ];
        };
        workspaceOutputAssign = flatten (map (o: map (w: { workspace = w; inherit (o) output; }) o.workspaces) context.variables.outputs);
        output = builtins.listToAttrs (map (o: { name = o.output; value = { bg = "${o.wallpaper} fill"; mode = o.mode; }; }) context.variables.outputs);
      };
      extraConfig = ''
        focus_wrapping yes
      '';
  };

  services.swayidle = {
    #enable = true;
    events = [
      { event = "before-sleep"; command = "${context.variables.binDir}/lockscreen"; }
      { event = "lock"; command = "${context.variables.binDir}/lockscreen"; }
      { event = "after-resume"; command = concatMapStringsSep "; " (o: ''${context.variables.i3-msg} "output ${o.output} dpms on"'') context.variables.outputs; }
      { event = "unlock"; command = concatMapStringsSep "; " (o: ''${context.variables.i3-msg} "output ${o.output} dpms on"'') context.variables.outputs; }
    ];
    timeouts = [
      { timeout = 120; command = "${context.variables.binDir}/lockscreen"; }
      {
        timeout = 300;
        command = concatMapStringsSep "; " (o: ''${context.variables.i3-msg} "output ${o.output} dpms off"'') context.variables.outputs;
        resumeCommand = concatMapStringsSep "; " (o: ''${context.variables.i3-msg} "output ${o.output} dpms on"'') context.variables.outputs;
      }
      { timeout = 3600; command = "systemctl suspend"; }
    ];
  };

  #services.blueman-applet.enable = true;

  programs.i3status-rust = {
    enable = true;
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

  programs.waybar.enable = true;
  programs.waybar.style = ''
    * {
        border: none;
        border-radius: 0;
        font-family: ${context.variables.font.family};
        font-style: normal;
        font-weight: bold;
        font-size: 14px;
        min-height: 0;
        padding: 0;
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
        color: white;
        border-bottom: 3px solid transparent;
    }

    #workspaces button.focused {
        background: #64727D;
        border-bottom: 3px solid white;
    }

    #mode, #clock, #battery, #taskbar, #pulseaudio, #idle_inhibitor, #keyboard-state, #bluetooth, #battery, #cpu, #temperature, #tray, #network {
        padding: 0 10px;
    }

    #window {
        padding: 0 30px;
    }

    #battery {
        background-color: #ffffff;
        color: black;
    }

    #battery.charging {
        color: white;
        background-color: #26A65B;
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
  '';
  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "bottom";
      height = 26;
      modules-left = [ "sway/workspaces" "sway/mode" "sway/window" ];
      modules-center = [ ];
      modules-right = [ "pulseaudio" "idle_inhibitor" "bluetooth" "network" "battery" "cpu" "temperature" "clock" "tray" ];
      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
      };
      clock.format = "{:%H:%M, %a %d.%m.%Y}";
      pulseaudio = {
        scroll-step = 5.0;
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
        on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
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
      temperature.hwmon-path = context.variables.hwmonPath;
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
            activated = "";
            deactivated = "";
        };
      };
      network = {
        interface = context.variables.networkInterface;
        format = "{ifname}";
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ipaddr}/{cidr} ";
        format-disconnected = "";
        tooltip-format = "{ifname} via {gwaddr} ";
        tooltip-format-wifi = "{essid} ({signalStrength}%) ";
        tooltip-format-ethernet = "{ifname} ";
        tooltip-format-disconnected = "Disconnected";
        max-length = 50;
      };
    };
  };
  programs.waybar.systemd.enable = true;
  programs.waybar.systemd.target = "sway-session.target";

  programs.mako = {
    enable = true;
    font = "${context.variables.font.family} ${context.variables.font.style} ${toString context.variables.font.size}";
  };

  #services.nextcloud-client.enable = true;
  #services.nextcloud-client.startInBackground = true;
  #systemd.user.services.nextcloud-client.Service.ExecStart = mkForce (exec "${nextcloud-client}/bin/nextcloud --background");

  services.syncthing.extraOptions = [ "-gui-address=127.0.0.1:8384" ];

  home.activation.dotfiles = ''
    $DRY_RUN_CMD ${dotfiles}/bin/dot-files-apply-homemanager
  '';

  home.activation.checkLinkTargets = mkForce "true";

  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    initExtra = ''
      ${readFile (dotFileAt "zsh.nix" 0)}

      . "${pkgs.nix}/etc/profile.d/nix.sh"

      unset __HM_SESS_VARS_SOURCED
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    '';
    loginExtra = ''
      ${readFile (dotFileAt "zsh.nix" 1)}

      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty3" ] && [ -f "$(${pkgs.which}/bin/which startsway)" ]
      then
        exec dbus-run-session startsway
      fi
    '';
  };
  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 1000;
      character.success_symbol = "[❯](bold green) ";
      character.error_symbol = "[✗](bold red) ";
    };
  };
}] ++ [ context.home-configuration ])
