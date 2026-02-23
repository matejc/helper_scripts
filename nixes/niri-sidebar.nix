{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "niri-sidebar";
  version = "20260223";
  src = fetchFromGitHub {
    owner = "Vigintillionn";
    repo = pname;
    rev = "83603353eceb51a0a1d889b17713000dcb222794";
    hash = "sha256-YDNugm3RQ65tN0jYdD0sO//AWYGJ+P+WP8APu40r2fM=";
  };
  cargoHash = "sha256-13gDpYcG0gB35zu8pzKUuSRvTc10cCjWQkIg42zejpc=";
}
