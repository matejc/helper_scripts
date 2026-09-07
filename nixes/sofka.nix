{ pkgs ? import <nixpkgs> { } }:
let
  src = pkgs.fetchFromGitHub {
    owner = "nklmilojevic";
    repo = "sofka";
    rev = "refs/tags/v0.24.6";
    sha256 = "sha256-jzgZ9A15C2gPm2muO5Fvwl3F5RwwjqWjTT0a9q85iVM=";
  };
  package = pkgs.callPackage "${src}/package.nix" { };
in
  package
