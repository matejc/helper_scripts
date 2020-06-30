{pkgs?import <nixpkgs> {}}:
let
  variables = { font.family = "Fira Code"; font.size = "13"; homeDir = "/home/matejc"; };
  nvim = import ../dotfiles/nvim.nix { inherit pkgs variables; lib = pkgs.lib; config = pkgs.config; };
in
  pkgs.writeScript "relink.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.lib.concatMapStringsSep "\n" (i: "mkdir -p \"$(dirname ${i.target})\" && ln -svf \"${i.source}\" \"${i.target}\"") nvim}
  ''
