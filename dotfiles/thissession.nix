{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/thissession";
  source = pkgs.writeScript "thissession" ''
    #!${pkgs.stdenv.shell}
    env DISPLAY=:0 USER=${variables.user} XAUTHORITY=${variables.homeDir}/.Xauthority "$@"
  '';
}
