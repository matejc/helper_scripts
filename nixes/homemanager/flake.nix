{
  description = "home-manager system";
  inputs = {
    nixpkgs.url = "path:/home/matejc/workarea/nixpkgs";
    nixexprs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixos-configuration = {
      url = "path:/etc/nixos";
      flake = false;
    };
    nixmy = {
      url = "github:matejc/nixmy/master";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
    clearprimary = {
      url = "github:matejc/clearprimary/main";
      flake = false;
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sway-workspace = {
      url = "github:matejc/sway-workspace";
      flake = false;
    };
    swayest = {
      url = "github:Lyr-7D1h/swayest_workstyle/1.3.0";
      flake = false;
    };
    sway-scratchpad = {
      url = "github:matejc/sway-scratchpad";
      flake = false;
    };
    jupyenv = {
      url = "github:tweag/jupyenv/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs: {
    homeConfigurations = {
      wsl = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          (import ./configuration.nix { inherit inputs; contextFile = ./contexts/wsl.nix; })
        ];
      };
      nixcode = inputs.home-manager.lib.homeManagerConfiguration {
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
            nixpkgs.overlays = [ inputs.nixgl.overlay ];
          }
          {
            imports = [(import ./modules/jupyenv.nix { jupyenv = inputs.jupyenv; })];
            services.jupyenv.demo = {
              enable = true;
              port = 18080;
              attrs = {
                kernel.python.example.enable = true;
                kernel.postgres.example.enable = true;
              };
            };
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
