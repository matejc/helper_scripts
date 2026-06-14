{
  variables,
  config,
  pkgs,
  lib,
}:
[
  {
    target = "${variables.homeDir}/bin/lockscreen";
    source = pkgs.writeScript "noctalialockscreen.sh" ''
      #!${pkgs.stdenv.shell}
      exec ${pkgs.noctalia}/bin/noctalia msg session lock
    '';
  }
]
