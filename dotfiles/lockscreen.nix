{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/lockscreen";
  source = pkgs.writeScript "lockscreen" ''
    #!${pkgs.stdenv.shell}
    ${variables.homeDir}/bin/i3lock-wrapper &
    sleep 1
    xset dpms force off
  '';
}
