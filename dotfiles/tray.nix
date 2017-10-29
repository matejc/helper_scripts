{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/systemtray";
  source = pkgs.writeScript "systemtray.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.stalonetray}/bin/stalonetray -v --geometry 1x1+0+400 --grow-gravity S -t --icon-size=16 "$@"
  '';
}
