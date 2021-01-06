{
  description = "Example home-manager from non-nixos system";
  inputs = {
    nixpkgs.url = "github:matejc/nixpkgs/mylocal198";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, ... }@inputs: {
    homeConfigurations = {
      wsl = inputs.home-manager.lib.homeManagerConfiguration rec {
        configuration = { ... }: {
          imports = [ ./configuration-wsl.nix ];
          nixpkgs.overlays = [ inputs.nur.overlay ];
        };
        system = "x86_64-linux";
        homeDirectory = "/home/${username}";
        username = "matejc";
      };
    };

    wsl = self.homeConfigurations.wsl.activationPackage;
    defaultPackage.x86_64-linux = self.wsl;
  };
}
