{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/setbrightness";
  source = pkgs.writeScript "setbrightness" ''
    #!${pkgs.stdenv.shell}

    MAX=$(cat ${variables.backlightSysDir}/max_brightness)
    CURR=$(cat ${variables.backlightSysDir}/brightness)

    if [[ $1 == 'inc' ]]; then
        NEW=$(( $CURR + $MAX / 10 ))
    elif [[ $1 == 'dec' ]]; then
        NEW=$(( $CURR - $MAX / 10 ))
    fi

    echo $NEW > ${variables.backlightSysDir}/brightness

    notify-send Brightness "`${variables.homeDir}/bin/getbrightness`%" -t 200
  '';
} {
  target = "${variables.homeDir}/bin/getbrightness";
  source = pkgs.writeScript "getbrightness" ''
    #!${pkgs.stdenv.shell}

    MAX=$(cat ${variables.backlightSysDir}/max_brightness)
    CURR=$(cat ${variables.backlightSysDir}/brightness)

    echo $CURR $MAX | ${pkgs.gawk}/bin/awk '{printf( "%0.0f", $1/$2*100 )}'
  '';
}]
