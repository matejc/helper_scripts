{
  description = "home-manager system";
  inputs = {
    nixpkgs.url = "path:/home/matejc/workarea/nixpkgs";
    nixos-configuration = {
      url = "path:/etc/nixos";
      flake = false;
    };
    nixmy = {
      url = "github:matejc/nixmy/master";
      flake = false;
    };
    helper_scripts = {
      url = "path:/home/matejc/workarea/helper_scripts";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    nur.url = "github:nix-community/NUR";
    clearprimary = {
      url = "github:matejc/clearprimary/main";
      flake = false;
    };
  };

  outputs = { self, ... }@inputs: {
    homeConfigurations = {
      wsl = inputs.home-manager.lib.homeManagerConfiguration rec {
        configuration = { ... }: {
          imports = [
            (import ./configuration.nix { inherit inputs; contextFile = ./contexts/wsl.nix; })
            ./modules/xrdp.nix
          ];
        };
        system = "x86_64-linux";
        homeDirectory = "/home/${username}";
        username = "matejc";
      };
      nixcode = inputs.home-manager.lib.homeManagerConfiguration rec {
        pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          (import ./configuration.nix { inherit inputs; contextFile = ./contexts/nixcode.nix; })
        ];
      };
    };
    nixosConfigurations = {
      matej70 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; })
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.matejc = (import ./configuration.nix { inherit inputs; contextFile = ./contexts/matej70.nix; });
          }
        ];
      };
      nixcode = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; })
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.matejc = (import ./configuration.nix { inherit inputs; contextFile = ./contexts/nixcode-nixos.nix; });
          }
        ];
      };
    };
    images = {
      wsl =
        let
          build = import "${inputs.nixpkgs}/nixos" {
            configuration = {
              imports = [
                (import ./wsl/configuration.nix { inherit inputs; defaultUser = "matejc"; })
                (import ./wsl/build-tarball.nix { inherit inputs; })
                ./modules/wayvnc.nix
              ];
              services.wayvnc.enable = true;
              services.wayvnc.user = "matejc";
            };
            system = "x86_64-linux";
          };
        in { system = build.system; tarball = build.config.system.build.tarball; };
    };
  };
}
