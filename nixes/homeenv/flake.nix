{
  description = "Example home-manager from non-nixos system";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs: {
    homeConfigurations = {
      wsl = inputs.home-manager.lib.homeManagerConfiguration rec {
        configuration = ./configuration-wsl.nix;
        system = "x86_64-linux";
        homeDirectory = "/home/${username}";
        username = "matejc";
      };
    };

    wsl = self.homeConfigurations.wsl.activationPackage;
    defaultPackage.x86_64-linux = self.wsl;
  };
}
