{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/nix/nix.conf";
  source = pkgs.writeText "nix.conf" ''
    experimental-features = nix-command flakes
  '';
}]
