{ pkgs, lib, config, inputs, dotFileAt, helper_scripts, homeConfig }:
with pkgs;
let
  clearprimary = import "${inputs.clearprimary}" { inherit pkgs; };
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
      "${helper_scripts}/dotfiles/batstatus.nix"
      "${helper_scripts}/dotfiles/kitty.nix"
      "${helper_scripts}/dotfiles/startup.nix"
      "${helper_scripts}/dotfiles/wofi.nix"
      "${helper_scripts}/dotfiles/wezterm.nix"
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
      batteries = [ "0" ];
      temperatureFiles = [ hwmonPath ];
      hwmonPath = "/sys/class/hwmon/hwmon1/temp1_input";
      lockscreen = "${homeDir}/bin/lockscreen";
      lockImage = "${homeDir}/Pictures/blade-of-grass-blur.png";
      wallpaper = "${homeDir}/Pictures/pexels.png";
      fullName = "Matej Cotman";
      email = "matej.cotman@eficode.com";
      locale.all = "en_US.UTF-8";
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
        filemanager = "${cinnamon.nemo}/bin/nemo";
        #terminal = "${xfce.terminal}/bin/xfce4-terminal";
        terminal = "${profileDir}/bin/nixGL ${pkgs.wezterm}/bin/wezterm start --always-new-process";
        dropdown = "${dotFileAt "i3config.nix" 1} --class=ScratchTerm";
        browser = "${profileDir}/bin/chromium --ozone-platform-hint=auto";
        editor = "${nano}/bin/nano";
        #launcher = dotFileAt "bemenu.nix" 0;
        #launcher = "${pkgs.xfce.terminal}/bin/xfce4-terminal --title Launcher --hide-scrollbar --hide-toolbar --hide-menubar --drop-down -x ${homeDir}/bin/sway-launcher-desktop";
        launcher = ''env PATH="${profileDir}/bin:${homeDir}/bin:$PATH" ${pkgs.wofi}/bin/wofi --show run'';
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
      startup = [
        self.variables.programs.keepassxc
        "${clearprimary}/bin/clearprimary"
        "/usr/bin/google-chrome"
      ];
    };
    services = [ ];
    config = {};
    home-configuration = {
      #services.nextcloud-client.enable = true;
      home.stateVersion = "21.05";
      #systemd.user.services.nextcloud-client.environment.QT_QPA_PLATFORM = "wayland";
      services.syncthing.enable = true;
      services.syncthing.extraOptions = [ "-home=${self.variables.homeDir}/Syncthing/.config/syncthing" ];
      services.syncthing.tray.enable = false;
      programs.obs-studio = {
        enable = true;
        plugins = [ pkgs.obs-studio-plugins.looking-glass-obs pkgs.obs-studio-plugins.wlrobs ];
      };
    };
  };
in
  self
