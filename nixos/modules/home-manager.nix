{ inputs, defaultUser, context, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager.backupFileExtension = "backup";
    home-manager.extraSpecialArgs = {
      inherit inputs context defaultUser;
    };
    home-manager.users.${defaultUser} = ../../contexts/${context}/home.nix;
  };
}
