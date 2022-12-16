{ pkgs, lib ? pkgs.lib }:
let
  variables = rec {
    prefix = "${variables.homeDir}/workarea/helper_scripts";
    nixpkgs = "${variables.homeDir}/workarea/nixpkgs";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    temperatureFiles = [];
    user = "matejc";
    homeDir = "/home/${variables.user}";
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "matej.cotman@eficode.com";
    font = {
      family = "SauceCodePro Nerd Font Mono";
      style = "Regular";
      size = 11;
    };
    term = null;
    terminal = null;
    sway.enable = false;
    programs = {
      browser = "Chrome.exe";
      editor = "${pkgs.nano}/bin/nano";
      terminal = "${nixGL.nixGLDefault}/bin/nixGL ${pkgs.kitty}/bin/kitty -o=hide_window_decorations=no";
      shell = "${pkgs.zsh}/bin/zsh";
      zsh = "${pkgs.zsh}/bin/zsh";
      tug = "${pkgs.turbogit}/bin/tug";
      node = "${pkgs.nodejs}/bin/node";
      python = "${pkgs.python3Packages.python}/bin/python";
      nixGL = "${nixGL.nixGLDefault}/bin/nixGL";
      openocd = "${pkgs.openocd}/bin/openocd";
    };
    locale.all = "en_US.utf8";
    #alacritty.path = "/mnt/c/Program\\ Files/Alacritty/alacritty.exe";
    #alacritty.args = ''-o "shell.program='wsl.exe'" -o "shell.args=['-d Ubuntu-20.04 /home/matejc/bin/shell']"'';
    #vims.n = "env NVIM_FRONTEND_PATH=/mnt/c/Users/cotman_matej/neovide/neovide.exe NVIM_FRONTEND_ARGS='--remote-tcp' ${homeDir}/bin/guinvim";
    #vims.n = "${nixGL.nixGLDefault}/bin/nixGL ${pkgs.neovide}/bin/neovide --neovim-bin ${homeDir}/bin/nvim";
    vims.q = "env NVIM_FRONTEND_PATH=/mnt/c/Users/cotman_matej/neovim-qt/bin/nvim-qt.exe ${homeDir}/bin/guinvim";
    #vims.q = "${nixGL.nixGLDefault}/bin/nixGL ${pkgs.neovim-qt}/bin/nvim-qt --nvim ${homeDir}/bin/nvim";
    #vims.g = "${nixGL.nixGLDefault}/bin/nixGL ${pkgs.gnvim}/bin/gnvim --nvim ${homeDir}/bin/nvim --disable-ext-cmdline --disable-ext-popupmenu --disable-ext-tabline";
  };

  nixGL = (import (builtins.fetchGit {
    url = https://github.com/guibou/nixGL;
    ref = "refs/heads/main";
  }) { enable32bits = false; }).auto;

  dotFilePaths = [
    ./gitconfig.nix
    ./gitignore.nix
    ./jstools.nix
    ./zsh.nix
    ./programs.nix
    ./starship.nix
    ./nvim.nix
    ./mypassgen.nix
    ./nixmy.nix
    ./comma.nix
    ./tmux.nix
  ];

  activationScript = ''
    mkdir -p ${variables.homeDir}/.nixpkgs
    ln -fs ${variables.nixpkgsConfig} ${variables.homeDir}/.nixpkgs/config.nix

    mkdir -p ${variables.homeDir}/bin
    ln -fs ${variables.binDir}/* ${variables.homeDir}/bin/
  '';
in {
  inherit variables dotFilePaths activationScript;
}
