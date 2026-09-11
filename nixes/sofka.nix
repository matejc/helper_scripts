{ pkgs ? import <nixpkgs> { } }:
let
  src = fetchTarball {
    url = "https://github.com/nklmilojevic/sofka/archive/refs/tags/v0.24.6.tar.gz";
    sha256 = "sha256:0lw976pzc6ix9nisb3ih3kjwapf2dy8kpbk9kc7nh2vr1ps1jf4g";
  };
  package = pkgs.callPackage "${src}/package.nix" { };
in
  package
