{
  description = "NixOS configuration";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "path:../../nixpkgs";
    configuration.url = "path:/etc/nixos/configuration.nix";
  };

  outputs = { home-manager, nixpkgs, configuration, ... }: {
    nixosConfigurations = {
      hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.matejc = import ./matej70.nix;
          }
        ];
      };
    };
  };
}
