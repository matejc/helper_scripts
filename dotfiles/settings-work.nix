{ pkgs, lib ? pkgs.lib }:
let
  variables = rec {
    prefix = "${variables.homeDir}/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/${variables.user}";
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "matej.cotman@eficode.com";
    font = {
      family = "FiraMono NF";
      style = "Regular";
      size = "11";
    };
    term = null;
    terminal = null;
    programs = {
      browser = "Chrome.exe";
      editor = "${pkgs.nano}/bin/nano";
      terminal = "${pkgs.xfce.terminal}/bin/xfce4-terminal";
    };
    locale.all = "en_US.utf8";
  };

  dotFilePaths = [
    ./gitconfig.nix
    ./gitignore.nix
    ./jstools.nix
    ./zsh.nix
    ./programs.nix
    ./starship.nix
    ./nvim.nix
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
