{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];

  config = {
    nixpkgs.overlays = [
      (final: prev: {
        nix-index = inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-db; # for nixmy
      })
    ];
    programs.nix-index-database.comma.enable = true;
  };
}
