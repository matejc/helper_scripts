{ pkgs ? import <nixpkgs> {} }:
with pkgs;
buildGoModule rec {
  pname = "steam-exporter";
  version = "dev";

  src = fetchFromGitHub {
    owner = "michaelsergio";
    repo = "steam-exporter";
    rev = "79b2c2e6ae8de06b43d1f1945d89f25e1639b9ca";
    hash = "sha256-6HO+oLRAvU0DxKSQVdP5UlHYzIbIvSDPIPYNcD6vjKM=";
  };

  vendorHash = "sha256-cy3z8sBpkbMK/6NSjqxfX9dBPt3amuEnJlRRGsJIi8s=";
}
