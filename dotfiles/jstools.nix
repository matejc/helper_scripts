{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/jcurl";
  source = pkgs.writeScript "jcurl.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.curl}/bin/curl "$@" | ${pkgs.jq}/bin/jq -C '.' | $PAGER
  '';
} {
  target = "${variables.homeDir}/bin/jcat";
  source = pkgs.writeScript "jcat.sh" ''
    #!${pkgs.stdenv.shell}
    cat "$@" | ${pkgs.jq}/bin/jq -C '.'
  '';
} {
  target = "${variables.homeDir}/bin/jless";
  source = pkgs.writeScript "jless.sh" ''
    #!${pkgs.stdenv.shell}
    cat "$@" | ${pkgs.jq}/bin/jq -C '.' | $PAGER
  '';
}]
