{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/work-since-until";
  source = pkgs.writeScript "work-since-until.sh" ''
    #!${pkgs.stdenv.shell}
    journalctl -t systemd-sleep -S "$1" -U "$2" -o json | ${pkgs.jq}/bin/jq --slurp '. as $d|(select($d[]|.MESSAGE|contains("Entering"))|last|.__MONOTONIC_TIMESTAMP|tonumber)-(select($d[]|.MESSAGE|contains("returned"))|first|.__MONOTONIC_TIMESTAMP|tonumber)|./1000000/60/60'
  '';
} {
  target = "${variables.homeDir}/bin/work-today";
  source = pkgs.writeScript "work-today.sh" ''
    #!${pkgs.stdenv.shell}
    journalctl -t systemd-sleep -S today -o json | ${pkgs.jq}/bin/jq --slurp '(now-(.|map(select(.MESSAGE|contains("returned")))|first|.__REALTIME_TIMESTAMP|tonumber/1000000))/60/60'
  '';
}]
