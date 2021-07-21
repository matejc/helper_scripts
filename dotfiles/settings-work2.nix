{ pkgs, lib ? pkgs.lib }:
let

  nixGL = import (builtins.fetchGit git://github.com/guibou/nixGL) {};

  variables = rec {
    prefix = "${variables.homeDir}/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/${variables.user}";
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "matej.cotman@eficode.com";
    font = {
      family = "SauceCodePro Nerd Font Mono";
      style = "Regular";
      size = 10;
    };
    term = null;
    terminal = null;
    sway.enable = false;
    programs = {
      browser = "google-chrome";
      editor = "${pkgs.nano}/bin/nano";
      terminal = "${nixGL.nixGLDefault}/bin/nixGL ${pkgs.kitty}/bin/kitty";
      kitty = "${nixGL.nixGLDefault}/bin/nixGL ${pkgs.kitty}/bin/kitty";
      shell = "${pkgs.zsh}/bin/zsh";
      zsh = "${pkgs.zsh}/bin/zsh";
      keepassxc = "${nixGL.nixGLDefault}/bin/nixGL ${pkgs.keepassx-community}/bin/keepassxc";
      nixGL = "${nixGL.nixGLDefault}/bin/nixGL";
    };
    locale.all = "en_US.utf8";
    vims.n = "${nixGL.nixGLDefault}/bin/nixGL ${pkgs.neovide}/bin/neovide --frameless --multiGrid";
    vims.q = "${nixGL.nixGLDefault}/bin/nixGL ${pkgs.neovim-qt}/bin/nvim-qt --nvim ${homeDir}/bin/nvim";
    startup = [
      "${homeDir}/bin/browser"
      "${homeDir}/bin/keepassxc"
    ];
  };

  dotFilePaths = [
    ./gitconfig.nix
    ./gitignore.nix
    ./jstools.nix
    ./zsh.nix
    ./programs.nix
    ./starship.nix
    ./nvim.nix
    ./oath.nix
    ./mypassgen.nix
    ./keepassxc-oath.nix
    ./startup.nix
    ./kitty.nix
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
