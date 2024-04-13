{
  description = "home-manager system";
  inputs = {
    nixpkgs.url = "github:matejc/nixpkgs/latest";
    # nixpkgs.url = "path:/home/matejc/workarea/nixpkgs";
    nixexprs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
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
    # clearprimary = {
    #   url = "github:matejc/clearprimary/main";
    #   flake = false;
    # };
    #nixgl = {
    #  url = "github:guibou/nixGL";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
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
    # nwg-displays = {
    #   url = "github:nwg-piotr/nwg-displays/master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # devenv.url = "github:cachix/devenv";
    # niri = {
    #   url = "github:sodiboo/niri-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # jupyenv = {
    #   url = "github:tweag/jupyenv/main";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    NixOS-WSL.url = "github:nix-community/NixOS-WSL/main";
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.matejc.com"
    ];
    extra-trusted-public-keys = [
      "cache.matejc.com-1:1gX7YfpZK4zkYf5MRrz9HPsJq9XZBC6bJgDySZmzbUM="
    ];
  };

  outputs = { self, ... }@inputs: let
    system = "x86_64-linux";
    helper_scripts = ./.;
    defaultUser = "matejc";
    nixosBuild = { context, modules ? [] }: let
      nixosSystem = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs helper_scripts defaultUser; contextFile = ./nixos/contexts + "/${context}.nix"; };
        modules = modules + [
          ./nixos/minimal-configuration.nix
          inputs.home-manager.nixosModules.home-manager
          ./nixes/sway-wsshare/module.nix
          ./nixos/configuration.nix
        ];
      };
    in
      nixosSystem.config.system.build.toplevel;
  in {
    # homeConfigurations = {
    #   wsl = inputs.home-manager.lib.homeManagerConfiguration {
    #     pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    #     modules = [
    #       (import ./configuration.nix { inherit inputs; contextFile = ./contexts/wsl.nix; })
    #     ];
    #   };
    #   nixcode = inputs.home-manager.lib.homeManagerConfiguration {
    #     pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    #     modules = [
    #       (import ./configuration.nix { inherit inputs; contextFile = ./contexts/nixcode.nix; })
    #     ];
    #   };
    # };
    nixosConfigurations = {
      matej70 = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs helper_scripts defaultUser; contextFile = ./nixos/contexts/matej70.nix; };
        modules = [
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs helper_scripts; })
          inputs.home-manager.nixosModules.home-manager
          ./nixes/sway-wsshare/module.nix
          ./nixos/configuration.nix
          # {
          #   nixpkgs.overlays = [ inputs.nixgl.overlay (import ../teleport/overlay.nix) ];
          # }
          # {
          #   imports = [(import ../jupyenv.nix { jupyenv = import inputs.jupyenv; })];
          #   services.jupyenv.my = {
          #     enable = false;
          #     port = 9980;
          #     token = "'token'";
          #     attrs = {
          #       kernel.python.minimal.enable = true;
          #       kernel.nix.minimal.enable = true;
          #     };
          #   };
          # }
        ];
      };
      matej80 = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs helper_scripts defaultUser; contextFile = ./nixos/contexts/matej80.nix; };
        modules = [
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs helper_scripts; })
          inputs.home-manager.nixosModules.home-manager
          ./nixes/sway-wsshare/module.nix
          ./nixos/configuration.nix
        ];
      };
      nixcode = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs helper_scripts defaultUser; contextFile = ./nixos/contexts/nixcode-nixos.nix; };
        modules = [
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; })
          inputs.home-manager.nixosModules.home-manager
          ./nixes/sway-wsshare/module.nix
          import ./nixos/configuration.nix
        ];
      };
    };
    images = {
      wsl =
        let
          build = inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs helper_scripts defaultUser; contextFile = ./nixos/contexts/wsl.nix; };
            modules = [
              inputs.NixOS-WSL.nixosModules.wsl
              inputs.home-manager.nixosModules.home-manager
              ./nixos/wsl/configuration.nix
              ./nixos/configuration.nix
            ];
          };
        in {
          system = build.config.system.build.toplevel;
          tarball = (import ./nixos/wsl/build-tarball.nix { inherit (build) config pkgs; }).system.build.tarball;
        };
    };
  };
}
