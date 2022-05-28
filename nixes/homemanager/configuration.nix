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
            "${modifier}+Control+k" = "kill";
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
          { command = "systemctl --user restart waybar"; always = true; }
          { command = "systemctl --user restart kanshi"; always = true; }
          { command = "systemctl --user restart dunst"; always = true; }
          { command = "systemctl --user restart nextcloud-client"; always = true; }
          { command = "${pkgs.xorg.xrdb}/bin/xrdb -load ${context.variables.homeDir}/.Xresources"; always = true; }
          { command = "${pkgs.feh}/bin/feh --bg-fill ${context.variables.wallpaper}"; always = true; }
          #{ command = "${execRestart "nextcloud" "${nextcloud-client}/bin/nextcloud --background"}"; always = true; }
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
        focus_wrapping workspace
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
  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "bottom";
      height = 24;
      modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "pulseaudio" "idle_inhibitor" "bluetooth" "battery" "temperature" "clock" "tray" ];
      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
      };
      clock.format = "{:%H:%M %a, %d.%m.%Y}";
    };
  };
  programs.waybar.systemd.enable = true;

  services.polybar =
    let
      variables = context.variables;
      pulse = true;
    in rec {
      enable = false;
      package = polybar.override { i3Support = true; pulseSupport = pulse; };
    config = {
      colors = {
        background = "#e0272822";
        background-alt = "#454932";
        foreground = "#dfdfdf";
        foreground-alt = "#555942";
        primary = "#FD971F";
        secondary = "#5900ff";
        alert = "#A6E22E";
        underline = "#0a81f5";
      };
      settings = {
        screenchange-reload = true;
      };
      "global/wm" = {
        margin-top = 5;
        margin-bottom = 5;
      };
      "bar/my" = {
        width = "100%";
        height = "24";
        radius = "0.0";
        fixed-center = false;
        bottom = true;
        background = config.colors.background;
        foreground = config.colors.foreground;
        line-size = 2;
        line-color = "#f00";
        border-size = 0;
        border-color = "#00000000";
        padding-left = 0;
        padding-right = 2;
        module-margin-left = 1;
        module-margin-right = 2;
        #font-0 = "Font Awesome 5 Free Solid:size=10";
        font-0 = "${context.variables.font.family}:style=${context.variables.font.style}:size=${toString context.variables.font.size}";
        modules-left = "i3 xwindow";
        modules-right = "xkeyboard filesystem memory cpu ${optionalString pulse "volume"} ${concatImapStringsSep " " (i: v: ''wlan${toString i}'') variables.wirelessInterfaces} ${concatImapStringsSep " " (i: v: ''eth${toString i}'') variables.ethernetInterfaces} external-ip date";
        tray-position = "right";
        tray-padding = 2;
        tray-background = config.colors.background;
        tray-reparent = true;
      };
      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:60:...%";
      };
      "module/xkeyboard" = {
        type = "internal/xkeyboard";
        format = "<label-indicator>";
        blacklist-0 = "num lock";
        blacklist-1 = "scroll lock";
        format-prefix-foreground = config.colors.foreground-alt;
        format-prefix-underline = config.colors.underline;
        label-indicator-padding = 2;
        label-indicator-margin = 1;
        label-indicator-background = config.colors.secondary;
        label-indicator-underline = config.colors.underline;
      };
      "module/filesystem" = {
        type = "internal/fs";
        interval = "25";
        label-mounted = "%{F#0a81f5}%mountpoint%%{F-} %percentage_used%%";
        label-mounted-underline = config.colors.underline;
        label-unmounted = "%mountpoint% not mounted";
        label-unmounted-foreground = config.colors.foreground-alt;
      } // builtins.listToAttrs (imap (i: m: { name = "mount-${toString (i - 1)}"; value = m; }) variables.mounts);
      "module/i3" = {
        type = "internal/i3";
        format = "<label-state> <label-mode>";
        index-sort = true;
        wrapping-scroll = false;
        label-mode-padding = 1;
        label-mode-foreground = "#000";
        label-mode-background = config.colors.primary;
        label-focused = "%index%";
        label-focused-background = config.colors.background-alt;
        label-focused-underline = config.colors.primary;
        label-focused-padding = 1;
        label-unfocused = "%index%";
        label-unfocused-padding = 1;
        label-visible = "%index%";
        label-visible-background = config.colors.background-alt;
        label-visible-padding = 1;
        label-urgent = "%index%";
        label-urgent-foreground = config.colors.foreground-alt;
        label-urgent-background = config.colors.alert;
        label-urgent-padding = 1;
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format-prefix = " ";
        format-prefix-foreground = config.colors.foreground-alt;
        format-underline = config.colors.underline;
        label = "%percentage%%";
      };
      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-prefix = " ";
        format-prefix-foreground = config.colors.foreground-alt;
        format-underline = config.colors.underline;
        label = "%percentage_used%%";
      };
      "module/date" = {
        type = "internal/date";
        interval = 5;
        date = "%a, %d.%m.%Y";
        time = "%H:%M";
        format-underline = config.colors.underline;
        label = "%time% %date%";
      };
      "module/external-ip" = {
        type = "custom/script";
        exec = "${pkgs.curl}/bin/curl --connect-timeout 2 -fs myip.matejc.com";
        click-left = "${pkgs.curl}/bin/curl --connect-timeout 2 -fs myip.matejc.com";
        click-right = "${pkgs.curl}/bin/curl --connect-timeout 2 -fs myip.matejc.com | ${pkgs.coreutils}/bin/tr -d '\\n' | ${pkgs.xclip}/bin/xclip -selection primary";
        interval = 30;
        format-underline = config.colors.underline;
        format-prefix = " ";
      };
      "module/volume" = {
        type = "internal/pulseaudio";
        use-ui-max = false;
        format-volume = "<ramp-volume> <bar-volume>";
        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";
        format-muted-foreground = config.colors.foreground;
        label-muted = "婢";
        bar-volume-width = "10";
        bar-volume-foreground-0 = "#55aa55";
        bar-volume-foreground-1 = "#55aa55";
        bar-volume-foreground-2 = "#55aa55";
        bar-volume-foreground-3 = "#f5a70a";
        bar-volume-foreground-4 = "#ff5555";
        bar-volume-gradient = false;
        bar-volume-indicator = "";
        bar-volume-fill = "─";
        bar-volume-empty = "─";
        bar-volume-empty-foreground = config.colors.foreground-alt;
      };
    } // (
      builtins.listToAttrs (imap (i: interface: { name = "module/wlan-${toString i}"; value = {
        type = "internal/network";
        interface = interface;
        interval = 3;
        format-connected = "<ramp-signal> <label-connected>";
        format-connected-underline = config.colors.underline;
        label-connected = "%essid%";
        format-disconnected = "<label-disconnected>";
        label-disconnected = "%ifname% disconnected";
        label-disconnected-foreground = config.colors.foreground-alt;
        ramp-signal-0 = "";
        ramp-signal-1 = "";
        ramp-signal-2 = "";
        ramp-signal-0-foreground = "#ff0000";
        ramp-signal-1-foreground = "#ffa500";
        ramp-signal-2-foreground = "#00ff00";
      }; }) variables.wirelessInterfaces)
      ) // (
        builtins.listToAttrs (imap (i: interface: { name = "module/eth${toString i}"; value = {
          type = "internal/network";
          interface = interface;
          interval = 3;
          format-connected-underline = config.colors.underline;
          label-connected = " %local_ip%";
          format-disconnected = "";
        }; }) variables.ethernetInterfaces)
      );
    script = exec "polybar my &";
  };
  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "${context.variables.font.family} ${context.variables.font.style} ${toString context.variables.font.size}";
        allow_markup = "yes";
        plain_text = "no";
        format = "<b>%s</b>\\n%b";
        sort = "no";
        indicate_hidden = "yes";
        alignment = "center";
        bounce_freq = 0;
        show_age_threshold = -1;
        word_wrap = "yes";
        ignore_newline = "no";
        stack_duplicates = "yes";
        hide_duplicates_count = "yes";
        geometry = "300x50-15+15";
        shrink = "no";
        transparency = 50;
        idle_threshold = 0;
        monitor = 0;
        follow = "none";
        sticky_history = "yes";
        history_length = 15;
        show_indicators = "no";
        line_height = 3;
        separator_height = 2;
        padding = 6;
        horizontal_padding = 6;
        separator_color = "frame";
        startup_notification = "false";
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst:";
        browser = "${context.variables.programs.browser}";
        icon_position = "off";
        max_icon_size = 80;
        icon_folders = "${pkgs.paper-icon-theme}/share/icons/Paper/16x16/mimetypes/:${pkgs.paper-icon-theme}/share/icons/Paper/48x48/status/:${pkgs.paper-icon-theme}/share/icons/Paper/16x16/devices/:${pkgs.paper-icon-theme}/share/icons/Paper/48x48/notifications/:${pkgs.paper-icon-theme}/share/icons/Paper/48x48/emblems/";
      };
      frame = {
        width = 3;
        color = "#8EC07C";
      };
      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
      };
      urgency_low = {
        frame_color = "#A6E22E";
        foreground = "#A6E22E";
        background = "#1E1F1C";
        timeout = 10;
      };
      urgency_normal = {
        frame_color = "#66D9EF";
        foreground = "#66D9EF";
        background = "#1E1F1C";
        timeout = 20;
      };
      urgency_critical = {
        frame_color = "#F92672";
        foreground = "#F92672";
        background = "#1E1F1C";
        timeout = 30;
      };
    };
  };
  systemd.user.services.dunst.Service.ExecStart = mkForce (exec "${dunst}/bin/dunst");

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
