{ pkgs, lib, config, inputs, dotFileAt }:
with pkgs;
let
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
      signingkey = "";
      locale.all = "en_US.UTF-8";
      networkInterface = "eth0";
      wirelessInterfaces = [];
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
        filemanager = "${pkgs.pcmanfm}/bin/pcmanfm";
        #terminal = "${xfce.terminal}/bin/xfce4-terminal";
        #terminal = "${pkgs.kitty}/bin/kitty";
        terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        dropdown = "${dotFileAt "i3config.nix" 1} --class=ScratchTerm";
        browser = "${profileDir}/bin/google-chrome-stable --enable-features=WebRTCPipeWireCapturer";
        editor = "${nano}/bin/nano";
        #launcher = dotFileAt "bemenu.nix" 0;
        #launcher = "${pkgs.kitty}/bin/kitty --class=launcher -e env TERMINAL_COMMAND='${pkgs.kitty}/bin/kitty -e' ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
        window-center = dotFileAt "i3config.nix" 4;
        window-size = dotFileAt "i3config.nix" 5;
        i3-msg = "${profileDir}/bin/swaymsg";
        #nextcloud = "${nextcloud-client}/bin/nextcloud";
        tmux = "${pkgs.tmux}/bin/tmux";
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
        output = "HEADLESS-1";
        criteria = "HEADLESS-1";
        position = "0,0";
        mode = "1920x1080@60Hz";
        workspaces = [ "1" ];
        scale = 1.0;
        wallpaper = "${pkgs.sway}/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png";
      }];
    };
    services = [
      { name = "gnome-keyring"; delay = 1; group = "always"; }
    ];
    config = {};
    home-configuration = {
      home.stateVersion = "22.11";
      home.sessionVariables.WSL_INTEROP = "$(realpath /run/WSL/*_interop | head -n 1)";
      wayland.windowManager.sway.config.startup = [
        { command = "${self.variables.programs.browser}"; }
      ];
    };
  };
in
  self
