{ pkgs, lib ? pkgs.lib }:
let
  variables = rec {
    prefix = "${variable.homeDir}/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/${variables.user}";
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "matej.cotman@eficode.com";
    editor = "${pkgs.nano}/bin/nano";
    font = {
      family = "Consolas";
      extra = "Semibold";
      size = "11";
    };
    term = null;
    browser = programs.chromium;
    programs = {
      chromium = "Chrome.exe";
      code = "${pkgs.vscodium}/bin/codium";
    };
  };

  dotFilePaths = [
    ./gitconfig.nix
    ./gitignore.nix
    ./jstools.nix
    ./zsh.nix
    ./programs.nix
    ./nvim.nix
    ./bash.nix
    ./starship.nix
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
