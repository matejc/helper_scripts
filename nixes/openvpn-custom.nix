{ pkgs ? import <nixpkgs> { } }:
let
    pkgsArm32 = import "${pkgs.path}" {
        crossSystem = "armv6l-unknown-linux-musleabihf";
    };

    openvpn = (pkgsArm32.pkgsStatic.openvpn.overrideAttrs (old: {
        configureFlags = ["--disable-plugin-auth-pam"];
    })).override {
        useSystemd = false;
        pam = null;
    };
in [
    openvpn
    (pkgs.runCommand "openvpn.tar.xz" {
      pname = "openvpn_tar_xz";
    } ''
        cd "${openvpn}"
        mkdir -p $out
        tar cvJf $out/openvpn.tar.xz .
    '')
]
