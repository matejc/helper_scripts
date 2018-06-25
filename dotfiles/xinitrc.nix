{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.xinitrc";
  source = pkgs.writeScript "xinitrc" ''
    #!${pkgs.stdenv.shell}
    ${variables.homeDir}/bin/autolock &
  '';
}
