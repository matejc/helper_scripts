{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/lockscreen";
  source = pkgs.writeScript "lockscreen" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.procps}/bin/pgrep slock
    if [ $? -ne 0 ]
    then
      revert() {
        ${pkgs.xorg.xset}/bin/xset dpms 0 0 0
      }
      trap revert HUP INT TERM
      ${pkgs.xorg.xset}/bin/xset +dpms dpms 5 5 5
      sleep 1
      /run/wrappers/bin/slock
      revert
    fi
  '';
}
