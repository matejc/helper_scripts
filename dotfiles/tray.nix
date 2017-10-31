{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/systemtray";
  source = pkgs.writeScript "systemtray.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.stalonetray}/bin/stalonetray --geometry 1x1-500+0 -t --icon-size=16 "$@"
  '';
}
