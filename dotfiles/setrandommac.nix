{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/setrandommac";
  source = pkgs.writeScript "setrandommac" ''
    #!${pkgs.stdenv.shell}
    set -ex
    INTERFACE="$1"
    test -n "$INTERFACE"
    MACADDRESS="e0:$(${pkgs.openssl}/bin/openssl rand -hex 5 | ${pkgs.gnused}/bin/sed 's/\(..\)/\1:/g; s/.$//')"
    ${pkgs.nettools}/bin/ifconfig $INTERFACE down
    sleep 1
    ${pkgs.nettools}/bin/ifconfig $INTERFACE hw ether $MACADDRESS
    ${pkgs.nettools}/bin/ifconfig $INTERFACE up
  '';
}]
