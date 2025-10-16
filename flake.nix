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
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      # url = "github:matejc/noctalia-shell";
      # url = "path:/home/matejc/workarea/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickemu = {
      url = "github:quickemu-project/quickemu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.matejc.com"
      "https://chaotic-nyx.cachix.org"
      "https://niri.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.matejc.com-1:1gX7YfpZK4zkYf5MRrz9HPsJq9XZBC6bJgDySZmzbUM="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
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
            inherit inputs helper_scripts defaultUser;
            contextFile = ./nixos/contexts + "/${context}.nix";
          };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.nix-index
            ./nixos/configuration.nix
          ] ++ modules;
        });
      # pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
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
        matej70 =
          (nixosBuild {
            context = "matej70-niri";
            modules = [
              ./nixos/minimal-configuration.nix
              inputs.chaotic.nixosModules.default
            ];
          }).config.system.build.toplevel;
        matej80 =
          (nixosBuild {
            context = "matej80-niri";
            modules = [
              ./nixos/minimal-configuration.nix
            ];
          }).config.system.build.toplevel;
        nixko =
          (nixosBuild {
            context = "nixko";
            modules = [
              inputs.lanzaboote.nixosModules.lanzaboote
              ./nixos/minimal-configuration.nix
            ];
          }).config.system.build.toplevel;
        wsl =
          (nixosBuild {
            context = "wsl";
            modules = [
              inputs.NixOS-WSL.nixosModules.wsl
              ./nixos/wsl/configuration.nix
            ];
          }).config.system.build.toplevel;
        packages =
          {
            deploy-rs = {
              ${system} = inputs.deploy-rs.packages."${system}".deploy-rs;
              "aarch64-linux" = inputs.deploy-rs.packages."aarch64-linux".deploy-rs;
            };
          };
      };
      nixosConfigurations = {
        matej70 = nixosBuild {
          context = "matej70-niri";
          modules = [
            (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs helper_scripts; })
            inputs.chaotic.nixosModules.default
          ];
        };
        matej80 = nixosBuild {
          context = "matej80-niri";
          modules = [
            (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs helper_scripts; })
          ];
        };
        nixko = nixosBuild {
          context = "nixko";
          modules = [
            inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
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
