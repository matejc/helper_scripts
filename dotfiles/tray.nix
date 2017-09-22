{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/systemtray";
  source = pkgs.writeScript "systemtray.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.stalonetray}/bin/stalonetray -v --geometry 1x1+0-50 --grow-gravity S "$@"
  '';
}
