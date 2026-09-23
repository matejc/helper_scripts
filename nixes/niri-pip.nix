{ pkgs ? import <nixpkgs> {} }:
let
  version = "0.3.2";
in
pkgs.rustPlatform.buildRustPackage (final: {
  pname = "niri-pip";
  inherit version;
  src = pkgs.fetchFromGitHub {
    owner = "t1ktakdev";
    repo = final.pname;
    tag = "v${version}";
    hash = "sha256-ArpJiP/wLEaeXu5KRihonRQRQEl+maJH8Vbh40bBXqM=";
  };
  cargoHash = "sha256-wDaI8Wh+6rQqJrePn5LeV9MqwwQI4Ud38gCoR9daado=";
})
