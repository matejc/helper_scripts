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
in {
    inherit openvpn;
    openvpn_tar_xz = pkgs.runCommand "openvpn.tar.xz" {
    } ''
        cd "${openvpn}"
        tar cvJf $out .
    '';
}
