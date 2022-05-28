{ pkgs, lib, config, ... }:
with lib;
let
  defaultUser = config.nixosHomeManager.defaultUser;
  homeManagerSrc = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
  };
in {
  options.nixosHomeManager.defaultUser = mkOption {
    type = types.str;
    description = ''
      Default user
    '';
  };

  config = {
    imports = [ (import "${homeManagerSrc}/nixos") ];
    home-manager.users.${defaultUser} = import ./configuration.nix {
      inherit pkgs lib config defaultUser;
    };
  };
}
