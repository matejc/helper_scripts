{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/lockscreen";
  source = pkgs.writeScript "lockscreen" ''
    #!${pkgs.stdenv.shell}
    revert() {
      xset dpms 0 0 0
    }
    trap revert HUP INT TERM
    xset +dpms dpms 5 5 5
    sleep 1
    /run/wrappers/bin/slock
    revert
  '';
}
