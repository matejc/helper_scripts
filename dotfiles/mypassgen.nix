{ variables, pkgs, ... }:
{
  target = "${variables.homeDir}/bin/mypassgen";
  source = pkgs.writeScript "mypassgen.sh" ''
    #!${pkgs.stdenv.shell}
    LENGTH=$1
    [ "$LENGTH" == "" ] && LENGTH=16
    ${pkgs.coreutils}/bin/tr -dc A-Za-z0-9_ < /dev/urandom | ${pkgs.coreutils}/bin/head -c $LENGTH | ${pkgs.findutils}/bin/xargs
  '';
}
