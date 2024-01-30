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
      i3-msg = "${profileDir}/bin/swaymsg";
      term = null;
      programs = {
        filemanager = "${pkgs.pcmanfm}/bin/pcmanfm";
        #terminal = "${xfce.terminal}/bin/xfce4-terminal";
        terminal = "${pkgs.kitty}/bin/kitty";
        # terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        #dropdown = "${dotFileAt "i3config.nix" 1} --class=ScratchTerm";
        # browser = "${pkgs.google-chrome}/bin/google-chrome-stable --enable-features=WebRTCPipeWireCapturer";
        # browser = "${pkgs.chromium}/bin/chromium --enable-features=WebRTCPipeWireCapturer";
        browser = "${profileDir}/bin/firefox";
        slack = "${pkgs.slack}/bin/slack --enable-features=WebRTCPipeWireCapturer";
        #browser = "${profileDir}/bin/google-chrome-stable";
        editor = "${nano}/bin/nano";
        #launcher = dotFileAt "bemenu.nix" 0;
        #launcher = "${pkgs.kitty}/bin/kitty --class=launcher -e env TERMINAL_COMMAND='${pkgs.kitty}/bin/kitty -e' ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
        # window-center = dotFileAt "i3config.nix" 4;
        # window-size = dotFileAt "i3config.nix" 5;
        # i3-msg = "${profileDir}/bin/swaymsg";
        #nextcloud = "${nextcloud-client}/bin/nextcloud";
        # tmux = "${pkgs.tmux}/bin/tmux";
        # tug = "${pkgs.turbogit}/bin/tug";
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
        n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${homeDir}/bin/nvim" --frame None --multigrid'';
        #g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
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
      { name = "kanshi"; delay = 2; group = "always"; }
      { name = "nextcloud-client"; delay = 3; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 3; group = "always"; }
      { name = "waybar"; delay = 1; group = "always"; }
      { name = "swayidle"; delay = 1; group = "always"; }
      { name = "gnome-keyring"; delay = 1; group = "always"; }
    ];
    config = {};
    nixos-configuration = {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
          };
        };
        vt = 2;
      };
      xdg.portal = {
        enable = true;
        wlr = {
          enable = true;
          settings = {
            screencast = let
              chooserCmd = pkgs.writeScript "chooser.sh" ''
                #!${pkgs.stdenv.shell}
                ${pkgs.sway}/bin/swaymsg -s "$(${pkgs.coreutils}/bin/realpath /run/user/$(${pkgs.coreutils}/bin/id -u)/sway*.sock)" -t get_outputs | ${pkgs.jq}/bin/jq -r '.[] | .name' | ${pkgs.wofi}/bin/wofi -d
              '';
            in {
              chooser_type = "dmenu";
              chooser_cmd = "${chooserCmd}";
              max_fps = 30;
            };
          };
        };
      };
    };
    home-configuration = rec {
      home.stateVersion = "22.05";
      wayland.windowManager.sway.enable = true;
      wayland.windowManager.sway.config.assigns = {
        #"workspace number 5" = [{ app_id = "^org.keepassxc.KeePassXC$"; }];
        "workspace number 1" = [{ class = "^Logseq$"; }];
        "workspace number 2" = [{ class = "^Slack$"; }];
        "workspace number 3" = [{ app_id = "firefox"; } { class = "^Chromium-browser$"; } { class = "^Google-chrome$"; }];
      };
      wayland.windowManager.sway.config.startup = [
        { command = "${self.variables.programs.browser}"; }
        { command = "${self.variables.programs.slack}"; }
        { command = "${self.variables.profileDir}/bin/logseq"; }
        #{ command = "${self.variables.profileDir}/bin/keepassxc"; }
        # { command = "${clearprimary}/bin/clearprimary"; }
      ];
      wayland.windowManager.sway.config.input = {
        "2:10:TPPS/2_Elan_TrackPoint" = { accel_profile = "flat"; };
      };
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
      home.packages = [
        keepassxc zoom-us pulseaudio networkmanagerapplet git-crypt jq yq-go
        logseq
        proxychains
        # (import inputs.devenv).packages.${builtins.currentSystem}.devenv
        shell_gpt
        #guake gnome.gnome-tweaks gnome-extension-manager gnomeExtensions.gsconnect
        #google-chrome
        #slack
      ];
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
      };
      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "sway";
        LIBVA_DRIVER_NAME = "iHD";
      };
      programs.chromium.enable = true;
      programs.firefox.enable = true;
      programs.firefox.package = pkgs.firefox;
    };
  };
in
  self
