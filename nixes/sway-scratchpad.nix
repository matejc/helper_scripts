{ pkgs ? import <nixpkgs> { } }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "sway-scratchpad";
  version = "0.2.1";
  src = pkgs.fetchFromGitHub {
    owner = "matejc";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-Ic0vzxby2vJTqdmfDDAYs0TNyntMJuEknbXK3wRjnR4=";
  };
  cargoHash = "sha256-3wyZNv0VJT8hPOWQr2jL8A9xVsfLor/6Lhv3lN5JuXY=";
}

