{ variables, config, pkgs, lib }:
let
  cfg = { nixpkgs.config.nixmy = {
    NIX_MY_PKGS = "/home/matejc/workarea/nixpkgs";
    NIX_USER_PROFILE_DIR = "/nix/var/nix/profiles/per-user/matejc";
    NIX_MY_GITHUB = "git://github.com/matejc/nixpkgs";
    NIX_MY_BACKUP = "git@github.com:matejc/configuration_nix_backups";
    nix = pkgs.nix;
  }; };
in
[{
  target = "${variables.homeDir}/bin/nixmy";
  source = "${pkgs.callPackage (builtins.fetchGit git://github.com/matejc/nixmy) { config = cfg; }}/bin/nixmy";
}]
