{ pkgs, config, defaultUser, ... }:
let
  variables = config.variables;

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
in
{
  imports = [
    ../../home/variables.nix
    ../../home/misc.nix
    ../../home/dotfiles.nix
    ../../home/nixmy.nix
    ../../home/nix-index-database.nix
  ];
  config = {
    dotfiles.paths = [
      ../../dotfiles/gitconfig.nix
      ../../dotfiles/gitignore.nix
      ../../dotfiles/dd.nix
      ../../dotfiles/sync.nix
      ../../dotfiles/mypassgen.nix
      ../../dotfiles/wofi.nix
      ../../dotfiles/kitty.nix
      ../../dotfiles/countdown.nix
    ];
    variables = {
      homeDir = "/home/${variables.user}";
      user = defaultUser;
      profileDir = "${variables.homeDir}/.nix-profile";
      prefix = "${variables.homeDir}/workarea/helper_scripts";
      nixpkgs = "${variables.homeDir}/workarea/nixpkgs";
      binDir = "${variables.homeDir}/bin";
      temperatures = [ ];
      lockscreen = "${variables.homeDir}/bin/lockscreen";
      fullName = "Matej Cotman";
      email = "matej@matejc.com";
      signingkey = "";
      locale.all = "en_US.UTF-8";
      networkInterface = "eth0";
      wirelessInterfaces = [];
      ethernetInterfaces = [ variables.networkInterface ];
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
        browser = "${variables.profileDir}/bin/firefox";
        editor = "${pkgs.helix}/bin/hx";
        launcher = "${pkgs.wofi}/bin/wofi --show run";
      };
      shell = "${variables.profileDir}/bin/zsh";
      shellRc = "${variables.homeDir}/.zshrc";
      vims = {
        # q = "env QT_PLUGIN_PATH='${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}' ${pkgs.neovim-qt}/bin/nvim-qt --nvim ${homeDir}/bin/nvim";
        #q = "env NVIM_FRONTEND_PATH=${neovim-qt-win}/bin/nvim-qt ${variables.profileDir}/bin/guinvim";
        #n = "env NVIM_FRONTEND_PATH=${neovide-win}/bin/neovide NVIM_FRONTEND_ARGS='--remote-tcp' ${variables.profileDir}/bin/guinvim";
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
        nixpkgs = "${variables.homeDir}/workarea/nixpkgs";
      };
      graphical = {
        name = "wslg";
        target = "graphical-session.target";
      };
      services = [
        { name = "gnome-keyring"; delay = 1; group = "always"; }
      ];
    };
    home.stateVersion = "25.05";
  };
}
