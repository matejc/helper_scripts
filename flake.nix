{
  description = "home-manager system";
  inputs = {
    nixpkgs.url = "github:matejc/nixpkgs/latest";
    # nixpkgs.url = "path:/home/matejc/workarea/nixpkgs";
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
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # jupyenv = {
    #   url = "github:tweag/jupyenv/main";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    NixOS-WSL.url = "github:nix-community/NixOS-WSL/main";
    nixd = {
      url = "github:nix-community/nixd/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nixosBuild = { context, modules ? [] }:
      (inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs helper_scripts defaultUser; contextFile = ./nixos/contexts + "/${context}.nix"; };
        modules = [
          inputs.home-manager.nixosModules.home-manager
          ./nixos/configuration.nix
        ] ++ modules;
      });
    pkgs = inputs.nixpkgs.legacyPackages.${system};
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
    hydraJobs = {
      matej70 = (nixosBuild {
        context = "matej70-niri";
        modules = [
          ./nixos/minimal-configuration.nix
        ];
      }).config.system.build.toplevel;
      matej80 = (nixosBuild {
        context = "matej80";
        modules = [
          ./nixos/minimal-configuration.nix
        ];
      }).config.system.build.toplevel;
      nixcode = (nixosBuild {
        context = "nixcode-niri";
        modules = [
          inputs.lanzaboote.nixosModules.lanzaboote
          ./nixos/minimal-configuration.nix
        ];
      }).config.system.build.toplevel;
      wsl = (nixosBuild {
        context = "wsl";
        modules = [
          inputs.NixOS-WSL.nixosModules.wsl
          ./nixos/wsl/configuration.nix
        ];
      }).config.system.build.tarballBuilder;
      packages = let
        aider = pkgs.callPackage ./nixes/aider { };
        sway-scratchpad = pkgs.callPackage ./nixes/sway-scratchpad.nix { };
        sway-workspace = pkgs.callPackage ./nixes/sway-workspace.nix { };
      in pkgs.lib.listToAttrs (map (p: pkgs.lib.nameValuePair p.pname p) [
        pkgs.clamav
        aider
        sway-workspace
        sway-scratchpad
      ]);
    };
    nixosConfigurations = {
      matej70 = nixosBuild {
        context = "matej70-niri";
        modules = [
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs helper_scripts; })
        ];
      };
      matej80 = nixosBuild {
        context = "matej80";
        modules = [
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs helper_scripts; })
        ];
      };
      nixcode = nixosBuild {
        context = "nixcode-niri";
        modules = [
          inputs.lanzaboote.nixosModules.lanzaboote
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; })
        ];
      };
      wsl = nixosBuild {
        context = "wsl";
        modules = [
          inputs.NixOS-WSL.nixosModules.wsl
          ./nixos/wsl/configuration.nix
        ];
      };
      # matej70 = inputs.nixpkgs.lib.nixosSystem {
      #   inherit system;
      #   specialArgs = { inherit inputs helper_scripts defaultUser; contextFile = ./nixos/contexts/matej70.nix; };
      #   modules = [
      #     (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs helper_scripts; })
      #     inputs.home-manager.nixosModules.home-manager
      #     ./nixos/configuration.nix
      #     # {
      #     #   nixpkgs.overlays = [ inputs.nixgl.overlay (import ../teleport/overlay.nix) ];
      #     # }
      #     # {
      #     #   imports = [(import ../jupyenv.nix { jupyenv = import inputs.jupyenv; })];
      #     #   services.jupyenv.my = {
      #     #     enable = false;
      #     #     port = 9980;
      #     #     token = "'token'";
      #     #     attrs = {
      #     #       kernel.python.minimal.enable = true;
      #     #       kernel.nix.minimal.enable = true;
      #     #     };
      #     #   };
      #     # }
      #   ];
      # };
    };
    images = {
      wsl = {
        system = self.nixosConfigurations.wsl.config.system.build.toplevel;
        builder = self.nixosConfigurations.wsl.config.system.build.tarballBuilder;
      };
    };
  };
}
