{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/oath";
  source = pkgs.writeScript "oath-copy" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.oathToolkit}/bin/oathtool --base32 --totp `cat "$1" | jq ".[] | select(.name == \"$2\") | .secret" -r` $3  | ${pkgs.gawk}/bin/awk '{printf $1}' | ${pkgs.xclip}/bin/xclip -sel clip
  '';
}