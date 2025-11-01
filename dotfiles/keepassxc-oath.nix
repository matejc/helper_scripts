{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/keepassxc-oath";
  source = pkgs.writeScript "keepassxc-oath.sh" ''
    #!${pkgs.stdenv.shell}

    oath="$(${pkgs.keepassxc}/bin/keepassxc-cli show $KEEPASS_DB -k $KEEPASS_KEY $1 -a notes)"
    ${pkgs.oath-toolkit}/bin/oathtool --base32 --totp `echo "$oath" | ${pkgs.jq}/bin/jq ".[] | select(.name == \"$2\") | .secret" -r` | ${pkgs.gawk}/bin/awk '{print $1}'
  '';
}
