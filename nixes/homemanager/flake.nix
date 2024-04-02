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
  };

  # nixConfig = {
  #   extra-substituters = [
  #     "https://nix-community.cachix.org"
  #     "https://hydra.nixos.org"
  #   ];
  #   extra-trusted-public-keys = [
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #     "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  #   ];
  # };

  outputs = { self, ... }@inputs: {
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
        system = "x86_64-linux";
        modules = [
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; helper_scripts = ../..; })
          inputs.home-manager.nixosModules.home-manager
          ../../nixes/sway-wsshare/module.nix
          (import ./configuration.nix { inherit inputs; contextFile = ./contexts/matej70.nix; })
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
      # matej70-niri = inputs.nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; helper_scripts = ../..; })
      #     inputs.home-manager.nixosModules.home-manager
      #     (import ./configuration.nix { inherit inputs; contextFile = ./contexts/matej70-niri.nix; })
      #   ];
      # };
      matej80 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; helper_scripts = ../..; })
          inputs.home-manager.nixosModules.home-manager
          ../../nixes/sway-wsshare/module.nix
          (import ./configuration.nix { inherit inputs; contextFile = ./contexts/matej80.nix; })
        ];
      };
      nixcode = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; })
          inputs.home-manager.nixosModules.home-manager
          ../../nixes/sway-wsshare/module.nix
          (import ./configuration.nix { inherit inputs; contextFile = ./contexts/nixcode-nixos.nix; })
        ];
      };
      # nixcode-niri = inputs.nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; })
      #     inputs.home-manager.nixosModules.home-manager
      #     (import ./configuration.nix { inherit inputs; contextFile = ./contexts/nixcode-niri.nix; })
      #   ];
      # };
      # nixcode-hyprland = inputs.nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     (import "${inputs.nixos-configuration}/configuration.nix" { inherit inputs; })
      #     inputs.home-manager.nixosModules.home-manager
      #     (import ./configuration.nix { inherit inputs; contextFile = ./contexts/nixcode-hyprland.nix; })
      #   ];
      # };
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
