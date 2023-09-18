{ pkgs, lib, config, inputs, dotFileAt, helper_scripts }:
with pkgs;
let
  homeConfig = config.home-manager.users.matejc;

  self = {
    dotFilePaths = [
      "${helper_scripts}/dotfiles/programs.nix"
      "${helper_scripts}/dotfiles/nvim.nix"
      "${helper_scripts}/dotfiles/gitconfig.nix"
      "${helper_scripts}/dotfiles/gitignore.nix"
      "${helper_scripts}/dotfiles/nix.nix"
      "${helper_scripts}/dotfiles/oath.nix"
      "${helper_scripts}/dotfiles/jstools.nix"
      "${helper_scripts}/dotfiles/superslicer.nix"
      "${helper_scripts}/dotfiles/scan.nix"
      "${helper_scripts}/dotfiles/comma.nix"
      "${helper_scripts}/dotfiles/dd.nix"
      "${helper_scripts}/dotfiles/sync.nix"
      "${helper_scripts}/dotfiles/mypassgen.nix"
      "${helper_scripts}/dotfiles/wofi.nix"
      "${helper_scripts}/dotfiles/nwgbar.nix"
      "${helper_scripts}/dotfiles/wezterm.nix"
      "${helper_scripts}/dotfiles/helix.nix"
      "${helper_scripts}/dotfiles/vlc.nix"
      "${helper_scripts}/dotfiles/mac.nix"
      "${helper_scripts}/dotfiles/swaylockscreen.nix"
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
      term = null;
      programs = {
        filemanager = "${pcmanfm}/bin/pcmanfm";
        terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        dropdown = "${pkgs.procps}/bin/pgrep '.*wezterm.*dropdown.*' -fl || ${pkgs.wezterm}/bin/wezterm start --always-new-process --class dropdown-terminal";
        passwords = "${pkgs.procps}/bin/pgrep 'keepassxc$' || ${pkgs.keepassxc}/bin/keepassxc";
        browser = "${profileDir}/bin/firefox";
        editor = "${helix}/bin/hx";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
      };
      shell = "${profileDir}/bin/zsh";
      shellRc = "${homeDir}/.zshrc";
      sway.enable = false;
      graphical = let
        logoutCmd = pkgs.writeShellScript "logout.sh" ''
          (  # execute in subshell so that `shopt` won't affect other scripts
            shopt -s nullglob  # so that nothing is done if /tmp/hypr/ does not exist or is empty
            for instance in /tmp/hypr/*; do
              HYPRLAND_INSTANCE_SIGNATURE=''${instance##*/} ${profileDir}/bin/hyprctl dispatch exit \
                || true  # ignore dead instance(s)
            done
          )
        '';
      in {
        name = "hyprland";
        logout = "${logoutCmd}";
        target = "hyprland-session.target";
      };
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${homeDir}/bin/nvim";
        # n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${homeDir}/bin/nvim" --frame none'';
        # g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
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
      { name = "waybar"; delay = 3; group = "always"; }
      { name = "network-manager-applet"; delay = 3; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 3; group = "always"; }
    ];
    config = {};
    nixos-configuration = {
      xdg.portal = {
        enable = true;
        wlr.enable = false;
        extraPortals = [ inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland ];
      };
      nix.settings = {
        substituters = ["https://hyprland.cachix.org"];
        trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
      };
      services.greetd = {
        enable = lib.mkDefault true;
        settings = {
          default_session = {
            command = lib.mkForce "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          };
        };
        vt = lib.mkDefault 2;
      };
    };
    home-configuration = {
      home.stateVersion = "20.09";
      wayland.windowManager.hyprland.enable = true;

      services.swayidle = {
        enable = true;
        events = lib.mkForce [
          { event = "before-sleep"; command = "${self.variables.binDir}/lockscreen"; }
          { event = "lock"; command = "${self.variables.binDir}/lockscreen"; }
          { event = "after-resume"; command = "hyprctl dispatch dpms on"; }
          { event = "unlock"; command = "hyprctl dispatch dpms on"; }
        ];
        timeouts = lib.mkForce [
          { timeout = 120; command = "${self.variables.binDir}/lockscreen --grace 3"; }
          {
            timeout = 300;
            command = "hyprctl dispatch dpms off";
            resumeCommand = "hyprctl dispatch dpms on";
          }
          { timeout = 3600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
        ];
      };

      programs.waybar.enable = true;
      services.kanshi.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.syncthing.enable = true;
      services.syncthing.extraOptions = [ "-home=${self.variables.homeDir}/Syncthing/.config/syncthing" ];
      programs.obs-studio = {
        enable = true;
        plugins = [ pkgs.obs-studio-plugins.looking-glass-obs pkgs.obs-studio-plugins.wlrobs ];
      };
      home.packages = [ super-slicer-latest solvespace keepassxc libreoffice ];
      programs.chromium.enable = true;
      services.network-manager-applet.enable = true;
      systemd.user.services.network-manager-applet.Service.ExecStart = lib.mkForce "${networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-beta-bin;
      };
    };
  };
in
  self
