{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/rebuild-nix-index";
  source = pkgs.writeScript "rebuild-nix-index.sh" ''
    #!${pkgs.stdenv.shell}
    set -e
    rm -rf "${variables.homeDir}/.cache/nix-index"
    env NIX_PATH="nixpkgs=${variables.nixpkgs}" ${pkgs.nix-index}/bin/nix-index --db "${variables.homeDir}/.cache/nix-index"
  '';
} {
  target = "${variables.homeDir}/bin/,";
  source = pkgs.writeScript "comma.sh" ''
    #!${pkgs.stdenv.shell}
    exec env NIX_PATH="nixpkgs=${variables.nixpkgs}" ${pkgs.comma}/bin/, $@
  '';
}]
