{ pkgs, lib, config, inputs, dotFileAt, helper_scripts }:
with pkgs;
let
  homeConfig = config.home-manager.users.matejc;

  hyprCmd = pkgs.writeShellScript "hypr-cmd.sh" ''
    (  # execute in subshell so that `shopt` won't affect other scripts
      shopt -s nullglob  # so that nothing is done if /tmp/hypr/ does not exist or is empty
      for instance in /tmp/hypr/*; do
        HYPRLAND_INSTANCE_SIGNATURE=''${instance##*/} ${self.variables.profileDir}/bin/hyprctl "$@" \
          || true  # ignore dead instance(s)
      done
    )
  '';

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
      #nixpkgsConfig = "${pkgs.dotfiles}/nixpkgs-config.nix";
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
        size = 12.0;
        style = "Bold";
      };
      i3-msg = "${programs.i3-msg}";
      term = null;
      programs = {
        filemanager = "${pcmanfm}/bin/pcmanfm";
        terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        dropdown = "${pkgs.procps}/bin/pgrep '.*wezterm.*dropdown.*' -fl || ${pkgs.wezterm}/bin/wezterm start --always-new-process --class dropdown-terminal";
        passwords = "${pkgs.procps}/bin/pgrep 'keepassxc$' || ${pkgs.keepassxc}/bin/keepassxc";
        browser = "${profileDir}/bin/firefox";
        editor = "${helix}/bin/hx";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
        slack = "${pkgs.slack}/bin/slack --enable-features=WebRTCPipeWireCapturer";
      };
      shell = "${profileDir}/bin/zsh";
      shellRc = "${homeDir}/.zshrc";
      sway.enable = false;
      graphical = let
        logoutCmd = "${hyprCmd} dispatch exit";
      in {
        name = "hyprland";
        logout = "${logoutCmd}";
        target = "hyprland-session.target";
      };
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --maximized --nvim ${homeDir}/bin/nvim";
        # n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${homeDir}/bin/nvim" --frame None --multigrid'';
        # g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
      };
      outputs = [{
        criteria = "eDP-1";
        position = "0,0";
        output = "eDP-1";
        mode = "2880x1800@60.001Hz";
        scale = 1.5;
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
    };
    services = [
      { name = "kanshi"; delay = 1; group = "always"; }
      { name = "nextcloud-client"; delay = 3; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 3; group = "always"; }
      { name = "network-manager-applet"; delay = 3; group = "always"; }
      { name = "waybar"; delay = 2; group = "always"; }
      { name = "swayidle"; delay = 1; group = "always"; }
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
    home-configuration = rec {
      home.stateVersion = "22.05";
      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.extraConfig = ''
        exec-once = [workspace 1 silent] ${pkgs.logseq}/bin/logseq
        exec-once = [workspace 2 silent] ${self.variables.binDir}/slack
        exec-once = [workspace 3] ${self.variables.binDir}/browser
      '';
      services.swayidle = {
        enable = true;
        events = lib.mkForce [
          { event = "before-sleep"; command = "${self.variables.binDir}/lockscreen"; }
          { event = "lock"; command = "${self.variables.binDir}/lockscreen"; }
          { event = "after-resume"; command = "${hyprCmd} dispatch dpms on"; }
          { event = "unlock"; command = "${hyprCmd} dispatch dpms on"; }
        ];
        timeouts = lib.mkForce [
          {
            timeout = 100;
            command = "${pkgs.brillo}/bin/brillo -U 30";
            resumeCommand = "${pkgs.brillo}/bin/brillo -A 30";
          }
          { timeout = 120; command = "${self.variables.binDir}/lockscreen --grace 3"; }
          {
            timeout = 300;
            command = "${hyprCmd} dispatch dpms off";
            resumeCommand = "${hyprCmd} dispatch dpms on";
          }
          { timeout = 3600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
        ];
      };

      programs.waybar.enable = true;
      services.kanshi.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.nextcloud-client.enable = true;
      services.nextcloud-client.startInBackground = true;
      services.network-manager-applet.enable = true;
      home.packages = [
        keepassxc zoom-us pulseaudio networkmanagerapplet git-crypt jq yq-go
        logseq
      ];
      # home.sessionVariables = {
      #   XDG_CURRENT_DESKTOP = "sway";
      #   LIBVA_DRIVER_NAME = "iHD";
      # };
      programs.chromium.enable = true;
      programs.firefox.enable = true;
      programs.firefox.package = pkgs.firefox-beta-bin;
    };
  };
in
  self
