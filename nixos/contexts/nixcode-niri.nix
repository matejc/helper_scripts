{ pkgs, lib, config, inputs, dotFileAt, helper_scripts }:
let
  # clearprimary = import "${inputs.clearprimary}" { inherit pkgs; };

  homeConfig = config.home-manager.users.matejc;

  nixos-wallpaper = pkgs.fetchurl {
    name = "nix-wallpaper.png";
    url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-nineish-solarized-dark.png";
    hash = "sha256-ZBrk9izKvsY4Hzsr7YovocCbkRVgUN9i/y1B5IzOOKo=";
  };

  self = {
    dotFilePaths = [
        "${helper_scripts}/dotfiles/nvim.nix"
        "${helper_scripts}/dotfiles/gitconfig.nix"
        "${helper_scripts}/dotfiles/gitignore.nix"
        "${helper_scripts}/dotfiles/swaylockscreen.nix"
        "${helper_scripts}/dotfiles/tmux.nix"
        "${helper_scripts}/dotfiles/dd.nix"
        "${helper_scripts}/dotfiles/sync.nix"
        "${helper_scripts}/dotfiles/mypassgen.nix"
        "${helper_scripts}/dotfiles/wofi.nix"
        "${helper_scripts}/dotfiles/nwgbar.nix"
        "${helper_scripts}/dotfiles/countdown.nix"
        "${helper_scripts}/dotfiles/helix.nix"
        "${helper_scripts}/dotfiles/zed.nix"
        "${helper_scripts}/dotfiles/work.nix"
        "${helper_scripts}/dotfiles/jwt.nix"
        "${helper_scripts}/dotfiles/helix.nix"
        "${helper_scripts}/dotfiles/kitty.nix"
        "${helper_scripts}/dotfiles/alacritty.nix"
        "${helper_scripts}/dotfiles/zellij.nix"
    ];
    activationScript = ''
      rm -vf ${self.variables.homeDir}/.zshrc.zwc
    '';
    variables = {
      homeDir = homeConfig.home.homeDirectory;
      user = homeConfig.home.username;
      profileDir = homeConfig.home.profileDirectory;
      prefix = "${self.variables.homeDir}/workarea/helper_scripts";
      nixpkgs = "${self.variables.homeDir}/workarea/nixpkgs";
      binDir = "${self.variables.homeDir}/bin";
      lockscreen = "${self.variables.homeDir}/bin/lockscreen";
      lockImage = ./../../assets/update.png;
      wallpaper = "${nixos-wallpaper}";
      temperatures = [
        { device = "coretemp-isa-0000"; group = "Package id 0"; field_prefix = "temp1"; }
      ];
      fullName = "Matej Cotman";
      email = "matej.cotman@eficode.com";
      signingkey = "E830DAC63C372EA6E7F0D6D90124F60926CFF815";
      locale.all = "en_GB.UTF-8";
      wirelessInterfaces = [ "wlp0s20f3" ];
      ethernetInterfaces = [ ];
      mounts = [ "/" ];
      font = {
        family = "SauceCodePro Nerd Font Mono";
        size = 12.0;
        style = "Bold";
      };
      i3-msg = "${self.variables.profileDir}/bin/niri msg";
      term = null;
      programs = {
        filemanager = "${pkgs.pcmanfm}/bin/pcmanfm";
        terminal = "${pkgs.kitty}/bin/kitty";
        browser = "${self.variables.profileDir}/bin/firefox";
        editor = "${pkgs.helix}/bin/hx";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
      };
      shell = "${self.variables.profileDir}/bin/zsh";
      shellRc = "${self.variables.homeDir}/.zshrc";
      sway.enable = false;
      graphical = {
        name = "niri";
        logout = "${self.variables.graphical.exec} msg action quit --skip-confirmation";
        target = "graphical-session.target";
        waybar.prefix = "niri";
        exec = "${self.variables.profileDir}/bin/niri";
      };
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${self.variables.homeDir}/bin/nvim";
        n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${self.variables.homeDir}/bin/nvim" --frame none'';
      };
      outputs = [{
        criteria = "eDP-1";
        position = "0,0";
        output = "eDP-1";
        mode = "2880x1800";
        scale = 1.5;
        workspaces = [ ];
        wallpaper = self.variables.wallpaper;
        status = "disable";
      } {
        criteria = "HDMI-A-1";
        position = "2880,0";
        output = "HDMI-A-1";
        mode = null;
        scale = 1.0;
        workspaces = [ ];
        wallpaper = self.variables.wallpaper;
        status = "enable";
      } {
        criteria = "DP-3";
        position = "2880,0";
        output = "DP-3";
        mode = null;
        scale = 1.0;
        workspaces = [ ];
        wallpaper = self.variables.wallpaper;
        status = "enable";
      }];
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "/home/matejc/workarea/nixpkgs";
      };
      startup = [
        "${self.variables.profileDir}/bin/logseq"
        "${self.variables.profileDir}/bin/slack"
        "${self.variables.programs.browser}"
        "${self.variables.profileDir}/bin/keepassxc"
      ];
    };
    services = [
      # { name = "kanshi"; delay = 2; group = "always"; }
      # { name = "gnome-keyring"; delay = 1; group = "always"; }
      # { name = "kdeconnect"; delay = 3; group = "always"; }
      # { name = "kdeconnect-indicator"; delay = 5; group = "always"; }
      # { name = "network-manager-applet"; delay = 3; group = "always"; }
      # { name = "wireplumber"; delay = 4; group = "always"; }
      # { name = "swayidle"; delay = 5; group = "always"; }
      { name = "network-manager-applet"; delay = 5; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 5; group = "always"; }
      { name = "nextcloud-client"; delay = 5; group = "always"; }
    ];
    config = {};
    nixos-configuration = {
      environment.systemPackages = with pkgs; [
        sbctl
        v4l-utils
      ];

      # Lanzaboote currently replaces the systemd-boot module.
      # This setting is usually set to true in configuration.nix
      # generated at installation time. So we force it to false
      # for now.
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
            user = "greeter";
          };
        };
        vt = 2;
      };
      users.users.matejc.extraGroups = [ "video" ];
      nixpkgs.config.permittedInsecurePackages = [
        "openssl-1.1.1w"
        "electron-27.3.11"
        "olm-3.2.16"
      ];
      # hardware.ipu6 = {
      #   enable = true;
      #   platform = "ipu6ep";
      # };
      boot.kernelPackages = pkgs.linuxPackages_latest;
      # systemd.services.v4l2-relayd-ipu6.environment.logSink = "SYSLOG";
      # systemd.services.v4l2-relayd-ipu6.environment.cameraDebug = "1";
      # boot.kernelPatches = [{
      #   name = "ipu6";
      #   patch = null;
      #   extraConfig = ''
      #     VIDEO_INTEL_IPU6 m
      #   '';
      # }];
      boot.blacklistedKernelModules = [ "intel_ipu6" "intel_ipu6_isys" "intel_ipu6_isys.isys" ];
      programs.niri.enable = true;
    };
    home-configuration = {
      home.stateVersion = "22.05";
      services.swayidle = {
        enable = true;
        timeouts = lib.mkForce [
            {
                timeout = 100;
                command = "${pkgs.brillo}/bin/brillo -U 30";
                resumeCommand = "${pkgs.brillo}/bin/brillo -A 30";
            }
            { timeout = 120; command = "${self.variables.binDir}/lockscreen"; }
            {
                timeout = 300;
                command = ''${self.variables.graphical.exec} msg action power-off-monitors'';
                resumeCommand = lib.concatMapStringsSep "; " (o: ''${self.variables.graphical.exec} msg output ${o.output} on'') self.variables.outputs;
            }
        ];
      };
      programs.waybar.enable = true;
      services.kanshi.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.nextcloud-client.enable = true;
      services.nextcloud-client.startInBackground = true;
      services.network-manager-applet.enable = true;
      home.packages = with pkgs; [
        slack
        logseq
        keepassxc zoom-us pulseaudio networkmanagerapplet git-crypt jq yq-go
        proxychains-ng cproxy graftcp
        helix
        aichat
        deploy-rs
        aider
        freerdp3
        file-roller

        minikube kubectl docker-machine-kvm2 k9s ttyd
      ];
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
      };
      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "niri";
        LIBVA_DRIVER_NAME = "iHD";
      };
      programs.chromium.enable = true;
      programs.firefox.enable = true;
    };
  };
in
  self
