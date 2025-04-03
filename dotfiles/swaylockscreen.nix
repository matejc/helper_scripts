{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/lockscreen";
  source = pkgs.writeScript "swaylockscreen.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.procps}/bin/pgrep swaylock
    if [ $? -ne 0 ]
    then
      if [ -f "${variables.lockImage}" ]
      then
        ${pkgs.swaylock}/bin/swaylock -f -i "${variables.lockImage}" $@
      else
        ${pkgs.swaylock}/bin/swaylock -f -c 000000 $@
      fi
    fi
  '';
} {
  target = "${variables.homeDir}/bin/lockscreen-all";
  source = pkgs.writeScript "lockscreen-all" ''
    #!${pkgs.stdenv.shell}

    export PATH="${lib.makeBinPath [ pkgs.gnugrep pkgs.gawk pkgs.findutils pkgs.systemd ]}"

    loginctl list-sessions | grep '^\ ' | awk '{print $1}' | xargs -i loginctl lock-session '{}'
  '';
}]
