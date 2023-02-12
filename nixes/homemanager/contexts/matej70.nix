{ pkgs, lib, config, inputs, dotFileAt, helper_scripts }:
with pkgs;
let
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
      "${helper_scripts}/dotfiles/tmux.nix"
      "${helper_scripts}/dotfiles/kitty.nix"
      "${helper_scripts}/dotfiles/dd.nix"
      "${helper_scripts}/dotfiles/sync.nix"
      "${helper_scripts}/dotfiles/mypassgen.nix"
      "${helper_scripts}/dotfiles/wofi.nix"
      "${helper_scripts}/dotfiles/nwgbar.nix"
      "${helper_scripts}/dotfiles/wezterm.nix"
      "${helper_scripts}/dotfiles/helix.nix"
      "${helper_scripts}/dotfiles/vlc.nix"
      "${helper_scripts}/dotfiles/nwgbar.nix"
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
      hwmonPath = "/sys/class/hwmon/hwmon1/temp1_input";
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
      i3-msg = "${programs.i3-msg}";
      term = null;
      programs = {
        filemanager = "${pcmanfm}/bin/pcmanfm";
        #terminal = "${xfce.terminal}/bin/xfce4-terminal";
        #terminal = "${pkgs.kitty}/bin/kitty";
        terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        #dropdown = "${dotFileAt "i3config.nix" 1} --class=ScratchTerm";
        #dropdown = "${sway-scratchpad}/bin/sway-scratchpad -c ${pkgs.wezterm}/bin/wezterm -a 'start --always-new-process' -m terminal";
        browser = "${profileDir}/bin/chromium";
        editor = "${nano}/bin/nano";
        #launcher = dotFileAt "bemenu.nix" 0;
        #launcher = "${pkgs.kitty}/bin/kitty --class=launcher -e env TERMINAL_COMMAND='${pkgs.kitty}/bin/kitty -e' ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
        window-center = dotFileAt "i3config.nix" 4;
        window-size = dotFileAt "i3config.nix" 5;
        i3-msg = "${profileDir}/bin/swaymsg";
        nextcloud = "${nextcloud-client}/bin/nextcloud";
        #keepassxc = "${pkgs.keepassxc}/bin/keepassxc";
        tmux = "${pkgs.tmux}/bin/tmux";
      };
      shell = "${profileDir}/bin/zsh";
      shellRc = "${homeDir}/.zshrc";
      sway.enable = false;
      vims = {
        q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --nvim ${homeDir}/bin/nvim";
        n = ''${pkgs.neovide}/bin/neovide --neovim-bin "${homeDir}/bin/nvim" --frame none'';
        g = "${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-tabline --disable-ext-popupmenu --disable-ext-cmdline";
      };
      outputs = [{
        criteria = "Samsung Electric Company S24F350 H4ZN501371";
        position = "0,0";
        output = "HDMI-A-2";
        mode = "1920x1080";
        workspaces = [ "1" "2" "3" "4" ];
        wallpaper = wallpaper;
        scale = 1.0;
      } {
        criteria = "BNQ BenQ GL2480 ETPBL0133504U";
        position = "1920,0";
        output = "HDMI-A-1";
        mode = "1920x1080";
        workspaces = [ "5" ];
        wallpaper = wallpaper;
        scale = 1.0;
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
      home.stateVersion = "20.09";
      wayland.windowManager.sway.config.startup = [
        { command = "${self.variables.programs.browser}"; }
        #{ command = "${self.variables.programs.keepassxc}"; }
        { command = "${pkgs.xiccd}/bin/xiccd"; }
      ];
      services.kanshi.enable = true;
      services.swayidle.enable = true;
      services.kdeconnect.enable = true;
      services.kdeconnect.indicator = true;
      services.syncthing.enable = true;
      services.syncthing.extraOptions = [ "-home=${self.variables.homeDir}/Syncthing/.config/syncthing" ];
      services.syncthing.tray.enable = true;
      programs.obs-studio = {
        enable = true;
        plugins = [ pkgs.obs-studio-plugins.looking-glass-obs pkgs.obs-studio-plugins.wlrobs ];
      };
      home.packages = [ super-slicer solvespace nixgl.nixVulkanIntel nixgl.nixGLIntel ];
    };
  };
in
  self
