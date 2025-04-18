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

    # For linux kernel 3.18.20
    # nixpkgsOld = pkgs.fetchzip {
    #   url = "https://github.com/NixOS/nixpkgs/archive/50dc28d7a0d3a22e624b44bbd1708ad148cef554.tar.gz";
    #   hash = "sha256-427XqvjnNLuQWbSBrNozlBKvBg6K4fj4oFvL+4Kcg5I=";
    # };
    nixpkgsOld = ../../nixpkgs_3_18;
    pkgsOld = import nixpkgsOld {
      crossSystem = {
        config = "armv6l-unknown-linux-musleabihf";
        libc = "musl";
      };
    };

    linux = pkgsOld.linux_3_18;
in { openvpn_tarball = mkTarball openvpn; linux_tarball = mkTarball linux; inherit openvpn linux; }
