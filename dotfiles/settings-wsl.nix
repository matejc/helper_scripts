{ pkgs, lib ? pkgs.lib }:
let
  variables = rec {
    prefix = "/home/matejc/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/matejc";
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "cotman.matej@gmail.com";
    editor = "${pkgs.nano}/bin/nano";
    font = {
      family = "Source Code Pro";
      extra = "Semibold";
      size = "11";
    };
    sway = {
      enable = false;
    };
    term = null;
    browser = "chrome";
    terminal = "";
    programs.filemanager = "${pkgs.xfce.thunar}/bin/thunar";
  };

  dotFilePaths = [
    ./gitconfig.nix
    ./gitignore.nix
    ./thissession.nix
    ./oath.nix
    ./jstools.nix
    ./zsh.nix
    ./nvim.nix
    ./starship.nix
    ./bemenu.nix
    ./programs.nix
    ./look.nix
    ./nix.nix
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
