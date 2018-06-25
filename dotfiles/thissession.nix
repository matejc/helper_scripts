{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/thissession";
  source = pkgs.writeScript "thissession" ''
    #!${pkgs.stdenv.shell} -l
    export USER="${variables.user}"
    export XDG_RUNTIME_DIR="/run/user/$(getent passwd "$USER" | cut -d: -f3)"
    env DISPLAY=:0 XAUTHORITY=${variables.homeDir}/.Xauthority "$@"
  '';
}
