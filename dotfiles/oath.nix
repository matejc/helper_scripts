{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/oath";
  source = pkgs.writeScript "oath-copy" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.oath-toolkit}/bin/oathtool --base32 --totp `cat "$1" | ${pkgs.jq}/bin/jq ".[] | select(.name == \"$2\") | .secret" -r` $3  | ${pkgs.gawk}/bin/awk '{printf $1}' | ${if variables.sway.enable then "${pkgs.wl-clipboard}/bin/wl-copy" else "${pkgs.xclip}/bin/xclip -sel clip"}
  '';
} {
  target = "${variables.homeDir}/bin/oath-raw";
  source = pkgs.writeScript "oath-raw" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.oath-toolkit}/bin/oathtool --base32 --totp `cat "$1" | ${pkgs.jq}/bin/jq ".[] | select(.name == \"$2\") | .secret" -r` $3  | ${pkgs.gawk}/bin/awk '{printf $1}'
  '';
}]
