{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/lockscreen";
  source = pkgs.writeScript "lockscreen" ''
    #!${pkgs.stdenv.shell}

    ${pkgs.procps}/bin/pgrep i3lock

    if [ $? -ne 0 ] && ! ${variables.homeDir}/bin/is-win-fullscreen
    then
      revert() {
        ${pkgs.xorg.xset}/bin/xset dpms 0 0 0
        ${pkgs.xorg.xset}/bin/xset -display $DISPLAY dpms force on
      }
      trap revert HUP INT TERM
      ${pkgs.xorg.xset}/bin/xset +dpms dpms 2 2 2
      sleep 0.25
      /run/wrappers/bin/i3lock -i ${variables.lockImage} --nofork
      revert
    fi
  '';
} {
  target = "/bin/lockscreen-all";
  source = pkgs.writeScript "lockscreen-all" ''
    #!${pkgs.stdenv.shell}

    export PATH="${lib.makeBinPath [ pkgs.gnugrep pkgs.gawk pkgs.findutils pkgs.systemd ]}"

    loginctl list-sessions | grep '^\ ' | awk '{print $1}' | xargs -i loginctl lock-session '{}'
  '';
} {
  target = "${variables.homeDir}/bin/is-win-fullscreen";
  source = pkgs.writeScript "is-win-fullscreen.sh" ''
    #!${pkgs.stdenv.shell}

    activ_win_id="$(${pkgs.xorg.xprop}/bin/xprop -root _NET_ACTIVE_WINDOW)"
    ${pkgs.xorg.xprop}/bin/xprop -id ''${activ_win_id:40:9} | ${pkgs.gnugrep}/bin/grep -q _NET_WM_STATE_FULLSCREEN
  '';
}]
