{ pkgs, lib, config, inputs, dotFileAt, helper_scripts }:
with pkgs;
let
  # clearprimary = import "${inputs.clearprimary}" { inherit pkgs; };

  homeConfig = config.home-manager.users.matejc;

  self = {
    dotFilePaths = [
      "${helper_scripts}/dotfiles/programs.nix"
      "${helper_scripts}/dotfiles/nvim.nix"
      "${helper_scripts}/dotfiles/gitconfig.nix"
      "${helper_scripts}/dotfiles/gitignore.nix"
      "${helper_scripts}/dotfiles/swaylockscreen.nix"
      "${helper_scripts}/dotfiles/comma.nix"
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
      temperatureFiles = [ hwmonPath ];
      hwmonPath = "/sys/class/hwmon/hwmon2/temp1_input";
      lockscreen = "${homeDir}/bin/lockscreen";
      wallpaper = "${homeDir}/Pictures/pexels.png";
      fullName = "Matej Cotman";
      email = "matej.cotman@eficode.com";
      signingkey = "E9DCD6F3A1CF9949995C43E09D45D4C00C8A5A48";
      locale.all = "en_GB.UTF-8";
      wirelessInterfaces = [ "wlp0s20f3" ];
      ethernetInterfaces = [ ];
      mounts = [ "/" ];
      font = {
        family = "SauceCodePro Nerd Font Mono";
        size = 16.0;
        style = "Bold";
      };
      i3-msg = "${profileDir}/bin/swaymsg";
      term = null;
      programs = {
        filemanager = "${pkgs.pcmanfm}/bin/pcmanfm";
        terminal = "${pkgs.kitty}/bin/kitty";
        browser = "${profileDir}/bin/firefox";
        slack = "${pkgs.slack}/bin/slack --enable-features=WebRTCPipeWireCapturer --enable-features=UseOzonePlatform --ozone-platform=wayland";
        editor = "${nano}/bin/nano";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
        logseq = "${pkgs.logseq}/bin/logseq --enable-features=UseOzonePlatform --ozone-platform=wayland";
      };
      shell = "${profileDir}/bin/zsh";
      shellRc = "${homeDir}/.zshrc";
      sway.enable = false;
      graphical = {
        name = "niri";
        logout = "loginctl terminate-user ${self.variables.user}";
        target = "niri.service";
      };
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${homeDir}/bin/nvim";
        n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${homeDir}/bin/nvim" --frame None --multigrid'';
      };
      outputs = [{
        criteria = "eDP-1";
        position = "0,0";
        output = "eDP-1";
        mode = "2880x1800";
        scale = 1.0;
        workspaces = [ "1" "2" "3" "4" ];
        wallpaper = wallpaper;
        status = "disable";
      }{
        criteria = "HDMI-A-1";
        position = "2880,0";
        output = "HDMI-A-1";
        mode = null;
        scale = 1.0;
        workspaces = [ "5" "6" "7" "8" ];
        wallpaper = wallpaper;
        status = "enable";
      }];
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "/home/matejc/workarea/nixpkgs";
      };
      startup = [
        "${self.variables.binDir}/logseq"
        "${self.variables.binDir}/slack"
        "${self.variables.binDir}/browser"
        "${self.variables.profileDir}/bin/service-group-once start"
        "${self.variables.profileDir}/bin/service-group-always restart"
        "${self.variables.profileDir}/bin/keepassxc"
      ];
    };
    services = [
      { name = "kanshi"; delay = 2; group = "always"; }
      { name = "nextcloud-client"; delay = 3; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 3; group = "always"; }
      { name = "network-manager-applet"; delay = 3; group = "always"; }
      { name = "waybar"; delay = 2; group = "always"; }
      { name = "swayidle"; delay = 1; group = "always"; }
      { name = "gnome-keyring"; delay = 1; group = "always"; }
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
        enable = true;
        config.common.default = "gnome;gtk;";
        config.common."org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
    };
    home-configuration = rec {
      home.stateVersion = "22.05";
      services.swayidle.timeouts = [
        {
          timeout = 100;
          command = "${pkgs.brillo}/bin/brillo -U 30";
          resumeCommand = "${pkgs.brillo}/bin/brillo -A 30";
        }
      ];
      programs.waybar.enable = true;
      services.kanshi.enable = true;
      services.swayidle.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.nextcloud-client.enable = true;
      services.nextcloud-client.startInBackground = true;
      services.network-manager-applet.enable = true;
      systemd.user.services.network-manager-applet.Service.ExecStart = lib.mkForce "${networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
      systemd.user.services.kdeconnect.Service.Environment = lib.mkForce [ "PATH=${self.variables.profileDir}/bin" "QT_QPA_PLATFORM=wayland" "QT_QPA_PLATFORM_PLUGIN_PATH=${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}" ];
      systemd.user.services.kdeconnect-indicator.Service.Environment = lib.mkForce [ "PATH=${self.variables.profileDir}/bin" "QT_QPA_PLATFORM=wayland" "QT_QPA_PLATFORM_PLUGIN_PATH=${pkgs.qt5.qtwayland.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}" ];
      home.packages = [
        keepassxc zoom-us pulseaudio networkmanagerapplet git-crypt jq yq-go
        proxychains
        # (import inputs.devenv).packages.${builtins.currentSystem}.devenv
        shell_gpt
        #guake gnome.gnome-tweaks gnome-extension-manager gnomeExtensions.gsconnect
        #google-chrome
        #slack
        cage
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
      programs.firefox.package = pkgs.firefox;
    };
  };
in
  self
