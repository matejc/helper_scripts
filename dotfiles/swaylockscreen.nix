{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/lockscreen";
  source = pkgs.writeScript "swaylockscreen.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.procps}/bin/pgrep swaylock
    if [ $? -ne 0 ]
    then
      swaylock -i ${variables.lockImage}
    fi
  '';
}
