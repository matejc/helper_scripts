{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/find-mac";
  source = pkgs.writeScript "mac.sh" ''
    #!/usr/bin/env bash

    OUI=$(echo ''${1//[:.- ]/} | tr "[a-f]" "[A-F]" | ${pkgs.gnugrep}/bin/egrep -o "^[0-9A-F]{6}")


    if [ ! -f /tmp/oui.txt ]; then
      ${pkgs.wget}/bin/wget -O /tmp/oui.txt http://standards-oui.ieee.org/oui.txt
    fi
    cat /tmp/oui.txt | grep $OUI
  '';
}
