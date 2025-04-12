{ pkgs ? import <nixpkgs> { } }:
let
    pkgsArm32 = import "${pkgs.path}" {
        crossSystem = "armv6l-unknown-linux-musleabihf";
    };

    openvpn = (pkgsArm32.pkgsStatic.openvpn.overrideAttrs (old: {
        configureFlags = ["--disable-plugin-auth-pam"];
        outputs = [ "out" "archive" ];
        postInstall = ''
            mkdir -p "$archive"
            tar cvJf "$archive/openvpn.tar.xz" "$out/sbin/openvpn"
        '';
    })).override {
        useSystemd = false;
        pam = null;
    };
in openvpn
