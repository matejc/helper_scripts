{ pkgs ? import <nixpkgs> { } }:
let
  src = fetchTarball {
    url = "https://github.com/matejc/isolated_agent/archive/refs/tags/0.1.0.tar.gz";
    sha256 = "sha256:1j3am0yxi1p56ga73g6s14n7rj1ank9jvic8mav06davzs4wlc6m";
  };
  package = pkgs.callPackage "${src}/agents/default.nix" { };
in
  package
