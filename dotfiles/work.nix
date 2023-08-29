{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/work-since-until";
  source = pkgs.writeScript "work-since-until.sh" ''
    #!${pkgs.stdenv.shell}
    log2seconds() {
      ${pkgs.jq}/bin/jq --slurp '. as $d|([select($d[]|.MESSAGE|contains("Entering"))]|flatten|last|.__REALTIME_TIMESTAMP|tonumber)-([select($d[]|.MESSAGE|contains("returned"))]|flatten|first|.__REALTIME_TIMESTAMP|tonumber)|./1000000' 2>/dev/null
    }
    diff=$(journalctl -t systemd-sleep -S "$1" -U "$2" -o json | log2seconds | cut -d "." -f 1 | tr -d "\n")
    if [ -z "$diff" ]
    then
      exit 1
    fi
    echo "$(($diff / 3600))h $((($diff / 60) % 60))m $(($diff % 60))s"
  '';
} {
  target = "${variables.homeDir}/bin/work-today";
  source = pkgs.writeScript "work-today.sh" ''
    #!${pkgs.stdenv.shell}
    log2seconds() {
      ${pkgs.jq}/bin/jq --slurp '(now-(.|map(select(.MESSAGE|contains("returned")))|first|.__REALTIME_TIMESTAMP|tonumber/1000000))' 2>/dev/null
    }
    diff=$(journalctl -t systemd-sleep -S today -o json | log2seconds | cut -d "." -f 1 | tr -d "\n")
    if [ -z "$diff" ]
    then
      exit 1
    fi
    echo "$(($diff / 3600))h $((($diff / 60) % 60))m $(($diff % 60))s"
  '';
} {
  target = "${variables.homeDir}/bin/work-day";
  source = pkgs.writeScript "work-day.sh" ''
    #!${pkgs.stdenv.shell}
    log2seconds() {
      ${pkgs.jq}/bin/jq --slurp '. as $d|([select($d[]|.MESSAGE|contains("Entering"))]|flatten|last|.__REALTIME_TIMESTAMP|tonumber)-([select($d[]|.MESSAGE|contains("returned"))]|flatten|first|.__REALTIME_TIMESTAMP|tonumber)|./1000000' 2>/dev/null
    }
    diff=$(journalctl -t systemd-sleep -S "$1 00:00:00" -U "$1 23:59:59" -o json | log2seconds | cut -d "." -f 1 | tr -d "\n")
    if [ -z "$diff" ]
    then
      exit 1
    fi
    if [[ "$2" == "seconds" ]]
    then
      echo "''${diff}s"
    else
      echo "$(($diff / 3600))h $((($diff / 60) % 60))m $(($diff % 60))s"
    fi
  '';
}]
