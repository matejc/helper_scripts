{ pkgs ? import <nixpkgs> { } }:
let
  pkgsArm32 = import <nixpkgs> {
      crossSystem = "armv6l-unknown-linux-musleabihf";
  };

  openvpn = (pkgsArm32.pkgsStatic.openvpn.overrideAttrs (old: {
      configureFlags = ["--disable-plugin-auth-pam"];
  })).override {
      useSystemd = false;
      pam = null;
  };
in
  openvpn
