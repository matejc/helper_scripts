{ pkgs ? import <nixpkgs> {} }:
let
  version = "2.2.13.38";
in
pkgs.appimageTools.wrapType2 {
  pname = "proxsign";
  inherit version;
  src = pkgs.fetchurl {
    url = "https://public.setcce.si/proxsign/update/linux/SETCCE_proXSign-${version}-x86_64.AppImage";
    hash = "sha256-Ixe0XjErci2ID4YUx/zr4pf1XTi3M2n9E/IIh2DPYB8=";
  };
  extraPkgs = pkgs: with pkgs; [];
}
