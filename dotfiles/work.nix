{ variables, pkgs, lib, ... }:
let
  startSeconds = pkgs.writeShellScript "start-seconds.sh" ''
    export PATH="$PATH:${lib.makeBinPath [ pkgs.jq ]}"
    wakeupSeconds="$(journalctl -t systemd-sleep -S "$1" -U "$2" -o json | jq --slurp '.|map(select(.MESSAGE|contains("returned")))|first|.__REALTIME_TIMESTAMP|tonumber/1000000' 2>/dev/null | cut -d "." -f 1 | tr -d "\n")"
    userLoginSeconds="$(journalctl --user -t systemd -S "$1" -U "$2" -o json | jq --slurp '.|map(select(.MESSAGE|contains("Startup finished")))|first|.__REALTIME_TIMESTAMP|tonumber/1000000' 2>/dev/null | cut -d "." -f 1 | tr -d "\n")"
    if [ ! -z "$wakeupSeconds" ] && [ ! -z "$userLoginSeconds" ]
    then
      if (( wakeupSeconds > userLoginSeconds ))
      then
        echo -n "$userLoginSeconds"
      else
        echo -n "$wakeupSeconds"
      fi
    elif [ ! -z "$wakeupSeconds" ]
    then
      echo -n "$wakeupSeconds"
    elif [ ! -z "$userLoginSeconds" ]
    then
      echo -n "$userLoginSeconds"
    else
      echo -n "$(date +%s)"
    fi
  '';
  endSeconds = pkgs.writeShellScript "end-seconds.sh" ''
    export PATH="$PATH:${lib.makeBinPath [ pkgs.jq ]}"
    sleepSeconds="$(journalctl -t systemd-sleep -S "$1" -U "$2" -o json | jq --slurp '.|map(select(.MESSAGE|contains("Performing")))|last|.__REALTIME_TIMESTAMP|tonumber/1000000' 2>/dev/null | cut -d "." -f 1 | tr -d "\n")"
    stopLoginSeconds="$(journalctl --user -t systemd -S "$1" -U "$2" -o json | jq --slurp '.|map(select(.MESSAGE|contains("Stopping User Login Management")))|last|.__REALTIME_TIMESTAMP|tonumber/1000000' 2>/dev/null | cut -d "." -f 1 | tr -d "\n")"
    if [ ! -z "$sleepSeconds" ] && [ ! -z "$stopLoginSeconds" ]
    then
      if (( stopLoginSeconds > sleepSeconds ))
      then
        echo -n "$stopLoginSeconds"
      else
        echo -n "$sleepSeconds"
      fi
    elif [ ! -z "$sleepSeconds" ]
    then
      echo -n "$sleepSeconds"
    elif [ ! -z "$stopLoginSeconds" ]
    then
      echo -n "$stopLoginSeconds"
    else
      echo -n "$(date +%s)"
    fi
  '';
in [{
  target = "${variables.homeDir}/bin/work-today";
  source = pkgs.writeShellScript "work-today.sh" ''
    startSeconds="$(${startSeconds} today tomorrow)"
    diff="$(echo "$startSeconds" | ${pkgs.jq}/bin/jq -r 'now - .' | cut -d "." -f 1 | tr -d "\n")"
    echo "$(($diff / 3600))h $((($diff / 60) % 60))m $(($diff % 60))s"
  '';
} {
  target = "${variables.homeDir}/bin/work-range";
  source = pkgs.writeShellScript "work-range.sh" ''
    start_epoch="$(date -d "$1" +%s)"
    days="''${2:-"1"}"
    seconds=0

    for day in $(seq 0 $((days-1)))
    do
      since_date="$(date -d "@$((start_epoch + (day * 86400)))" +"%Y-%m-%d")"
      until_date="$(date -d "@$((start_epoch + ((day+1) * 86400) ))" +"%Y-%m-%d")"
      start_seconds="$(${startSeconds} "$since_date" "$until_date")"
      end_seconds="$(${endSeconds} "$since_date" "$until_date")"
      diff=$(( $end_seconds - $start_seconds ))
      if (( diff >= 0 ))
      then
        seconds="$(( seconds + diff ))"
        echo "On $since_date: $(($diff / 3600))h $((($diff / 60) % 60))m $(($diff % 60))s"
      fi
    done

    echo "Total: $(($seconds / 3600))h $((($seconds / 60) % 60))m $(($seconds % 60))s"
  '';
}]
