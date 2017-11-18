{ variables, config, pkgs, lib }:
let
    now = lib.concatMapStringsSep " + " (i: ''$(cat /sys/class/power_supply/BAT${i}/energy_now)'') variables.batteries;
    full = lib.concatMapStringsSep " + " (i: ''$(cat /sys/class/power_supply/BAT${i}/energy_full)'') variables.batteries;
in
{
    target = "${variables.homeDir}/bin/batstatus";
    source = pkgs.writeScript "batstatus.sh" (
        if ((builtins.length variables.batteries) == 0)
        then
            ''
                #!${pkgs.stdenv.shell}
                PATH="${pkgs.upower}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.findutils}/bin"
                batstatuses="$(upower -e | grep -i 'ups\|bat' | xargs -i upower -i '{}' | grep 'percentage:' | grep -oP '[0-9]+' | grep -v '^$')"
                echo "$batstatuses" | awk '{ total += $1; count++ } END { print total/count }'
            ''
        else
            ''
                #!${pkgs.stdenv.shell}
                ${pkgs.coreutils}/bin/printf "%.0f\n" $(${pkgs.bc}/bin/bc -l <<< "(${now}) / (${full}) * 100")
            '');
}
