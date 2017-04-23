{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/autolock";
  source = pkgs.writeScript "autolock" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.xautolock}/bin/xautolock -time 20 -locker ${variables.homeDir}/bin/lockscreen -detectsleep
  '';
}
