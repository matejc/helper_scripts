{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/mako/config";
  source = pkgs.writeText "mako.conf" ''
    group-by=app-names
  '';
}]
