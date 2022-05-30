{ inputs }:
{ pkgs, lib, config, ... }@args:
with lib;
with pkgs;
let
  #config = builtins.trace args.config.home-manager.users.matejc args;

  #nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #  inherit pkgs;
  #};

  nur = import inputs.nur { nurpkgs = pkgs; inherit pkgs; };

  #nixmySrc = builtins.fetchGit {
  #  url = "https://github.com/matejc/nixmy.git";
  #};

  dotfiles = import "${inputs.helper_scripts}/dotfiles/default.nix"
    { name = "homemanager"; exposeScript = true; inherit context; }
    { inherit pkgs lib config; };

  dotFileAt = file: at:
    (elemAt (import "${inputs.helper_scripts}/dotfiles/${file}" { inherit lib pkgs; inherit (context) variables config; }) at).source;

  context.dotFilePaths = [
    "${inputs.helper_scripts}/dotfiles/programs.nix"
    "${inputs.helper_scripts}/dotfiles/nvim.nix"
    "${inputs.helper_scripts}/dotfiles/xfce4-terminal.nix"
    "${inputs.helper_scripts}/dotfiles/gitconfig.nix"
    "${inputs.helper_scripts}/dotfiles/gitignore.nix"
    "${inputs.helper_scripts}/dotfiles/nix.nix"
    "${inputs.helper_scripts}/dotfiles/oath.nix"
    "${inputs.helper_scripts}/dotfiles/jstools.nix"
    "${inputs.helper_scripts}/dotfiles/superslicer.nix"
    "${inputs.helper_scripts}/dotfiles/scan.nix"
    "${inputs.helper_scripts}/dotfiles/swaylockscreen.nix"
    "${inputs.helper_scripts}/dotfiles/comma.nix"
  ];
  context.activationScript = ''
    mkdir -p ${context.variables.homeDir}/.supervisord/
    mkdir -p ${context.variables.homeDir}/.xdg-runtime-dir/
  '';
  context.variables = rec {
    homeDir = config.home.homeDirectory;
    user = config.home.username;
    profileDir = config.home.profileDirectory;
    prefix = "${homeDir}/workarea/helper_scripts";
    nixpkgs = "${homeDir}/workarea/nixpkgs";
    #nixpkgsConfig = "${pkgs.dotfiles}/nixpkgs-config.nix";
    binDir = "${homeDir}/bin";
    temperatureFiles = [ hwmonPath ];
    hwmonPath = "/sys/class/hwmon/hwmon1/temp1_input";
    lockscreen = "${homeDir}/bin/lockscreen";
    lockImage = "${homeDir}/Pictures/blade-of-grass-blur.png";
    wallpaper = "${homeDir}/Pictures/pexels.png";
    fullName = "Matej Cotman";
    email = "matej@matejc.com";
    locale.all = "en_US.UTF-8";
    networkInterface = "br0";
    wirelessInterfaces = [];
    ethernetInterfaces = [ networkInterface ];
    mounts = [ "/" ];
    font = {
      family = "SauceCodePro Nerd Font Mono";
      style = "Bold";
      size = 10.0;
    };
    i3-msg = "${programs.i3-msg}";
    term = null;
    programs = {
      filemanager = "${cinnamon.nemo}/bin/nemo";
      #terminal = "${xfce.terminal}/bin/xfce4-terminal";
      terminal = "${pkgs.kitty}/bin/kitty";
      dropdown = "${dotFileAt "i3config.nix" 1} --class=ScratchTerm";
      browser = "${profileDir}/bin/chromium";
      editor = "${nano}/bin/nano";
      launcher = dotFileAt "bemenu.nix" 0;
      #launcher = "${pkgs.xfce.terminal}/bin/xfce4-terminal --title Launcher --hide-scrollbar --hide-toolbar --hide-menubar --drop-down -x ${homeDir}/bin/sway-launcher-desktop";
      window-size = dotFileAt "i3config.nix" 2;
      window-center = dotFileAt "i3config.nix" 3;
      i3-msg = "${profileDir}/bin/swaymsg";
      nextcloud = "${nextcloud-client}/bin/nextcloud";
      keepassxc = "${pkgs.keepassxc}/bin/keepassxc";
      tmux = "${pkgs.tmux}/bin/tmux";
      tug = "${pkgs.turbogit}/bin/tug";
      supervisorctl = "${pkgs.python3Packages.supervisor}/bin/supervisorctl --serverurl=unix://${homeDir}/.supervisor.sock";
      supervisord = "${pkgs.python3Packages.supervisor}/bin/supervisord --configuration=${supervisorConf}";
      sway = sway_exec;
    };
    shell = "${profileDir}/bin/zsh";
    sway.enable = false;
    vims = {
      q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --nvim ${homeDir}/bin/nvim";
      n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${homeDir}/bin/nvim" --frame None --multigrid'';
      g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
    };
    outputs = [{
      criteria = "Samsung Electric Company S24F350 H4ZN501371";
      position = "0,0";
      output = "HDMI-A-2";
      workspaces = [ "1" "2" ];
      wallpaper = wallpaper;
    } {
      criteria = "BenQ Corporation BenQ GL2480 ETPBL0133504U";
      position = "1920,0";
      output = "HDMI-A-1";
      workspaces = [ "3" ];
      wallpaper = wallpaper;
    }];
    supervisor.programs = [
      { name = "waybar"; cmd = "${waybar}/bin/waybar"; delay = 1; always = true; }
      { name = "mako"; cmd = "${mako}/bin/mako"; delay = 2; always = true; }
      { name = "kanshi"; cmd = "${kanshi}/bin/kanshi"; delay = 2; always = true; }
      { name = "nextcloud"; cmd = "${nextcloud-client}/bin/nextcloud --background"; delay = 3; always = true; }
      { name = "kdeconnect"; cmd = "${kdeconnect_custom}/bin/kdeconnectd"; delay = 3; always = true; }
      { name = "kdeconnect-indicator"; cmd = "${kdeconnect_custom}/bin/kdeconnect-indicator"; delay = 4; always = true; }
      { name = "blueman-applet"; cmd = "${blueman}/bin/blueman-applet"; delay = 3; always = true; }
      { name = "gnome-keyring"; cmd = "${gnome.gnome-keyring}/bin/gnome-keyring-daemon --start --foreground --components=secrets"; delay = 1; always = true; }
      { name = "browser"; cmd = "${context.variables.programs.browser}"; delay = 0; always = false; }
      { name = "keepassxc"; cmd = "${context.variables.programs.keepassxc}"; delay = 0; always = false; }
    ];
  };
  context.config = {};

  sway_exec = pkgs.writeScript "sway.sh" ''
    #!${pkgs.stdenv.shell}
    trap 'kill $(cat ${context.variables.homeDir}/.supervisord.pid)' EXIT
    ${context.variables.profileDir}/bin/sway $@
  '';

  kdeconnect_custom = pkgs.kdeconnect.overrideDerivation (old: {
    postInstall = ''
      ln -s $out/libexec/kdeconnectd $out/bin/kdeconnectd
    '';
  });

  exec = { name, cmd, delay ? 0 }: "${writeScript "exec.sh" ''
    #!${context.variables.shell}
    systemctl disable --now ${name} || true
    ${pkgs.coreutils}/bin/sleep ${toString delay}
    source "${context.variables.homeDir}/.zshrc"
    exec ${cmd}
  ''}";

  execRestart = binName: cmd: writeScript "${binName}-restart-script.sh" ''
    #!${context.variables.shell}
    ${procps}/bin/pkill ${binName}
    source "${context.variables.homeDir}/.zshrc"
    exec ${cmd}
  '';

  supervisorConf = writeText "supervisord.conf" ''
    [supervisord]
    directory = ${context.variables.homeDir}/.supervisord
    user = ${context.variables.user}
    pidfile = ${context.variables.homeDir}/.supervisord.pid
    logfile = ${context.variables.homeDir}/.supervisord/supervisord.log
    logfile_maxbytes = 10MB

    [unix_http_server]
    file = ${context.variables.homeDir}/.supervisor.sock

    [rpcinterface:supervisor]
    supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

    [supervisorctl]
    serverurl = unix://${context.variables.homeDir}/.supervisor.sock

    [group:always]
    programs = ${concatMapStringsSep "," (p: "${p.name}") (filter (p: p.always) context.variables.supervisor.programs)}

    [group:once]
    programs = ${concatMapStringsSep "," (p: "${p.name}") (filter (p: !p.always) context.variables.supervisor.programs)}

    ${concatMapStringsSep "\n" (p: ''
    [program:${p.name}]
    command = ${exec { inherit (p) name cmd delay; }}
    environment = PATH="${context.variables.profileDir}/bin:${context.variables.binDir}:%(ENV_PATH)s",XDG_RUNTIME_DIR="%(ENV_XDG_RUNTIME_DIR)s",DISPLAY="%(ENV_DISPLAY)s",WAYLAND_DISPLAY="%(ENV_WAYLAND_DISPLAY)s",SWAYSOCK="%(ENV_SWAYSOCK)s",${concatMapStringsSep "," (s: "${s.name}=\"${s.value}\"") (mapAttrsToList (name: value: {inherit name value;}) config.home.sessionVariables)}
    priority = 1
    directory = ${context.variables.homeDir}
    user = ${context.variables.user}
    numprocs = 1
    autostart = false
    autorestart = unexpected
    startretries = 3
    startsecs = ${toString (p.delay + 2)}
    exitcodes = 0
    stopsignal = TERM
    stopwaitsecs = 10
    stopasgroup = true
    killasgroup = true
    redirect_stderr = true
    stdout_logfile = ${context.variables.homeDir}/.supervisord/${p.name}.log
    stdout_logfile_maxbytes = 10MB
    '') context.variables.supervisor.programs}
  '';

  # https://nix-community.github.io/home-manager/options.html
in {
    nixpkgs.config = import "${inputs.helper_scripts}/dotfiles/nixpkgs-config.nix";
    xdg = {
      enable = true;
      #configFile."nixpkgs/config.nix".source = "nixpkgs-config.nix";
    };

    #services.gnome-keyring = {
      #enable = true;
    #};
    #systemd.user.services.gnome-keyring.Service.ExecStart = mkForce "/wrappers/gnome-keyring-daemon --start --foreground --components=secrets";

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
      cinnamon.nemo
      kdeconnect_custom
      zsh
      (import "${inputs.nixmy}/default.nix" { inherit pkgs lib; config = args.config; })
    ];
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
      profiles.default.outputs = map (o: { inherit (o) criteria position; }) context.variables.outputs;
    };

    #services.kdeconnect = {
    #  enable = true;
    #  indicator = true;
    #};

    wayland.windowManager.sway = {
      enable = true;
      systemdIntegration = true;
      config = rec {
        assigns = {
          "1" = [{ app_id = "^org.keepassxc.KeePassXC$"; }];
          "2" = [{ class = "^Firefox$"; } { class = "^Chromium-browser$"; }];
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
          };
        modifier = "Mod4";
        startup = [
          { command = "${context.variables.binDir}/supervisord"; }
          { command = "sleep 1 && ${context.variables.binDir}/supervisorctl restart 'always:*'"; always = true; }
          { command = "sleep 1 && ${context.variables.binDir}/supervisorctl start 'once:*'"; }
          #(startupEntry { cmd = "systemctl --user restart waybar"; delay = 2; always = true; })
          #(startupEntry { cmd = "systemctl --user restart kanshi"; delay = 2; always = true; })
          #(startupEntry { cmd = "systemctl --user restart nextcloud-client"; delay = 3; })
          #(startupEntry { cmd = "systemctl --user restart kdeconnect"; delay = 3; })
          #(startupEntry { cmd = "systemctl --user restart kdeconnect-indicator"; delay = 4; })
          #(startupEntry { cmd = "systemctl --user restart blueman-applet"; delay = 3; })
          #(startupEntry { cmd = "${mako}/bin/mako"; delay = 2; kill = "mako"; always = true; })
          #(startupEntry { cmd = "${context.variables.programs.terminal}"; })
          #(startupEntry { cmd = "${context.variables.programs.browser}"; })
          #(startupEntry { cmd = "${context.variables.programs.keepassxc}"; })
        ];
        window = {
          border = 1;
          commands = [
            #{ command = "mark I3WM_SCRATCHPAD"; criteria = { app_id = "ScratchTerm"; }; }
            #{ command = "border pixel 1"; criteria = { class = "Xfce4-terminal"; }; }
            #{ command = "border pixel 1"; criteria = { class = ".nvim-qt-wrapped"; }; }
            #{ command = "border pixel 1"; criteria = { class = "Firefox"; }; }
            #{ command = "border pixel 1"; criteria = { class = "Chromium-browser"; }; }
          ];
        };
        workspaceOutputAssign = flatten (map (o: map (w: { workspace = w; inherit (o) output; }) o.workspaces) context.variables.outputs);
        output = builtins.listToAttrs (map (o: { name = o.output; value = { bg = "${o.wallpaper} fill"; }; }) context.variables.outputs);
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

  services.blueman-applet.enable = true;

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
      modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" "sway/window" ];
      modules-center = [ ];
      modules-right = [ "pulseaudio" "idle_inhibitor" "keyboard-state" "bluetooth" "network" "battery" "cpu" "temperature" "clock" "tray" ];
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
        on-click-right = "${blueman}/bin/blueman-manager";
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
  #programs.waybar.systemd.enable = true;
  #programs.waybar.systemd.target = "sway-session.target";

  programs.mako = {
    enable = true;
  };

  #services.nextcloud-client.enable = true;
  #systemd.user.services.nextcloud-client.Service.ExecStart = mkForce (exec "${nextcloud-client}/bin/nextcloud --background");

  home.activation.dotfiles = ''
    $DRY_RUN_CMD ${dotfiles}/bin/dot-files-apply-homemanager
    $DRY_RUN_CMD rm -fv ${context.variables.homeDir}/.zshrc.zwc
  '';

  home.activation.checkLinkTargets = mkForce "true";

  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    initExtra = ''
      ${readFile (dotFileAt "zsh.nix" 0)}

      . "${pkgs.nix}/etc/profile.d/nix.sh"
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    '';
    loginExtra = readFile (dotFileAt "zsh.nix" 1);
  };
  programs.starship = {
    enable = true;
    settings = {
      character.success_symbol = "[❯](bold green) ";
      character.error_symbol = "[✗](bold red) ";
    };
  };
}
