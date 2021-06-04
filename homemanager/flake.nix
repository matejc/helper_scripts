{
  description = "NixOS configuration";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "path:/home/matejc/workarea/nixpkgs";
  };

  outputs = { home-manager, nixpkgs, ... }: {
    nixosConfigurations = {
      homemanager = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          /etc/nixos/configuration.nix
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
