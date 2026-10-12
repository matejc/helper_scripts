{ pkgs ? import <nixpkgs> { } }:
let
  src = fetchTarball {
    url = "https://github.com/nklmilojevic/sofka/archive/refs/tags/v0.31.8.tar.gz";
    sha256 = "sha256:168y84jbmxgc8v1jk8mdgbhr9nmd336vk577hwk3xlrvpgl1r0i8";
  };
  package = pkgs.callPackage "${src}/package.nix" { };
in
  package
