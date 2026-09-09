{ pkgs ? import <nixpkgs> {} }:
let
  version = "3.28.8";
  src = pkgs.fetchurl {
    url = "https://github.com/dhowe/AdNauseam/releases/download/v${version}/adnauseam-${version}.chromium.crx";
    name = "adnauseam-${version}.chromium.crx";
    hash = "sha256-ckO9QMiAhGMMBdCLFQwCjzcciqYvh/1qJ5RLMk8Qi74=";
  };

  extension = {
    id = "edbfkfjeankmfdlkemgjmcfmnjlndbfd";
    inherit version;
    crxPath = src;
  };
in
  extension
