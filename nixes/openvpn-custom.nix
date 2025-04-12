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

    mkTarball = package: pkgs.runCommand "binary-tarball" {
    } ''
        mkdir -p $out/tarballs
        tar cvJf "$out/tarballs/${package.name}.tar.xz" -C "${package}" .

        mkdir -p $out/nix-support
        echo "file binary-dist $out/tarballs/${package.name}.tar.xz" >> $out/nix-support/hydra-build-products
        echo "${package.name}" >> "$out/nix-support/hydra-release-name"
    '';
in { inherit openvpn; tarball = mkTarball openvpn; }
