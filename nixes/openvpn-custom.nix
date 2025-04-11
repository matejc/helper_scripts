{ pkgs ? import <nixpkgs> {
  crossSystem = "armv6l-unknown-linux-musleabihf";
} }:
(pkgs.pkgsStatic.openvpn.overrideAttrs (old: {
  configureFlags = ["--disable-plugin-auth-pam"];
})).override {
  useSystemd = false;
  pam = null;
}
