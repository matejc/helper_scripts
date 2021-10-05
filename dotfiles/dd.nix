{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/mydd";
  source = pkgs.writeScript "dd.sh" ''
    #!${pkgs.stdenv.shell}
    set -e
    export PATH=${pkgs.coreutils}/bin:${pkgs.pv}/bin
    dd if=$1 | pv | dd of=$2 "''${@:3}"
  '';
}
