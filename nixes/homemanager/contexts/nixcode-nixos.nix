{ pkgs, lib, config, inputs, dotFileAt }:
with pkgs;
let
  clearprimary = import "${inputs.clearprimary}" { inherit pkgs; };
  devenv = import "${inputs.devenv}" { inherit pkgs; };

  self = {
    dotFilePaths = [
      "${inputs.helper_scripts}/dotfiles/programs.nix"
      "${inputs.helper_scripts}/dotfiles/nvim.nix"
      "${inputs.helper_scripts}/dotfiles/gitconfig.nix"
      "${inputs.helper_scripts}/dotfiles/gitignore.nix"
      "${inputs.helper_scripts}/dotfiles/swaylockscreen.nix"
      "${inputs.helper_scripts}/dotfiles/comma.nix"
      "${inputs.helper_scripts}/dotfiles/tmux.nix"
      "${inputs.helper_scripts}/dotfiles/dd.nix"
      "${inputs.helper_scripts}/dotfiles/sync.nix"
      "${inputs.helper_scripts}/dotfiles/mypassgen.nix"
      "${inputs.helper_scripts}/dotfiles/wofi.nix"
      "${inputs.helper_scripts}/dotfiles/nwgbar.nix"
      "${inputs.helper_scripts}/dotfiles/wezterm.nix"
      "${inputs.helper_scripts}/dotfiles/countdown.nix"
      "${inputs.helper_scripts}/dotfiles/helix.nix"
    ];
    activationScript = ''
      rm -vf ${self.variables.homeDir}/.zshrc.zwc
    '';
    variables = rec {
      homeDir = config.home.homeDirectory;
      user = config.home.username;
      profileDir = config.home.profileDirectory;
      prefix = "${homeDir}/workarea/helper_scripts";
      nixpkgs = "${homeDir}/workarea/nixpkgs";
      #nixpkgsConfig = "${pkgs.dotfiles}/nixpkgs-config.nix";
      binDir = "${homeDir}/bin";
      temperatureFiles = [ hwmonPath ];
      hwmonPath = "/sys/class/hwmon/hwmon8/temp1_input";
      lockscreen = "${homeDir}/bin/lockscreen";
      wallpaper = "${homeDir}/Pictures/pexels.png";
      fullName = "Matej Cotman";
      email = "matej.cotman@eficode.com";
      signingkey = "E9DCD6F3A1CF9949995C43E09D45D4C00C8A5A48";
      locale.all = "en_GB.UTF-8";
      networkInterface = "wlp0s20f3";
      wirelessInterfaces = [];
      ethernetInterfaces = [ networkInterface ];
      mounts = [ "/" ];
      font = {
        family = "SauceCodePro Nerd Font Mono";
        style = "Bold";
        size = 11.0;
      };
      i3-msg = "${programs.i3-msg}";
      term = null;
      programs = {
        filemanager = "${pkgs.pcmanfm}/bin/pcmanfm";
        #terminal = "${xfce.terminal}/bin/xfce4-terminal";
        #terminal = "${pkgs.kitty}/bin/kitty";
        terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        dropdown = "${dotFileAt "i3config.nix" 1} --class=ScratchTerm";
        browser = "${profileDir}/bin/google-chrome-stable --enable-features=WebRTCPipeWireCapturer";
        slack = "${profileDir}/bin/slack --enable-features=WebRTCPipeWireCapturer";
        editor = "${nano}/bin/nano";
        #launcher = dotFileAt "bemenu.nix" 0;
        #launcher = "${pkgs.kitty}/bin/kitty --class=launcher -e env TERMINAL_COMMAND='${pkgs.kitty}/bin/kitty -e' ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
        window-center = dotFileAt "i3config.nix" 4;
        window-size = dotFileAt "i3config.nix" 5;
        i3-msg = "${profileDir}/bin/swaymsg";
        #nextcloud = "${nextcloud-client}/bin/nextcloud";
        tmux = "${pkgs.tmux}/bin/tmux";
        tug = "${pkgs.turbogit}/bin/tug";
      };
      shell = "${profileDir}/bin/zsh";
      shellRc = "${homeDir}/.zshrc";
      sway.enable = false;
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --nvim ${homeDir}/bin/nvim";
        n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${homeDir}/bin/nvim" --frame None --multigrid'';
        g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
      };
      outputs = [{
        criteria = "Unknown 0x4152 0x00000000";
        position = "0,0";
        output = "eDP-1";
        mode = "2880x1800";
        scale = 1.5;
        workspaces = [ "5" "6" "7" "8" ];
        wallpaper = wallpaper;
      }];
    };
    services = [
      { name = "kanshi"; delay = 2; group = "always"; }
      { name = "syncthingtray"; delay = 3; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 3; group = "always"; }
      { name = "waybar"; delay = 1; group = "always"; }
      { name = "swayidle"; delay = 1; group = "always"; }
    ];
    config = {};
    home-configuration = {
      home.stateVersion = "22.05";
      wayland.windowManager.sway.config.assigns = {
        "5" = [{ app_id = "^org.keepassxc.KeePassXC$"; }];
        "6" = [{ class = "^Slack$"; }];
        "7" = [{ class = "^Firefox$"; } { class = "^Chromium-browser$"; } { class = "^Google-chrome$"; }];
      };
      wayland.windowManager.sway.config.startup = [
        { command = "${self.variables.programs.browser}"; }
        { command = "${self.variables.programs.slack}"; }
        { command = "${self.variables.profileDir}/bin/keepassxc"; }
        { command = "${clearprimary}/bin/clearprimary"; }
      ];
      wayland.windowManager.sway.config.input = {
        "2:10:TPPS/2_Elan_TrackPoint" = { pointer_accel = "-0.3"; };
      };
      services.kanshi.enable = true;
      services.swayidle.enable = true;
      services.swayidle.timeouts = [
        {
          timeout = 100;
          command = "${pkgs.brillo}/bin/brillo -U 40";
          resumeCommand = "${pkgs.brillo}/bin/brillo -A 40";
        }
      ];
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.syncthing.enable = true;
      services.syncthing.extraOptions = [ "-home=${self.variables.homeDir}/Syncthing/.config/syncthing" ];
      services.network-manager-applet.enable = true;
      systemd.user.services.network-manager-applet.Service.ExecStart = lib.mkForce "${networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
      home.packages = [ google-chrome slack keepassxc zoom-us networkmanagerapplet wezterm devenv ];
      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "sway";
        LIBVA_DRIVER_NAME = "iHD";
      };
      programs.firefox.enable = true;
    };
  };
in
  self
