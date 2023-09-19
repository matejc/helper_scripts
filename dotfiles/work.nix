{ variables, config, pkgs, lib }:
let
  startSeconds = pkgs.writeScript "start-seconds.sh" ''
    #!${pkgs.stdenv.shell}
    wakeupSeconds="$(journalctl -t systemd-sleep -S "$1" -U "$2" -o json | ${pkgs.jq}/bin/jq --slurp '.|map(select(.MESSAGE|contains("returned")))|first|.__REALTIME_TIMESTAMP|tonumber/1000000' 2>/dev/null | cut -d "." -f 1 | tr -d "\n")"
    userLoginSeconds="$(journalctl --user -t systemd -S "$1" -U "$2" -o json | ${pkgs.jq}/bin/jq --slurp '.|map(select(.MESSAGE|contains("Startup finished")))|first|.__REALTIME_TIMESTAMP|tonumber/1000000' 2>/dev/null | cut -d "." -f 1 | tr -d "\n")"
    if [ ! -z "$wakeupSeconds" ] && [ ! -z "$userLoginSeconds" ]
    then
      if [ $wakeupSeconds -gt $userLoginSeconds ]
      then
        echo -n "$wakeupSeconds"
      else
        echo -n "$userLoginSeconds"
      fi
    elif [ ! -z "$wakeupSeconds" ]
    then
      echo -n "$wakeupSeconds"
    elif [ ! -z "$userLoginSeconds" ]
    then
      echo -n "$userLoginSeconds"
    else
      echo -n "0"
    fi
  '';
  endSeconds = pkgs.writeScript "end-seconds.sh" ''
    #!${pkgs.stdenv.shell}
    sleepSeconds="$(journalctl -t systemd-sleep -S "$1" -U "$2" -o json | ${pkgs.jq}/bin/jq --slurp '.|map(select(.MESSAGE|contains("Entering")))|last|.__REALTIME_TIMESTAMP|tonumber/1000000' 2>/dev/null | cut -d "." -f 1 | tr -d "\n")"
    stopLoginSeconds="$(journalctl --user -t systemd -S "$1" -U "$2" -o json | ${pkgs.jq}/bin/jq --slurp '.|map(select(.MESSAGE|contains("Stopping User Login Management")))|last|.__REALTIME_TIMESTAMP|tonumber/1000000' 2>/dev/null | cut -d "." -f 1 | tr -d "\n")"
    if [ ! -z "$sleepSeconds" ] && [ ! -z "$stopLoginSeconds" ]
    then
      if [ $stopLoginSeconds -gt $sleepSeconds ]
      then
        echo -n "$sleepSeconds"
      else
        echo -n "$stopLoginSeconds"
      fi
    elif [ ! -z "$sleepSeconds" ]
    then
      echo -n "$sleepSeconds"
    elif [ ! -z "$stopLoginSeconds" ]
    then
      echo -n "$stopLoginSeconds"
    else
      echo -n "0"
    fi
  '';
in [{
  target = "${variables.homeDir}/bin/work-today";
  source = pkgs.writeScript "work-today.sh" ''
    #!${pkgs.stdenv.shell}
    startSeconds="$(${startSeconds} today tomorrow)"
    diff="$(echo "$startSeconds" | ${pkgs.jq}/bin/jq -r 'now - .' | cut -d "." -f 1 | tr -d "\n")"
    echo "$(($diff / 3600))h $((($diff / 60) % 60))m $(($diff % 60))s"
  '';
} {
  target = "${variables.homeDir}/bin/work-range";
  source = pkgs.writeScript "work-range.sh" ''
    #!${pkgs.stdenv.shell}
    startSeconds="$(${startSeconds} "$1" "$2")"
    endSeconds="$(${endSeconds} "$1" "$2")"
    diff=$(( $endSeconds - $startSeconds ))
    if [ -z "$diff" ]
    then
      exit 1
    else
      echo "$(($diff / 3600))h $((($diff / 60) % 60))m $(($diff % 60))s"
    fi
  '';
}]
