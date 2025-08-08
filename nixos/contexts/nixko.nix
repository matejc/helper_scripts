{
  pkgs,
  lib,
  config,
  inputs,
  dotFileAt,
  helper_scripts,
}:
let
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
      "${helper_scripts}/dotfiles/dd.nix"
      "${helper_scripts}/dotfiles/sync.nix"
      "${helper_scripts}/dotfiles/mypassgen.nix"
      "${helper_scripts}/dotfiles/wofi.nix"
      "${helper_scripts}/dotfiles/nwgbar.nix"
      "${helper_scripts}/dotfiles/countdown.nix"
      "${helper_scripts}/dotfiles/zed.nix"
      "${helper_scripts}/dotfiles/work.nix"
      "${helper_scripts}/dotfiles/jwt.nix"
      "${helper_scripts}/dotfiles/helix.nix"
      "${helper_scripts}/dotfiles/kitty.nix"
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
      binDir = "${self.variables.profileDir}/bin";
      lockscreen = "${self.variables.profileDir}/bin/lockscreen";
      lockImage = ./../../assets/update.png;
      wallpaper = "${nixos-wallpaper}";
      temperatures = [
        {
          device = "k10temp-pci-00c3";
          group = "Tctl";
          field_prefix = "temp1";
        }
      ];
      fullName = "Matej Cotman";
      email = "matej.cotman@kumorion.com";
      signingkey = "429264DEEB7036EE8B426AA9E97E56DFA314778A";
      locale.all = "en_GB.UTF-8";
      wirelessInterfaces = [ "wlp192s0" ];
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
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${self.variables.profileDir}/bin/nvim";
        n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${self.variables.profileDir}/bin/nvim" --frame none'';
      };
      outputs = [
        {
          criteria = "eDP-1";
          position = "0,0";
          output = "eDP-1";
          mode = "2256x1504";
          scale = 1.2;
          workspaces = [ ];
          wallpaper = self.variables.wallpaper;
          status = "enable";
        }
      ];
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "${inputs.nixpkgs}";
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
      {
        name = "network-manager-applet";
        delay = 5;
        group = "always";
      }
      {
        name = "kdeconnect-indicator";
        delay = 5;
        group = "always";
      }
    ];
    config = { };
    nixos-configuration = {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
            user = "greeter";
          };
        };
      };
      nixpkgs.config.permittedInsecurePackages = [
        "openssl-1.1.1w"
        "electron-27.3.11"
        "olm-3.2.16"
      ];
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      programs.niri.enable = true;
      hardware.bluetooth.enable = true;
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
      '';
      hardware.graphics = {
        enable = true;
      };
      services.power-profiles-daemon.enable = lib.mkForce false;
    };
    home-configuration = {
      home.stateVersion = "25.05";
      services.swayidle = {
        enable = true;
        timeouts = lib.mkForce [
          {
            timeout = 100;
            command = "${pkgs.brillo}/bin/brillo -U 30";
            resumeCommand = "${pkgs.brillo}/bin/brillo -A 30";
          }
          {
            timeout = 120;
            command = "${self.variables.profileDir}/bin/lockscreen";
          }
          {
            timeout = 300;
            command = ''${self.variables.graphical.exec} msg action power-off-monitors'';
            resumeCommand = lib.concatMapStringsSep "; " (
              o: ''${self.variables.graphical.exec} msg output ${o.output} on''
            ) self.variables.outputs;
          }
        ];
      };
      programs.waybar.enable = true;
      services.kanshi.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.network-manager-applet.enable = true;
      home.packages = with pkgs; [
        slack
        notion-desktop
        teams-for-linux
        logseq
        keepassxc
        pulseaudio
        networkmanagerapplet
        git-crypt
        jq
        yq-go
        proxychains-ng
        cproxy
        graftcp
        freerdp3
        file-roller
        eog
        minikube kubectl docker-machine-kvm2 ttyd
        asdf-vm unzip stdenv.cc gnumake python313Packages.python colima docker docker-compose ansible
        devenv
      ];
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
      };
      programs.chromium.enable = true;
      programs.firefox.enable = true;
      programs.zsh.initContent = ''
        . "${pkgs.asdf-vm}/share/asdf-vm/asdf.sh"
        autoload -Uz bashcompinit && bashcompinit
        . "${pkgs.asdf-vm}/share/asdf-vm/completions/asdf.bash"
      '';
    };
  };
in
self
