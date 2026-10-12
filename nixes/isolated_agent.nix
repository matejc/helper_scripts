{ pkgs ? import <nixpkgs> { } }:
let
  src = fetchTarball {
    url = "https://github.com/matejc/isolated_agent/archive/refs/tags/v0.3.0.tar.gz";
    sha256 = "sha256:017r8s9n8pk10mb09cgbyqpcnqs8qmzb6lbrhg4lvib7z6yk1qiz";
  };
  package = pkgs.callPackage "${src}/agents/default.nix" { };
in
  package
