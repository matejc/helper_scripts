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
        "${helper_scripts}/dotfiles/programs.nix"
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
        "${helper_scripts}/dotfiles/wezterm.nix"
        "${helper_scripts}/dotfiles/work.nix"
        "${helper_scripts}/dotfiles/jwt.nix"
        "${helper_scripts}/dotfiles/helix.nix"
        "${helper_scripts}/dotfiles/kitty.nix"
        "${helper_scripts}/dotfiles/vlc.nix"
        "${helper_scripts}/dotfiles/zed.nix"
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
      temperatureFiles = [ self.variables.hwmonPath ];
      hwmonPath = "/sys/class/hwmon/hwmon2/temp1_input";
      lockscreen = "${self.variables.homeDir}/bin/lockscreen";
      wallpaper = "${nixos-wallpaper}";
      fullName = "Matej Cotman";
      email = "matej.cotman@eficode.com";
      signingkey = "E9DCD6F3A1CF9949995C43E09D45D4C00C8A5A48";
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
        logout = "${self.variables.graphical.exec} msg action quit";
        target = "graphical-session.target";
        waybar.prefix = "niri";
        exec = "${self.variables.profileDir}/bin/niri";
      };
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${self.variables.homeDir}/bin/nvim";
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
      { name = "nextcloud-client"; delay = 3; group = "always"; }
      # { name = "kdeconnect"; delay = 3; group = "always"; }
      # { name = "kdeconnect-indicator"; delay = 5; group = "always"; }
      # { name = "network-manager-applet"; delay = 3; group = "always"; }
      # { name = "waybar"; delay = 2; group = "always"; }
      # { name = "swayidle"; delay = 1; group = "always"; }
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


      hardware.enableRedistributableFirmware = true;
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      boot.extraModprobeConfig = ''
        options v4l2loopback nr_devices=0
      '';
      hardware.ipu6 = {
        enable = true;
        platform = "ipu6ep";
      };
      boot.kernelPackages = pkgs.linuxPackages_6_11;
      boot.kernelPatches = [ {
        name = "0001";
        patch = (pkgs.fetchurl { url = "https://raw.githubusercontent.com/intel/ipu6-drivers/refs/heads/master/patch/v6.11/in-tree-build/0001-media-ipu6-Workaround-to-build-PSYS.patch"; hash = "sha256-C64madWtm6GgKNGyWijZt8oLm2g08NmlIdCxbgVFi6c="; });
      } {
        name = "0002";
        patch = (pkgs.fetchurl { url = "https://raw.githubusercontent.com/intel/ipu6-drivers/refs/heads/master/patch/v6.11/in-tree-build/0002-media-i2c-Add-sensors-config.patch"; hash = "sha256-zNsuIVyzhasCzNBuUsHTR3Wx10qUJkUz+DViSN68/1Y="; });
      } {
        name = "0003";
        patch = (pkgs.fetchurl { url = "https://raw.githubusercontent.com/intel/ipu6-drivers/refs/heads/master/patch/v6.11/0003-media-ipu6-Use-module-parameter-to-set-isys-psys-fre.patch"; hash = "sha256-e+hRwXvJmUiMhQfwLYfDGst7oGRgjef3HkNGVkCP4xU="; });
      } {
        name = "0004";
        patch = (pkgs.fetchurl { url = "https://raw.githubusercontent.com/intel/ipu6-drivers/refs/heads/master/patch/v6.11/0004-media-ipu6-Don-t-disable-ATS-when-CPU-is-not-Meteor-.patch"; hash = "sha256-BhsxiKOrvQEwBHWMT00FlUK7c8GlaP0VJFGeAMHORUI="; });
      } {
        name = "0005";
        patch = (pkgs.fetchurl { url = "https://raw.githubusercontent.com/intel/ipu6-drivers/refs/heads/master/patch/v6.11/0005-media-ipu-bridge-Support-ov05c10-sensor.patch"; hash = "sha256-uU9cMbS1JHhJF+jx1+JXzzlYOIYW7Z+n2M3+ZJ+l2oE="; });
      } {
        name = "ipu6-config";
        patch = null;
        extraConfig = ''
          VIDEO_OV2740 m
          VIDEO_INTEL_IPU6 m
          IPU_BRIDGE m
          VIDEO_OV01A10 m
          I2C_LJCA m
          SPI_LJCA m
          GPIO_LJCA m
          USB_LJCA m
          INTEL_MEI_VSC m
          INTEL_MEI_VSC_HW m
          INTEL_VSC m
        '';
      } ];
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
      programs.niri.enable = true;
      programs.waybar.enable = true;
      # programs.waybar.systemd.target = lib.mkForce "non-existing-target";
      services.kanshi.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.nextcloud-client.enable = true;
      services.nextcloud-client.startInBackground = true;
      services.network-manager-applet.enable = true;
      # systemd.user.services.kdeconnect.Service.Environment = lib.mkForce [ "PATH=${self.variables.profileDir}/bin" "QT_QPA_PLATFORM=wayland" "QT_QPA_PLATFORM_PLUGIN_PATH=${pkgs.qt6.qtwayland.out}/${pkgs.qt6.qtbase.qtPluginPrefix}" ];
      # systemd.user.services.kdeconnect.Install.WantedBy = lib.mkForce [ "non-existing-target" ];
      # systemd.user.services.kdeconnect-indicator.Install.WantedBy = lib.mkForce [ "non-existing-target" ];
      # systemd.user.services.kdeconnect-indicator.Unit.Requires = lib.mkForce [ ];
      # systemd.user.services.kdeconnect-indicator.Service.Environment = lib.mkForce [ "PATH=${self.variables.profileDir}/bin" "QT_QPA_PLATFORM=wayland" "QT_QPA_PLATFORM_PLUGIN_PATH=${pkgs.qt6.qtwayland}/${pkgs.qt6.qtbase.qtPluginPrefix}" ];
      home.packages = with pkgs; [
        slack
        logseq
        keepassxc zoom-us pulseaudio networkmanagerapplet git-crypt jq yq-go
        proxychains-ng
        helix
        aichat
        deploy-rs
        aider
        freerdp3
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
