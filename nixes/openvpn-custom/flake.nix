{
    description = "OpenVPN and TUN Cross-compile";
    inputs = {
        nixpkgs.url = "github:matejc/nixpkgs/latest";
        nixpkgsOld = {
            url = "github:nixos/nixpkgs/50dc28d7a0d3a22e624b44bbd1708ad148cef554";
            flake = false;
        };
    };

    outputs = { self, ... }@inputs: let
        pkgs = import "${inputs.nixpkgs}" {
            system = "x86_64-linux";
        };

        mkTarball = package: pkgs.runCommand "binary-tarball" {
        } ''
            mkdir -p $out/tarballs
            tar cvJf "$out/tarballs/${package.name}.tar.xz" -C "${package}" .

            mkdir -p $out/nix-support
            echo "file binary-dist $out/tarballs/${package.name}.tar.xz" >> $out/nix-support/hydra-build-products
            echo "${package.name}" >> "$out/nix-support/hydra-release-name"
        '';

        mkTunTarball = package: pkgs.runCommand "binary-tarball" {
        } ''
            mkdir -p $out/tarballs
            tar cvJf "$out/tarballs/${package.name}-tun.tar.xz" -C "${package}/lib/modules/${package.version}/kernel/drivers/net" tun.ko

            mkdir -p $out/nix-support
            echo "file binary-dist $out/tarballs/${package.name}-tun.tar.xz" >> $out/nix-support/hydra-build-products
            echo "${package.name}-tun" >> "$out/nix-support/hydra-release-name"
        '';

        # OpenVPN
        pkgsArm = import "${inputs.nixpkgs}" {
            system = "x86_64-linux";
            crossSystem = "armv7l-unknown-linux-musleabihf";
        };
        openvpn = (pkgsArm.pkgsStatic.openvpn.overrideAttrs (old: {
            configureFlags = ["--disable-plugin-auth-pam" "--disable-plugin-down-root"];
        })).override {
            useSystemd = false;
            pam = null;
        };

        pkgsOld = import "${inputs.nixpkgsOld}" {
            system = "x86_64-linux";
            crossSystem = {
                config = "armv7l-unknown-linux-gnueabihf";
                libc = "glibc";
                arch = "arm";
                withTLS = true;
                float = "hard";
                openssl.system = "linux-generic32";
                platform = {
                    name = "arm";
                    kernelMajor = "2.6";
                    kernelArch = "arm";
                    kernelHeadersBaseConfig = "multi_v7_defconfig";
                    kernelBaseConfig = "multi_v7_defconfig";
                    kernelExtraConfig = ''
                      TUN m
                      PREEMPT y
                      SMP n
                      MODVERSIONS n

                      OUTER_CACHE y
                      USER_NS y
                      FUNCTION_TRACER y
                      NET y
                      NET_CORE y
                    '';
                    kernelAutoModules = false;
                    gcc = {
                        arch = "armv7-a";
                        fpu = "neon";
                        float = "hard";
                    };
                    kernelTarget = "zImage";
                    uboot = null;
                };
            };
        };

        # linux = pkgsOld.linux_3_18.crossDrv;

        linux = (pkgsOld.linuxManualConfig {
            version = "3.18.20";
            src = pkgsOld.linux_3_18.src;
            allowImportFromDerivation = true;
            configfile = pkgs.writeText "config" ''
                ${builtins.readFile ./mdm9607-config}

                CONFIG_TUN=m

                CONFIG_MODVERSIONS=n
                CONFIG_OUTER_CACHE=y
                CONFIG_USER_NS=y
                CONFIG_FUNCTION_TRACER=y
            '';
        }).crossDrv;
    in {
        hydraJobs = {
            inherit linux;
            openvpn_tarball = mkTarball openvpn;
            tun_tarball = mkTunTarball linux;
        };
    };
}
