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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # clearprimary = {
    #   url = "github:matejc/clearprimary/main";
    #   flake = false;
    # };
    #nixgl = {
    #  url = "github:guibou/nixGL";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    # sway-workspace = {
    #   url = "github:matejc/sway-workspace";
    #   flake = false;
    # };
    # sway-scratchpad = {
    #   url = "github:matejc/sway-scratchpad";
    #   flake = false;
    # };
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
    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL/main";
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
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      # url = "github:matejc/noctalia-shell";
      # url = "path:/home/matejc/workarea/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickemu = {
      url = "github:quickemu-project/quickemu";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.matejc.com"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.matejc.com-1:1gX7YfpZK4zkYf5MRrz9HPsJq9XZBC6bJgDySZmzbUM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  outputs =
    { self, ... }@inputs:
    let
      system = "x86_64-linux";
      helper_scripts = ./.;
      defaultUser = "matejc";
      nixosBuild =
        {
          context,
          modules ? [ ],
        }:
        (inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs context defaultUser;
          };
          modules = modules ++ [
            (./contexts + "/${context}/system.nix")
          ];
        });
      homeBuild =
        {
          context,
        }:
        (inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          modules = [
            (./contexts + "/${context}/home.nix")
          ];
          extraSpecialArgs = {
            inherit inputs context defaultUser;
          };
        });
    in
    {
      hydraJobs = {
        matej70 =
          { ... }:
          {
            system =
              (nixosBuild {
                context = "matej70";
                modules = [
                  ./nixos/minimal-configuration.nix
                ];
              }).config.system.build.toplevel;
            home =
              (homeBuild {
                context = "matej70";
              }).activationPackage;
          };
        matej80 =
          { ... }:
          {
            system =
              (nixosBuild {
                context = "matej80";
                modules = [
                  ./nixos/minimal-configuration.nix
                ];
              }).config.system.build.toplevel;
            home =
              (homeBuild {
                context = "matej80";
              }).activationPackage;
          };
        nixko =
          { ... }:
          {
            system =
              (nixosBuild {
                context = "nixko";
                modules = [
                  ./nixos/minimal-configuration.nix
                ];
              }).config.system.build.toplevel;
            home =
              (homeBuild {
                context = "nixko";
              }).activationPackage;
            home-minimal =
              (homeBuild {
                context = "nixko-minimal";
              }).activationPackage;
          };
        wsl =
          { ... }:
          {
            system = self.nixosConfigurations.wsl.config.system.build.toplevel;
            builder = self.nixosConfigurations.wsl.config.system.build.tarballBuilder;
          };
        packages =
          { ... }:
          {
            deploy-rs = {
              ${system} = inputs.deploy-rs.packages."${system}".deploy-rs;
              "aarch64-linux" = inputs.deploy-rs.packages."aarch64-linux".deploy-rs;
            };
          };
        nix-cachyos-kernel =
          { nix-cachyos-kernel, ... }:
          {
            linux-cachyos-latest = (import nix-cachyos-kernel).packages.x86_64-linux.linux-cachyos-latest;
            linux-cachyos-latest-lto =
              (import nix-cachyos-kernel).packages.x86_64-linux.linux-cachyos-latest-lto;
          };
      };
      homeConfigurations = {
        nixko = homeBuild {
          context = "nixko-minimal";
        };
      };
      nixosConfigurations = {
        matej70 = nixosBuild {
          context = "matej70";
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
        nixko = nixosBuild {
          context = "nixko";
          modules = [
            (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; })
          ];
        };
        wsl = nixosBuild {
          context = "wsl";
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
    };
}
