{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/connman-restart";
  source = pkgs.writeScript "connman-restart.sh" ''
    #!${pkgs.stdenv.shell} -l
    systemctl restart connman
    echo Restart Connman
    sleep 1
    ${pkgs.procps}/bin/pkill -9 cmst || true
    echo CMST Killed
    su - ${variables.user} -c "${variables.homeDir}/bin/thissession cmst &"
    echo CMST Start
  '';
}]
