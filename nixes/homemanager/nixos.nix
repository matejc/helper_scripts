{ pkgs, lib, config, ... }:
with lib;
let
  defaultUser = config.nixosHomeManager.defaultUser;
  inputs = {
    nixmy = builtins.fetchGit { url = "https://github.com/matejc/nixmy.git"; };
    nixpkgs = builtins.toPath "/home/matejc/workarea/nixpkgs";
    helper_scripts = builtins.toPath "/home/matejc/workarea/helper_scripts";
    home-manager = builtins.fetchGit { url = "https://github.com/nix-community/home-manager.git"; };
    nur = builtins.fetchGit { url = "https://github.com/nix-community/NUR.git"; };
  };
in {
  options.nixosHomeManager.defaultUser = mkOption {
    type = types.str;
    description = ''
      Default user
    '';
  };

  config = {
    imports = [ (import "${inputs.home-manager}/nixos") ];
    home-manager.users.${defaultUser} = (import ./configuration.nix { inherit inputs; }) {
      inherit pkgs lib config defaultUser;
    };
  };
}
