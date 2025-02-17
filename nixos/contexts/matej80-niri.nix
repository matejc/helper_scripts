{ pkgs, lib, config, helper_scripts, inputs, ... }:
let
  homeConfig = config.home-manager.users.matejc.home;

  # looking-glass-client = pkgs.callPackage ../../nixes/looking-glass-client.nix {};
  # looking-glass-obs = pkgs.obs-studio-plugins.looking-glass-obs.override { inherit looking-glass-client; };

  nixos-artwork-wallpaper = pkgs.fetchurl {
    name = "nix-wallpaper-nineish-dark-gray.png";
    url = "https://github.com/NixOS/nixos-artwork/blob/master/wallpapers/nix-wallpaper-nineish-dark-gray.png?raw=true";
    hash = "sha256-nhIUtCy/Hb8UbuxXeL3l3FMausjQrnjTVi1B3GkL9B8=";
  };

  self = {
    dotFilePaths = [
      "${helper_scripts}/dotfiles/nvim.nix"
      "${helper_scripts}/dotfiles/xfce4-terminal.nix"
      "${helper_scripts}/dotfiles/gitconfig.nix"
      "${helper_scripts}/dotfiles/gitignore.nix"
      "${helper_scripts}/dotfiles/nix.nix"
      "${helper_scripts}/dotfiles/oath.nix"
      "${helper_scripts}/dotfiles/jstools.nix"
      "${helper_scripts}/dotfiles/superslicer.nix"
      "${helper_scripts}/dotfiles/scan.nix"
      "${helper_scripts}/dotfiles/swaylockscreen.nix"
      "${helper_scripts}/dotfiles/kitty.nix"
      "${helper_scripts}/dotfiles/dd.nix"
      "${helper_scripts}/dotfiles/sync.nix"
      "${helper_scripts}/dotfiles/mypassgen.nix"
      "${helper_scripts}/dotfiles/wofi.nix"
      "${helper_scripts}/dotfiles/nwgbar.nix"
      "${helper_scripts}/dotfiles/helix.nix"
      "${helper_scripts}/dotfiles/vlc.nix"
      "${helper_scripts}/dotfiles/mac.nix"
      "${helper_scripts}/dotfiles/steam.nix"
    ];
    activationScript = ''
      rm -vf ${self.variables.homeDir}/.zshrc.zwc
    '';
    variables = {
      homeDir = homeConfig.homeDirectory;
      user = homeConfig.username;
      profileDir = homeConfig.profileDirectory;
      prefix = "${self.variables.homeDir}/workarea/helper_scripts";
      nixpkgs = "${self.variables.homeDir}/workarea/nixpkgs";
      binDir = "${self.variables.homeDir}/bin";
      lockscreen = "${self.variables.binDir}/lockscreen";
      lockImage = "";
      wallpaper = "${nixos-artwork-wallpaper}";
      fullName = "Matej Cotman";
      email = "matej@matejc.com";
      signingkey = "7F71148FAFC9B2EFE02FB9F466FDC7A2EEA1F8A6";
      locale.all = "en_US.UTF-8";
      networkInterface = "eno1";
      wirelessInterfaces = [ "wlp3s0" ];
      ethernetInterfaces = [ self.variables.networkInterface ];
      mounts = [ "/" "/mnt/games" ];
      # hwmonPath = "/sys/class/hwmon/hwmon2/temp1_input";
      font = {
        family = "SauceCodePro Nerd Font Mono";
        style = "Bold";
        size = 10.0;
      };
      term = null;
      programs = {
        filemanager = "${pkgs.pcmanfm}/bin/pcmanfm";
        #terminal = "${xfce.terminal}/bin/xfce4-terminal";
        terminal = "${pkgs.kitty}/bin/kitty";
        # terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        #dropdown = "env WAYLAND_DISPLAY=no  ${pkgs.tdrop}/bin/tdrop -mta -w -4 -y 90% terminal";
        #dropdown = "${dotFileAt "i3config.nix" 1} --class=ScratchTerm";
        #dropdown = "${sway-scratchpad}/bin/sway-scratchpad -c ${pkgs.wezterm}/bin/wezterm -a 'start --always-new-process' -m terminal";
        #browser = "${profileDir}/bin/chromium";
        browser = "${self.variables.profileDir}/bin/firefox";
        editor = "${pkgs.helix}/bin/hx";
        #launcher = dotFileAt "bemenu.nix" 0;
        #launcher = "${pkgs.kitty}/bin/kitty --class=launcher -e env TERMINAL_COMMAND='${pkgs.kitty}/bin/kitty -e' ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
        #window-center = dotFileAt "i3config.nix" 4;
        #window-size = dotFileAt "i3config.nix" 5;
        #i3-msg = "${profileDir}/bin/swaymsg";
        #nextcloud = "${nextcloud-client}/bin/nextcloud";
        #keepassxc = "${pkgs.keepassxc}/bin/keepassxc";
        #tmux = "${pkgs.tmux}/bin/tmux";
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
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${self.variables.binDir}/nvim";
        n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${self.variables.homeDir}/bin/nvim" --frame none'';
        # g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
      };
      outputs = [{
        criteria = "eDP-1";
        position = "0,0";
        output = "eDP-1";
        mode = "1920x1080";
        workspaces = [ "1" "2" "3" "4" ];
        wallpaper = nixos-artwork-wallpaper;
        scale = 1.0;
        status = "enable";
      } {
        criteria = "HDMI-A-1";
        position = "1920,0";
        output = "HDMI-A-1";
        mode = "1920x1080";
        workspaces = [ "5" ];
        wallpaper = nixos-artwork-wallpaper;
        scale = 1.0;
        status = "enable";
      }];
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "/home/matejc/workarea/nixpkgs";
      };
      startup = [
        "${self.variables.programs.browser}"
        "${self.variables.profileDir}/bin/chromium"
        "${self.variables.programs.terminal}"
        "${pkgs.keepassxc}/bin/keepassxc"
        "${self.variables.profileDir}/bin/logseq"
      ];
      steam = {
        xrun = [
          "swiftpoint"
        ];
        library = "/mnt/games/SteamLibrary";
        run = {
          # "2420110".compatibilityTool = "SteamTinkerLaunch";
          # "1898300".compatibilityTool = "GE-Proton9-11";
          # "2074920".compatibilityTool = "GE-Proton9-11";
          # "1716740".compatibilityTool = "SteamTinkerLaunch";
        };
      };
    };
    services = [
      # { name = "kanshi"; delay = 1; group = "always"; }
      #{ name = "syncthingtray"; delay = 3; group = "always"; }
      # { name = "kdeconnect"; delay = 4; group = "always"; }
      # { name = "wireplumber"; delay = 4; group = "always"; }
      # { name = "swayidle"; delay = 5; group = "always"; }
      { name = "network-manager-applet"; delay = 5; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 5; group = "always"; }
    ];
    config = {};
    nixos-configuration = {
      hardware.opengl.enable = true;
      hardware.opengl.extraPackages = with pkgs; [ vaapiIntel intel-media-driver ];
      networking.networkmanager.enable = true;
      services.dbus.packages = [ pkgs.dconf ];
      services.gnome.at-spi2-core.enable = true;
      services.gnome.gnome-keyring.enable = true;
      services.accounts-daemon.enable = true;
      fonts.packages = [ pkgs.corefonts pkgs.font-awesome pkgs.nerd-fonts.sauce-code-pro pkgs.nerd-fonts.fira-code pkgs.nerd-fonts.fira-mono ];
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = with pkgs; [
        vulkan-tools
        wl-clipboard
      ];
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
          };
        };
        vt = 2;
      };
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      networking.firewall = {
        allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
        allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
      };
      services.fprintd.enable = true;
      services.fprintd.tod.enable = true;
      services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
      security.pam.services.swaylock.fprintAuth = true;
      services.tailscale.enable = true;
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
      '';
      hardware.bluetooth.enable = true;
      nixpkgs.config.permittedInsecurePackages = [
        "electron-27.3.11"
      ];
    };
    home-configuration = {
      home.stateVersion = "23.05";
      programs.niri.enable = true;
      services.kanshi.enable = true;
      services.swayidle.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.syncthing.enable = true;
      services.syncthing.extraOptions = [ "-home=${self.variables.homeDir}/Syncthing/.config/syncthing" ];
      programs.waybar.enable = true;
      home.packages = [ pkgs.networkmanagerapplet ];
      programs.firefox.enable = true;
      programs.chromium.enable = true;
      services.network-manager-applet.enable = true;
      systemd.user.services.network-manager-applet.Service.ExecStart = lib.mkForce "${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";

    };
  };
in
  self
