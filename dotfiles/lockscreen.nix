{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/lockscreen";
  source = pkgs.writeScript "lockscreen" ''
    #!${pkgs.stdenv.shell}

    ${pkgs.procps}/bin/pgrep i3lock

    if [ $? -ne 0 ]
    then
      revert() {
        ${pkgs.xorg.xset}/bin/xset dpms 0 0 0
      }
      trap revert HUP INT TERM
      ${pkgs.xorg.xset}/bin/xset +dpms dpms 5 5 5
      sleep 0.25
      /run/wrappers/bin/i3lock -i ${variables.lockImage} --nofork
      revert
    fi
  '';
} {
  target = "${variables.homeDir}/bin/lockall";
  source = pkgs.writeScript "lockall" ''
    #!${pkgs.stdenv.shell}

    export PATH="${lib.makeBinPath [ pkgs.gnugrep pkgs.gawk pkgs.findutils pkgs.systemd ]}"

    loginctl list-sessions | grep '^\ ' | awk '{print $1}' | xargs -i loginctl lock-session '{}'
  '';
}]
