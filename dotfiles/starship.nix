{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/starship.toml";
  source = pkgs.writeText "starship" ''
    [aws]
    disabled = true
  '';
}]
