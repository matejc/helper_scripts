{
  description = "home-manager from non-nixos system";
  inputs = {
    nixpkgs.url = "github:matejc/nixpkgs/mylocal225";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, ... }@inputs: {
    homeConfigurations = {
      homemanager = inputs.home-manager.lib.homeManagerConfiguration rec {
        configuration = { ... }: {
          imports = [ (import ./configuration.nix { inherit inputs; }) ];
          #nixpkgs.overlays = [ inputs.nur.overlay ];
        };
        system = "x86_64-linux";
        homeDirectory = "/home/${username}";
        username = "matejc";
      };
    };

    homemanager = self.homeConfigurations.homemanager.activationPackage;
    defaultPackage.x86_64-linux = self.homemanager;
  };
}
