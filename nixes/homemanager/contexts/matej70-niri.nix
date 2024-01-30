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
      lockImage = "${homeDir}/Pictures/blade-of-grass-blur.png";
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
        name = "niri";
        logout = "loginctl terminate-user ${self.variables.user}";
        target = "graphical-session.target";
      };
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${homeDir}/bin/nvim";
      };
      outputs = [{
        criteria = "HDMI-A-2";
        position = "0,0";
        output = "HDMI-A-2";
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
      { name = "kdeconnect-indicator"; delay = 3; group = "always"; }
      { name = "network-manager-applet"; delay = 3; group = "always"; }
      { name = "waybar"; delay = 2; group = "always"; }
      { name = "swayidle"; delay = 1; group = "always"; }
    ];
    config = {};
    nixos-configuration = {
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
      programs.niri.enable = true;
      xdg.portal = {
        config.common.default = "gnome;gtk;";
        config.common."org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
    };
    home-configuration = {
      home.stateVersion = "20.09";
      services.kanshi.enable = true;
      services.swayidle.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.syncthing.enable = true;
      services.syncthing.extraOptions = [ "-home=${self.variables.homeDir}/Syncthing/.config/syncthing" ];
      programs.waybar.enable = true;
      programs.obs-studio = {
        enable = true;
        plugins = [ pkgs.obs-studio-plugins.looking-glass-obs pkgs.obs-studio-plugins.wlrobs ];
      };
      home.packages = [ cage super-slicer-latest solvespace keepassxc libreoffice shell_gpt caprine-bin freetube ];
      programs.chromium.enable = true;
      services.network-manager-applet.enable = true;
      systemd.user.services.network-manager-applet.Service.ExecStart = lib.mkForce "${networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
      systemd.user.services.kdeconnect.Service.Environment = lib.mkForce [ "PATH=${self.variables.profileDir}/bin" "QT_QPA_PLATFORM=wayland" "QT_QPA_PLATFORM_PLUGIN_PATH=${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}" ];
      systemd.user.services.kdeconnect-indicator.Service.Environment = lib.mkForce [ "PATH=${self.variables.profileDir}/bin" "QT_QPA_PLATFORM=wayland" "QT_QPA_PLATFORM_PLUGIN_PATH=${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}" ];
      programs.firefox = {
        enable = true;
        package = pkgs.firefox;
      };
    };
  };
in
  self
