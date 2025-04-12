{ pkgs ? import <nixpkgs> { } }:
let
    pkgsArm32 = import "${pkgs.path}" {
        crossSystem = "armv6l-unknown-linux-musleabihf";
    };

    openvpn = (pkgsArm32.pkgsStatic.openvpn.overrideAttrs (old: {
        configureFlags = ["--disable-plugin-auth-pam"];
        outputs = [ "out" "archive" ];
        postInstall = ''
            tar cvJf "$out/archive/openvpn.tar.xz" "$out/bin/openvpn"
        '';
    })).override {
        useSystemd = false;
        pam = null;
    };
in {
    package = openvpn;
    archive = pkgs.runCommand "openvpn.tar.xz" {
        pname = "openvpn_archive";
    } ''
        cd "${openvpn}"
        mkdir -p "$out"
        tar cvJf "$out/openvpn.tar.xz" .
    '';
}
