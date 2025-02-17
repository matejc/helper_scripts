{ pkgs, lib, config, inputs, dotFileAt, helper_scripts }:
let
  homeConfig = config.home-manager.users.matejc;

  neovim-qt-win = pkgs.stdenv.mkDerivation {
    name = "neovim-qt-win";
    src = pkgs.fetchurl {
      url = "https://github.com/equalsraf/neovim-qt/releases/download/v0.2.19/neovim-qt.zip";
      hash = "sha256-1zxfaz001O9ime2mIG++j/QCt4QPaa8RgtpalKIuDAA=";
    };
    nativeBuildInputs = with pkgs; [ unzip makeWrapper ];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/share/neovim-qt
      cp -r ./bin $out/share/neovim-qt/
      cp -r ./share $out/share/neovim-qt/
      mkdir -p $out/bin
      chmod +x $out/share/neovim-qt/bin/nvim-qt.exe
      makeWrapper $out/share/neovim-qt/bin/nvim-qt.exe $out/bin/nvim-qt
    '';
  };
  neovide-win = pkgs.stdenv.mkDerivation {
    name = "neovide-win";
    src = pkgs.fetchurl {
      url = "https://github.com/neovide/neovide/releases/download/0.14.0/neovide.exe.zip";
      hash = "sha256-md2eVTt0TZfkKlzzFpWUXMVLOSI4maiHlkvKVAdj0d8=";
    };
    nativeBuildInputs = with pkgs; [ unzip makeWrapper ];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/share/neovide
      cp -r . $out/share/neovide/
      mkdir -p $out/bin
      chmod +x $out/share/neovide/neovide.exe
      makeWrapper $out/share/neovide/neovide.exe $out/bin/neovide
    '';
  };

  self = {
    dotFilePaths = [
      "${helper_scripts}/dotfiles/nvim.nix"
      "${helper_scripts}/dotfiles/gitconfig.nix"
      "${helper_scripts}/dotfiles/gitignore.nix"
      "${helper_scripts}/dotfiles/swaylockscreen.nix"
      "${helper_scripts}/dotfiles/tmux.nix"
      "${helper_scripts}/dotfiles/dd.nix"
      "${helper_scripts}/dotfiles/sync.nix"
      "${helper_scripts}/dotfiles/mypassgen.nix"
      "${helper_scripts}/dotfiles/wofi.nix"
      "${helper_scripts}/dotfiles/nwgbar.nix"
      "${helper_scripts}/dotfiles/kitty.nix"
      "${helper_scripts}/dotfiles/countdown.nix"
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
        family = "SauceCodePro NFM";
        style = "Bold";
        size = 10.0;
      };
      term = null;
      programs = {
        filemanager = "${pkgs.pcmanfm}/bin/pcmanfm";
        terminal = "${pkgs.kitty}/bin/kitty -o=hide_window_decorations=no";
        browser = "${profileDir}/bin/firefox";
        editor = "${pkgs.helix}/bin/hx";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
      };
      shell = "${profileDir}/bin/zsh";
      shellRc = "${homeDir}/.zshrc";
      sway.enable = false;
      vims = {
        # q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --nvim ${homeDir}/bin/nvim";
        q = "env NVIM_FRONTEND_PATH=${neovim-qt-win}/bin/nvim-qt ${homeDir}/bin/guinvim";
        n = "env NVIM_FRONTEND_PATH=${neovide-win}/bin/neovide NVIM_FRONTEND_ARGS='--remote-tcp' ${homeDir}/bin/guinvim";
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
      nixmy = {
        backup = "git@github.com:matejc/configurations.git";
        remote = "https://github.com/matejc/nixpkgs";
        nixpkgs = "/home/matejc/workarea/nixpkgs";
      };
      graphical = {
        name = "sway";
        logout = "${self.variables.graphical.exec} exit";
        target = "sway-session.target";
        waybar.prefix = "sway";
        exec = "${self.variables.profileDir}/bin/swaymsg";
      };
    };
    services = [
      { name = "gnome-keyring"; delay = 1; group = "always"; }
    ];
    config = {};
    nixos-configuration = { };
    home-configuration = {
      home.stateVersion = "25.05";
      # home.packages = with pkgs; [ firefox ];
      #home.sessionVariables.WSL_INTEROP = "$(realpath /run/WSL/*_interop | head -n 1)";
      #home.sessionVariables.QT_QPA_PLATFORM = pkgs.lib.mkForce "xcb";
      #wayland.windowManager.sway.config.startup = [
      #  { command = "${self.variables.programs.browser}"; }
      #];
    };
  };
in
  self
