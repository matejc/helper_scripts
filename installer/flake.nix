{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, disko, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages."${system}";
  in {
    packages."${system}" = {
      disko = disko.packages."${system}".disko;

      pxe-system = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ config, pkgs, lib, modulesPath, ... }: {
            imports = [
              (modulesPath + "/installer/netboot/netboot-minimal.nix")
            ];
            config = {};
          })
          ./configuration.nix
        ];
        specialArgs = { inherit disko; };
      };
      pxe-run = let
        build = self.packages."${system}".pxe-system.config.system.build;
      in pkgs.writers.writeBash "run-pixiecore" ''
        set -xe

        function reverse_iptables() {
          iptables -w -D nixos-fw -p udp -m multiport --dports 67,69,4011 -j ACCEPT
          iptables -w -D nixos-fw -p tcp -m tcp --dport 64172 -j ACCEPT
        }
        trap reverse_iptables EXIT

        iptables -w -I nixos-fw -p udp -m multiport --dports 67,69,4011 -j ACCEPT
        iptables -w -I nixos-fw -p tcp -m tcp --dport 64172 -j ACCEPT

        ${pkgs.pixiecore}/bin/pixiecore \
          boot ${build.kernel}/bzImage ${build.netbootRamdisk}/initrd \
          --cmdline "init=${build.toplevel}/init loglevel=4" \
          --debug --dhcp-no-bind \
          --port 64172 --status-port 64172 "$@"
      '';

      image = nixos-generators.nixosGenerate {
        inherit system;
        modules = [
          ./configuration.nix
        ];
        format = "install-iso";

        # optional arguments:
        # explicit nixpkgs and lib:
        inherit pkgs;
        # lib = nixpkgs.legacyPackages.x86_64-linux.lib;
        # additional arguments to pass to modules:
        specialArgs = { inherit disko; };

        # you can also define your own custom formats
        # customFormats = { "myFormat" = <myFormatModule>; ... };
        # format = "myFormat";
      };

      test = nixos-generators.nixosGenerate {
        inherit system;
        modules = [
          ./configuration.nix
        ];
        format = "vm";
        specialArgs = { inherit disko; };
      };
    };
  };
}
