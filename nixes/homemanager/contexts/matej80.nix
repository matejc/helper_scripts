{ pkgs, lib, config, inputs, dotFileAt, helper_scripts }:
with pkgs;
let
  homeConfig = config.home-manager.users.matejc;

  self = {
    dotFilePaths = [
      "${helper_scripts}/dotfiles/programs.nix"
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
      "${helper_scripts}/dotfiles/comma.nix"
      "${helper_scripts}/dotfiles/kitty.nix"
      "${helper_scripts}/dotfiles/dd.nix"
      "${helper_scripts}/dotfiles/sync.nix"
      "${helper_scripts}/dotfiles/mypassgen.nix"
      "${helper_scripts}/dotfiles/wofi.nix"
      "${helper_scripts}/dotfiles/nwgbar.nix"
      "${helper_scripts}/dotfiles/helix.nix"
      "${helper_scripts}/dotfiles/vlc.nix"
      "${helper_scripts}/dotfiles/mac.nix"
    ];
    activationScript = ''
      rm -vf ${self.variables.homeDir}/.zshrc.zwc
    '';
    variables = rec {
      homeDir = homeConfig.home.homeDirectory;
      user = homeConfig.home.username;
      profileDir = homeConfig.home.profileDirectory;
      prefix = "${homeDir}/workarea/helper_scripts";
      nixpkgs = "${homeDir}/workarea/nixpkgs";
      binDir = "${homeDir}/bin";
      lockscreen = "${homeDir}/bin/lockscreen";
      wallpaper = "${homeDir}/Pictures/pexels.png";
      fullName = "Matej Cotman";
      email = "matej@matejc.com";
      signingkey = "7F71148FAFC9B2EFE02FB9F466FDC7A2EEA1F8A6";
      locale.all = "en_US.UTF-8";
      networkInterface = "br0";
      wirelessInterfaces = [ "wlp3s0" ];
      ethernetInterfaces = [ networkInterface ];
      mounts = [ "/" ];
      font = {
        family = "SauceCodePro Nerd Font Mono";
        style = "Bold";
        size = 10.0;
      };
      i3-msg = "${profileDir}/bin/swaymsg";
      term = null;
      programs = {
        filemanager = "${pcmanfm}/bin/pcmanfm";
        terminal = "${pkgs.kitty}/bin/kitty";
        browser = "${profileDir}/bin/firefox";
        editor = "${helix}/bin/hx";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
      };
      shell = "${profileDir}/bin/zsh";
      shellRc = "${homeDir}/.zshrc";
      sway.enable = false;
      graphical = {
        name = "sway";
        logout = "${pkgs.sway}/bin/swaymsg exit";
        target = "sway-session.target";
      };
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${homeDir}/bin/nvim";
      };
      outputs = [{
        criteria = "eDP-1";
        position = "0,0";
        output = "eDP-1";
        mode = "1920x1080";
        workspaces = [ "1" "2" "3" "4" ];
        wallpaper = wallpaper;
        scale = 1.0;
        status = "enable";
      } {
        criteria = "HDMI-A-1";
        position = "1920,0";
        output = "HDMI-A-1";
        mode = "1920x1080";
        workspaces = [ "5" ];
        wallpaper = wallpaper;
        scale = 1.0;
        status = "enable";
      }];
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "/home/matejc/workarea/nixpkgs";
      };
    };
    services = [
      { name = "kanshi"; delay = 2; group = "always"; }
      { name = "kdeconnect"; delay = 3; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 3; group = "always"; }
      { name = "network-manager-applet"; delay = 3; group = "always"; }
      { name = "waybar"; delay = 1; group = "always"; }
      { name = "swayidle"; delay = 1; group = "always"; }
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
      fonts.packages = [ pkgs.corefonts pkgs.font-awesome (pkgs.nerdfonts.override { fonts = [ "SourceCodePro" "FiraCode" "FiraMono" ]; }) ];
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
    };
    home-configuration = {
      home.stateVersion = "23.05";
      wayland.windowManager.sway.enable = true;
      wayland.windowManager.sway.config.startup = [
        { command = "${self.variables.programs.browser}"; }
      ];
      wayland.windowManager.sway.config.input = {
        "1267:47:Elan_TrackPoint" = { accel_profile = "flat"; };
      };
      services.kanshi.enable = true;
      services.swayidle.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.syncthing.enable = true;
      services.syncthing.extraOptions = [ "-home=${self.variables.homeDir}/Syncthing/.config/syncthing" ];
      programs.waybar.enable = true;
      home.packages = [ ];
      programs.chromium.enable = true;
      services.network-manager-applet.enable = true;
      systemd.user.services.network-manager-applet.Service.ExecStart = lib.mkForce "${networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
      programs.firefox = {
        enable = true;
        package = pkgs.firefox;
      };
    };
  };
in
  self
