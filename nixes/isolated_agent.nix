{ pkgs ? import <nixpkgs> { } }:
let
  src = fetchTarball {
    url = "https://github.com/matejc/isolated_agent/archive/refs/tags/v0.2.0.tar.gz";
    sha256 = "sha256:00wh9y7lgcdw79x99z49w08bc7qff99rij8jwb7cnnifk69g6grb";
  };
  package = pkgs.callPackage "${src}/agents/default.nix" { };
in
  package
