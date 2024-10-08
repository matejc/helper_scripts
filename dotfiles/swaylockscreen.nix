{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/lockscreen";
  source = pkgs.writeScript "swaylockscreen.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.procps}/bin/pgrep swaylock
    if [ $? -ne 0 ]
    then
      ${pkgs.swaylock}/bin/swaylock -f -c 000000 $@
    fi
  '';
} {
  target = "/bin/lockscreen-all";
  source = pkgs.writeScript "lockscreen-all" ''
    #!${pkgs.stdenv.shell}

    export PATH="${lib.makeBinPath [ pkgs.gnugrep pkgs.gawk pkgs.findutils pkgs.systemd ]}"

    loginctl list-sessions | grep '^\ ' | awk '{print $1}' | xargs -i loginctl lock-session '{}'
  '';
}]
