{ pkgs, lib, config, inputs, dotFileAt }:
with pkgs;
let
  self = {
    dotFilePaths = [
      "${inputs.helper_scripts}/dotfiles/programs.nix"
      "${inputs.helper_scripts}/dotfiles/nvim.nix"
      "${inputs.helper_scripts}/dotfiles/xfce4-terminal.nix"
      "${inputs.helper_scripts}/dotfiles/gitconfig.nix"
      "${inputs.helper_scripts}/dotfiles/gitignore.nix"
      "${inputs.helper_scripts}/dotfiles/nix.nix"
      "${inputs.helper_scripts}/dotfiles/oath.nix"
      "${inputs.helper_scripts}/dotfiles/jstools.nix"
      "${inputs.helper_scripts}/dotfiles/superslicer.nix"
      "${inputs.helper_scripts}/dotfiles/scan.nix"
      "${inputs.helper_scripts}/dotfiles/swaylockscreen.nix"
      "${inputs.helper_scripts}/dotfiles/comma.nix"
      "${inputs.helper_scripts}/dotfiles/tmux.nix"
    ];
    activationScript = ''
      mkdir -vp ${self.variables.homeDir}/.supervisord/
      mkdir -vp ${self.variables.homeDir}/.xdg-runtime-dir/
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
      locale.all = "en_US.UTF-8";
      networkInterface = "br0";
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
        filemanager = "${cinnamon.nemo}/bin/nemo";
        #terminal = "${xfce.terminal}/bin/xfce4-terminal";
        terminal = "${pkgs.kitty}/bin/kitty";
        dropdown = "${dotFileAt "i3config.nix" 1} --class=ScratchTerm";
        browser = "${profileDir}/bin/chromium";
        editor = "${nano}/bin/nano";
        launcher = dotFileAt "bemenu.nix" 0;
        #launcher = "${pkgs.xfce.terminal}/bin/xfce4-terminal --title Launcher --hide-scrollbar --hide-toolbar --hide-menubar --drop-down -x ${homeDir}/bin/sway-launcher-desktop";
        window-size = dotFileAt "i3config.nix" 2;
        window-center = dotFileAt "i3config.nix" 3;
        i3-msg = "${profileDir}/bin/swaymsg";
        nextcloud = "${nextcloud-client}/bin/nextcloud";
        keepassxc = "${pkgs.keepassxc}/bin/keepassxc";
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
      outputs = [];
    };
    services = [
      { name = "kanshi"; delay = 2; group = "always"; }
      { name = "nextcloud-client"; delay = 3; group = "always"; }
      { name = "kdeconnect"; delay = 3; group = "always"; }
      { name = "kdeconnect-indicator"; delay = 4; group = "always"; }
      { name = "blueman-applet"; delay = 3; group = "always"; }
      { name = "gnome-keyring"; delay = 1; group = "always"; }
    ];
    config = {};
    home-configuration = {
      wayland.windowManager.sway.config.startup = [
        { command = "${self.variables.programs.browser}"; }
        { command = "${self.variables.programs.keepassxc}"; }
      ];
    };
  };
in
  self
