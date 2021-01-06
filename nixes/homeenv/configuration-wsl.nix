{ pkgs, lib, config, ... }:
with lib;
with pkgs;
let
  dotfiles = import ../../dotfiles/default.nix
    { name = "hm-wsl"; exposeScript = true; inherit context; }
    { inherit pkgs lib config; };

  dotFileAt = file: at:
    (elemAt (import file { inherit lib pkgs; inherit (context) variables config; }) at).source;

  context.dotFilePaths = [
    ../../dotfiles/programs.nix
    ../../dotfiles/nvim.nix
    ../../dotfiles/xfce4-terminal.nix
    ../../dotfiles/gitconfig.nix
    ../../dotfiles/gitignore.nix
    ../../dotfiles/nix.nix
    ../../dotfiles/oath.nix
    ../../dotfiles/jstools.nix
    ../../dotfiles/superslicer.nix
  ];
  context.activationScript = "";
  context.variables = rec {
    fullName = "Matej Cotman";
    email = "matej@matejc.com";
    locale.all = "en_US.UTF-8";
    flake = "${homeDir}/workarea/helper_scripts/nixes/homeenv#wsl";
    wirelessInterfaces = [];
    ethernetInterfaces = [ "eth0" ];
    mounts = [ "/" ];
    font = {
      family = "FiraCode Nerd Font Mono";
      style = "Regular";
      size = "11";
    };
    i3-msg = "${programs.i3-msg}";
    homeDir = config.home.homeDirectory;
    user = config.home.username;
    profileDir = config.home.profileDirectory;
    wallpaper = "${homeDir}/Pictures/wallpaper.jpg";
    term = null;
    programs = {
      filemanager = "${xfce.thunar}/bin/thunar";
      terminal = "${xfce.terminal}/bin/xfce4-terminal";
      dropdown = "${dotFileAt ../../dotfiles/i3config.nix 1} --role=ScratchTerm";
      browser = "${profileDir}/bin/chromium";
      editor = "${nano}/bin/nano";
      launcher = dotFileAt ../../dotfiles/bemenu.nix 0;
      window-size = dotFileAt ../../dotfiles/i3config.nix 2;
      window-center = dotFileAt ../../dotfiles/i3config.nix 3;
      i3-msg = "${i3}/bin/i3-msg";
      setup-systemd = setupSystemd;
      activate = activate;
      "startwm.sh" = startwm;
    };
    shell = "${profileDir}/bin/zsh";
    sway.enable = false;
  };
  context.config = {};

  activate = writeScript "activate.sh" ''
    #!${context.variables.shell}
    set -e
    ${nixFlakes}/bin/nix --experimental-features "nix-command flakes" build --impure "${context.variables.flake}" --out-link "${context.variables.homeDir}/.last-activate-result" "$@"
    ${context.variables.homeDir}/.last-activate-result/activate
  '';

  startScriptRoot = writeScript "start-script-root.sh" ''
    #!${stdenv.shell}

    sysctl -w fs.inotify.max_user_watches=524288
    systemctl start xrdp

    exit 0
  '';

  setupSystemd = writeScript "setup-systemd.sh" ''
    #!${stdenv.shell}

    set -e

    apt-get update
    apt-get install -y dbus policykit-1 daemonize xrdp wslu binfmt-support
    ln -sfv ${context.variables.homeDir}/.var/bash /usr/bin/bash

    echo "/bin/sh" > /etc/shells
    echo "/bin/bash" >> /etc/shells
    echo "/usr/bin/bash" >> /etc/shells
    echo "${context.variables.shell}" >> /etc/shells

    chsh --shell /usr/bin/bash root
    chsh --shell ${context.variables.shell} ${context.variables.user}

    ln -svf ${context.variables.homeDir}/.var/rc.local /etc/rc.local

    ln -svf ${context.variables.homeDir}/.var/startwm.sh /etc/xrdp/startwm.sh

    sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini

    systemctl enable xrdp

    echo 1 > /proc/sys/fs/binfmt_misc/WSLInterop

    echo -e "\nRun: wsl.exe --shutdown"
    echo -e "Run: ubuntu2004.exe config --default-user root\n"
  '';

  fakeBash = pkgs.writeScript "fake-bash.sh" ''
    #!${stdenv.shell}

    UNAME="${context.variables.user}"

    UUID=$(id -u "''${UNAME}")
    UGID=$(id -g "''${UNAME}")
    UHOME=$(getent passwd "''${UNAME}" | cut -d: -f6)
    USHELL=$(getent passwd "''${UNAME}" | cut -d: -f7)

    if [[ -p /dev/stdin || "''${BASH_ARGC}" > 0 && "''${BASH_ARGV[1]}" != "-c" ]]; then
        USHELL=${stdenv.shell}
    fi

    if [[ "''${PWD}" = "/root" ]]; then
        cd "''${UHOME}"
    fi

    # get pid of systemd
    SYSTEMD_PID=$(pgrep -xo systemd)

    # if we're already in the systemd environment
    if [[ "''${SYSTEMD_PID}" -eq "1" ]]; then
        exec "''${USHELL}" "$@"
    fi

    # start systemd if not started
    daemonize -l "''${HOME}/.systemd.lock" /usr/bin/unshare -fp --mount-proc /lib/systemd/systemd --system-unit=basic.target 2>/dev/null
    # wait for systemd to start
    while [[ "''${SYSTEMD_PID}" = "" ]]; do
        sleep 0.5
        SYSTEMD_PID=$(pgrep -xo systemd)
    done

    # enter systemd namespace
    exec /usr/bin/nsenter -t "''${SYSTEMD_PID}" -m -p --wd="''${PWD}" /sbin/runuser -s "''${USHELL}" "''${UNAME}" -- "''${@}"
  '';

  startwm = exec "${context.variables.profileDir}/bin/i3";

  exec = cmd: "${writeScript "exec.sh" ''
    #!${context.variables.shell}
    source "${context.variables.homeDir}/.zshrc"
    exec ${cmd}
  ''}";

  # https://nix-community.github.io/home-manager/options.html
in
  {
    imports = [ ./pulse.nix ];
    nixpkgs.config = import "${builtins.toString ./.}/../../dotfiles/nixpkgs-config.nix";
    xdg = {
      enable = true;
      configFile."nixpkgs/config.nix".source = "${builtins.toString ./.}/../../dotfiles/nixpkgs-config.nix";
      dataFile."icons".source = "${context.variables.profileDir}/share/icons";
      dataFile."themes".source = "${context.variables.profileDir}/share/themes";
      dataFile."fonts".source = "${context.variables.profileDir}/share/fonts";
      dataFile."mime".source = "${context.variables.profileDir}/share/mime";
    };
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      font-awesome
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      xorg.xauth
      xfce.terminal
      git
    ];
    home.file.".var/rc.local".source = startScriptRoot;
    home.file.".var/bash".source = fakeBash;
    home.file.".var/startwm.sh".source = startwm;

    gtk = {
      enable = true;
      font.name = "${context.variables.font.family} ${context.variables.font.style} ${context.variables.font.size}";
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
      package = chromium.override { enableVaapi = true; };
      extensions = [
        "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      ];
    };

    programs.firefox = {
      enable = false;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        https-everywhere ublock-origin
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

    targets.genericLinux.enable = true;
    programs.i3status.enable = false;

    xsession.windowManager.i3 = {
      enable = true;
      config = rec {
        assigns = {
          "2" = [{ window_role = "^xfce4-terminal.*"; }];
          "3" = [{ class = "^.nvim-qt-wrapped$"; }];
          "4" = [{ class = "^Firefox$"; } { class = "^Chromium-browser$"; }];
        };
        bars = [];
        colors = {
          background = "#ff0000";
          focused = { background = "#272822"; border = "#272822"; childBorder = "#66D9EF"; indicator = "#66D9EF"; text = "#A6E22E"; };
          focusedInactive = { background = "#272822"; border = "#272822"; childBorder = "#272822"; indicator = "#272822"; text = "#66D9EF"; };
          unfocused = { background = "#1E1F1C"; border = "#1E1F1C"; childBorder = "#272822"; indicator = "#272822"; text = "#939393"; };
          urgent = { background = "#F92672"; border = "#F92672"; childBorder = "#F92672"; indicator = "#F92672"; text = "#FFFFFF"; };
        };
        fonts = [ "${context.variables.font.family} ${context.variables.font.style} ${context.variables.font.size}" ];
        keybindings =
          mkOptionDefault {
            "${modifier}+Control+t" = "exec ${context.variables.programs.terminal}";
            "${modifier}+Control+h" = "exec ${context.variables.programs.filemanager} '${context.variables.homeDir}'";
            "F12" = "exec ${context.variables.programs.dropdown}";
            "${modifier}+Control+k" = "kill";
            "${modifier}+Control+space" = "exec ${context.variables.programs.launcher}";
            "Control+Tab" = "workspace back_and_forth";
            "${modifier}+Control+Left" = "exec WSNUM=$(${dotFileAt ../../dotfiles/i3_workspace.nix 0} --skip prev) && ${context.variables.i3-msg} workspace $WSNUM";
            "${modifier}+Control+Right" = "exec WSNUM=$(${dotFileAt ../../dotfiles/i3_workspace.nix 0} --skip next) && ${context.variables.i3-msg} workspace $WSNUM";
            "${modifier}+Control+Shift+Left" = "exec WSNUM=$(${dotFileAt ../../dotfiles/i3_workspace.nix 0} prev) && ${context.variables.i3-msg} move workspace $WSNUM && ${context.variables.i3-msg} workspace $WSNUM";
            "${modifier}+Control+Shift+Right" = "exec WSNUM=$(${dotFileAt ../../dotfiles/i3_workspace.nix 0} next) && ${context.variables.i3-msg} move workspace $WSNUM && ${context.variables.i3-msg} workspace $WSNUM";
          };
          modifier = "Mod1";
          startup = [
            { command = "systemctl --user restart polybar"; always = true; }
            { command = "systemctl --user restart dunst"; always = true; }
            { command = "${pkgs.xorg.xrdb}/bin/xrdb -load ${context.variables.homeDir}/.Xresources"; always = true; }
            { command = "${pkgs.feh}/bin/feh --bg-fill ${context.variables.wallpaper}"; always = true; }
            { command = "${context.variables.programs.browser}"; }
            { command = "${context.variables.programs.terminal}"; }
          ];
          window = {
            border = 1;
            commands = [
              { command = "border pixel 1"; criteria = { class = "Xfce4-terminal"; }; }
              { command = "border pixel 1"; criteria = { class = ".nvim-qt-wrapped"; }; }
              { command = "border pixel 1"; criteria = { class = "Firefox"; }; }
              { command = "border pixel 1"; criteria = { class = "Chromium-browser"; }; }
            ];
          };
        };
  };

  services.polybar =
    let
      variables = context.variables;
      pulse = true;
    in rec {
      enable = true;
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
        font-0 = "${context.variables.font.family}:style=${context.variables.font.style}:size=${context.variables.font.size}";
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
        font = "${context.variables.font.family} ${context.variables.font.style} ${context.variables.font.size}";
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

  services.pulse.enable = false;

  home.activation.dotfiles = hm.dag.entryBefore ["writeBoundary"] ''
    $DRY_RUN_CMD ${dotfiles}
    $DRY_RUN_CMD rm -fv ${context.variables.homeDir}/.zshrc.zwc
  '';
  home.activation.instructions = hm.dag.entryAfter ["writeBoundary"] ''
    echo -e "\nTo setup systemd under WSL2,"
    echo -e "run as root: ${setupSystemd}\n"
  '';
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    initExtra = ''
      ${readFile (dotFileAt ../../dotfiles/zsh.nix 0)}

      . "${pkgs.nix}/etc/profile.d/nix.sh"
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    '';
    loginExtra = readFile (dotFileAt ../../dotfiles/zsh.nix 1);
  };
  programs.starship = {
    enable = true;
    settings = {
      character.success_symbol = "[❯](bold green) ";
      character.error_symbol = "[✗](bold red) ";
    };
  };

  # TODO:
  # - start.ps1 and start.ahk to /mnt/c/tools/
}
