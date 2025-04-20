{ pkgs ? import <nixpkgs> { } }:
let
    pkgsArmMusl = import "${pkgs.path}" {
        crossSystem = "armv6l-unknown-linux-musleabihf";
    };

    pkgsArm = import "${pkgs.path}" {
        crossSystem = "armv6l-unknown-linux-gnueabihf";
    };

    openvpn = (pkgsArmMusl.pkgsStatic.openvpn.overrideAttrs (old: {
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
    nixpkgsOld = pkgs.fetchzip {
      url = "https://github.com/NixOS/nixpkgs/archive/50dc28d7a0d3a22e624b44bbd1708ad148cef554.tar.gz";
      hash = "sha256-427XqvjnNLuQWbSBrNozlBKvBg6K4fj4oFvL+4Kcg5I=";
    };
    pkgsOld = import nixpkgsOld {
        crossSystem = {
            config = "armv6l-unknown-linux-gnueabihf";
            libc = "glibc";
            arch = "armv6";
            withTLS = true;
            float = "hard";
            platform = {
                name = "armv6l";
                kernelMajor = "2.6";
                kernelArch = "arm";
                kernelHeadersBaseConfig = "kirkwood_defconfig";
                kernelBaseConfig = "versatile_defconfig";
                kernelExtraConfig = ''
                  TUN m
                '';
                kernelAutoModules = true;
                gcc = {
                    arch = "armv6";
                    fpu = "vfp";
                    float = "hard";
                };
                kernelTarget = "zImage";
                uboot = null;
            };
        };
    };

    linux = pkgsOld.linux.crossDrv;

    mkTunTarball = package: pkgs.runCommand "binary-tarball" {
    } ''
        mkdir -p $out/tarballs
        tar cvJf "$out/tarballs/${package.name}-tun.tar.xz" -C "${package}/lib/modules/${package.version}/kernel/drivers/net" tun.ko

        mkdir -p $out/nix-support
        echo "file binary-dist $out/tarballs/${package.name}-tun.tar.xz" >> $out/nix-support/hydra-build-products
        echo "${package.name}-tun" >> "$out/nix-support/hydra-release-name"
    '';

in { openvpn_tarball = mkTarball openvpn; linux_tarball = mkTarball linux; tun_tarball = mkTunTarball linux; inherit openvpn linux; }
