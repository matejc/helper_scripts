{ inputs, ... }:
{
  imports = [
    ../../nixos/modules/variables.nix
    ../../nixos/modules/misc.nix
    ../../nixos/modules/home-manager.nix
    inputs.NixOS-WSL.nixosModules.wsl
    ../../nixos/wsl/configuration.nix
  ];
}
