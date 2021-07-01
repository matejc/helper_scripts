{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/keepassxc-oath";
  source = pkgs.writeScript "keepassxc-oath.sh" ''
    #!${pkgs.stdenv.shell}

    oath="$(${pkgs.keepassxc}/bin/keepassxc-cli show $KEEPASS_DB -k $KEEPASS_KEY oath -a notes)"
    ${pkgs.oathToolkit}/bin/oathtool --base32 --totp `echo "$oath" | ${pkgs.jq}/bin/jq ".[] | select(.name == \"$1\") | .secret" -r` | ${pkgs.gawk}/bin/awk '{printf $1}'
  '';
}
