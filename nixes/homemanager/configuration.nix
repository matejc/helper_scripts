{ pkgs, lib, ... }@args:
with lib;
with pkgs;
let
  config = args.config.home-manager.users.${args.defaultUser};

  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };

  nixmySrc = builtins.fetchGit {
    url = "https://github.com/matejc/nixmy.git";
  };

  dotfiles = import ./../../dotfiles/default.nix
    { name = "homemanager"; exposeScript = true; inherit context; }
    { inherit pkgs lib config; };

  dotFileAt = file: at:
    (elemAt (import file { inherit lib pkgs; inherit (context) variables config; }) at).source;

  context.dotFilePaths = [
    ./../../dotfiles/programs.nix
    ./../../dotfiles/nvim.nix
    ./../../dotfiles/xfce4-terminal.nix
    ./../../dotfiles/gitconfig.nix
    ./../../dotfiles/gitignore.nix
    ./../../dotfiles/nix.nix
    ./../../dotfiles/oath.nix
    ./../../dotfiles/jstools.nix
    ./../../dotfiles/superslicer.nix
    ./../../dotfiles/scan.nix
    ./../../dotfiles/swaylockscreen.nix
    ./../../dotfiles/comma.nix
  ];
  context.activationScript = "";
  context.variables = rec {
    homeDir = config.home.homeDirectory;
    user = config.home.username;
    profileDir = config.home.profileDirectory;
    prefix = "${homeDir}/workarea/helper_scripts";
    nixpkgs = "${homeDir}/workarea/nixpkgs";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    binDir = "${homeDir}/bin";
    monitors = [ ];
    temperatureFiles = [ "/sys/devices/virtual/thermal/thermal_zone1/temp" ];
    lockscreen = "${homeDir}/bin/lockscreen";
    lockImage = "${homeDir}/Pictures/blade-of-grass-blur.png";
    wallpaper = "${homeDir}/Pictures/blade-of-grass.jpg";
    fullName = "Matej Cotman";
    email = "matej@matejc.com";
    locale.all = "en_US.UTF-8";
    wirelessInterfaces = [];
    ethernetInterfaces = [ "br0" ];
    mounts = [ "/" ];
    font = {
      family = "SauceCodePro Nerd Font Mono";
      style = "Bold";
      size = 10.0;
    };
    i3-msg = "${programs.i3-msg}";
    term = null;
    programs = {
      filemanager = "${xfce.thunar}/bin/thunar";
      #terminal = "${xfce.terminal}/bin/xfce4-terminal";
      terminal = "${pkgs.kitty}/bin/kitty";
      dropdown = "${dotFileAt ./../../dotfiles/i3config.nix 1} --class=ScratchTerm";
      browser = "${profileDir}/bin/chromium";
      editor = "${nano}/bin/nano";
      launcher = dotFileAt ./../../dotfiles/bemenu.nix 0;
      #launcher = "${pkgs.xfce.terminal}/bin/xfce4-terminal --title Launcher --hide-scrollbar --hide-toolbar --hide-menubar --drop-down -x ${homeDir}/bin/sway-launcher-desktop";
      window-size = dotFileAt ./../../dotfiles/i3config.nix 2;
      window-center = dotFileAt ./../../dotfiles/i3config.nix 3;
      i3-msg = "${profileDir}/bin/swaymsg";
      nextcloud = "${nextcloud-client}/bin/nextcloud";
      keepassxc = "${pkgs.keepassxc}/bin/keepassxc";
      tmux = "${pkgs.tmux}/bin/tmux";
      tug = "${pkgs.turbogit}/bin/tug";
    };
    shell = "${profileDir}/bin/zsh";
    sway.enable = false;
    vims = {
      q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --nvim ${homeDir}/bin/nvim";
      n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${homeDir}/bin/nvim" --frame None --multigrid'';
      g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
    };
  };
  context.config = {};

  exec = cmd: "${writeScript "exec.sh" ''
    #!${context.variables.shell}
    source "${context.variables.homeDir}/.zshrc"
    exec ${cmd}
  ''}";

  execRestart = binName: execCmd: writeScript "${binName}-restart-script.sh" ''
    #!${context.variables.shell}
    ${procps}/bin/pkill ${binName}
    source "${context.variables.homeDir}/.zshrc"
    mkdir -p ${context.variables.homeDir}/.logs
    exec ${execCmd} &>${context.variables.homeDir}/.logs/${binName}.log
  '';

  # https://nix-community.github.io/home-manager/options.html
in {
    nixpkgs.config = import ./../../dotfiles/nixpkgs-config.nix;
    xdg = {
      enable = true;
      configFile."nixpkgs/config.nix".source = ./../../dotfiles/nixpkgs-config.nix;
    };

    services.gnome-keyring = {
      enable = true;
    };
    systemd.user.services.gnome-keyring.Service.ExecStart = mkForce "/wrappers/gnome-keyring-daemon --start --foreground --components=secrets";

    fonts.fontconfig.enable = mkDefault true;
    home.packages = with pkgs; [
      font-awesome
      (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
      corefonts
      git
      keepassxc
      qt5Full
      socat
      protonvpn-cli
      (import "${nixmySrc}/default.nix" { inherit pkgs lib; config = args.config; })
    ];
    #home.sessionVariables = {
      #NVIM_QT_PATH = "/mnt/c/tools/neovim-qt/bin/nvim-qt.exe";
    #};

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
        "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
        "oboonakemofpalcgghocfoadofidjkkk" # keepassxc
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

    services.kanshi = {
      enable = true;
      profiles.default.outputs = [{
        criteria = "Samsung Electric Company S24F350 H4ZN501371"; position = "0,0";
      } {
        criteria = "BenQ Corporation BenQ GL2480 ETPBL0133504U"; position = "1920,0";
      }];
    };

    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    wayland.windowManager.sway = {
      enable = true;
      systemdIntegration = true;
      config = rec {
        assigns = {
          "1" = [{ class = "^Firefox$"; } { class = "^Chromium-browser$"; }];
        };
        bars = [];
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
            "${modifier}+Control+h" = "exec ${context.variables.programs.filemanager} '${context.variables.homeDir}'";
            "F12" = "exec ${context.variables.programs.dropdown}";
            "Mod1+F4" = "kill";
            "${modifier}+Control+space" = "exec ${context.variables.programs.launcher}";
            "${modifier}+Control+l" = "exec ${context.variables.binDir}/lockscreen";
            "Control+Tab" = "workspace back_and_forth";
            "Mod1+Tab" = "focus right";
            "Mod1+Shift+Tab" = "focus left";
            "${modifier}+Control+Left" = "exec WSNUM=$(${dotFileAt ./../../dotfiles/i3_workspace.nix 0} prev_on_output) && ${context.variables.i3-msg} workspace $WSNUM";
            "${modifier}+Control+Right" = "exec WSNUM=$(${dotFileAt ./../../dotfiles/i3_workspace.nix 0} next_on_output) && ${context.variables.i3-msg} workspace $WSNUM";
            "${modifier}+Control+Shift+Left" = "exec WSNUM=$(${dotFileAt ./../../dotfiles/i3_workspace.nix 0} prev_on_output) && ${context.variables.i3-msg} move workspace $WSNUM && ${context.variables.i3-msg} workspace $WSNUM";
            "${modifier}+Control+Shift+Right" = "exec WSNUM=$(${dotFileAt ./../../dotfiles/i3_workspace.nix 0} next_on_output) && ${context.variables.i3-msg} move workspace $WSNUM && ${context.variables.i3-msg} workspace $WSNUM";
          };
        modifier = "Mod1";
        startup = [
          #{ command = "dbus-update-activation-environment --systemd DISPLAY; systemctl --user restart gnome-keyring"; always = true; }
          { command = "sleep 1 && systemctl --user restart waybar"; }
          { command = "sleep 2 && systemctl --user restart kanshi"; always = true; }
          { command = "systemctl --user restart kdeconnect"; }
          { command = "sleep 2 && systemctl --user restart nextcloud-client"; }
          { command = "sleep 2 && systemctl --user restart kdeconnect-indicator"; }
          { command = "${pkgs.xorg.xrdb}/bin/xrdb -load ${context.variables.homeDir}/.Xresources"; always = true; }
          { command = "${pkgs.feh}/bin/feh --bg-fill ${context.variables.wallpaper}"; always = true; }
          { command = "sleep 2 && ${execRestart "mako" "${mako}/bin/mako"}"; always = true; }
          { command = "sleep 2 && ${execRestart "blueberry-tray" "${blueberry}/bin/blueberry-tray"}"; always = true; }
          { command = "${context.variables.programs.browser}"; }
          { command = "${context.variables.programs.terminal}"; }
        ];
        window = {
          border = 1;
          commands = [
            #{ command = "mark I3WM_SCRATCHPAD"; criteria = { app_id = "ScratchTerm"; }; }
            { command = "border pixel 1"; criteria = { class = "Xfce4-terminal"; }; }
            { command = "border pixel 1"; criteria = { class = ".nvim-qt-wrapped"; }; }
            { command = "border pixel 1"; criteria = { class = "Firefox"; }; }
            { command = "border pixel 1"; criteria = { class = "Chromium-browser"; }; }
          ];
        };
        workspaceOutputAssign = [ { workspace = "1"; output = "HDMI-A-2"; } ];
      };
      extraConfig = ''
        focus_wrapping yes
      '';
  };

  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${context.variables.binDir}/lockscreen"; }
      { event = "lock"; command = "${context.variables.binDir}/lockscreen"; }
      { event = "after-resume"; command = "${context.variables.i3-msg} \"output * dpms on, output * dpms on\""; }
      { event = "unlock"; command = "${context.variables.i3-msg} \"output * dpms on, output * dpms on\""; }
    ];
    timeouts = [
      { timeout = 120; command = "${context.variables.binDir}/lockscreen"; }
      {
        timeout = 300;
        command = "${context.variables.i3-msg} \"output * dpms off\"";
        resumeCommand = "${context.variables.i3-msg} \"output * dpms on, output * dpms on, reload\"";
      }
      { timeout = 3600; command = "systemctl suspend"; }
    ];
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
        background: rgba(50, 48, 47, 0.5);
        border-bottom: 3px solid rgba(100, 90, 86, 0.5);
        color: white;
    }

    tooltip {
      background: rgba(50, 48, 47, 0.5);
      border: 1px solid rgba(100, 90, 86, 0.5);
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

    #mode, #clock, #battery, #taskbar, #pulseaudio, #idle_inhibitor, #keyboard-state, #bluetooth, #battery, #cpu, #temperature, #tray {
        padding: 0 10px;
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
      modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "pulseaudio" "idle_inhibitor" "keyboard-state" "bluetooth" "battery" "cpu" "temperature" "clock" "tray" ];
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
        format = "  {status}";
        format-disabled = "";
        format-connected = " {num_connections} connected";
        tooltip-format = "{controller_alias}\t{controller_address}";
        tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        on-click-right = "${blueberry}/bin/blueberry";
      };
      cpu = {
        format = "{icon}";
        format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
      };
      temperature.hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
            activated = "";
            deactivated = "";
        };
      };
    };
  };
  programs.waybar.systemd.enable = true;
  programs.waybar.systemd.target = "sway-session.target";

  programs.mako = {
    enable = true;
  };

  services.nextcloud-client.enable = true;
  systemd.user.services.nextcloud-client.Service.ExecStart = mkForce (exec "${nextcloud-client}/bin/nextcloud --background");

  home.activation.dotfiles = ''
    $DRY_RUN_CMD ${dotfiles}/bin/dot-files-apply-homemanager
    $DRY_RUN_CMD rm -fv ${context.variables.homeDir}/.zshrc.zwc
  '';

  home.activation.checkLinkTargets = mkForce "true";

  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    initExtra = ''
      ${readFile (dotFileAt ./../../dotfiles/zsh.nix 0)}

      . "${pkgs.nix}/etc/profile.d/nix.sh"
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    '';
    loginExtra = readFile (dotFileAt ./../../dotfiles/zsh.nix 1);
  };
  programs.starship = {
    enable = true;
    settings = {
      character.success_symbol = "[❯](bold green) ";
      character.error_symbol = "[✗](bold red) ";
    };
  };
}
