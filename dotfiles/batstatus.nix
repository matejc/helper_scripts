{ variables, config, pkgs, lib }:
let
    now = lib.concatMapStringsSep " + " (i: ''$(cat /sys/class/power_supply/BAT${i}/energy_now)'') variables.batteries;
    full = lib.concatMapStringsSep " + " (i: ''$(cat /sys/class/power_supply/BAT${i}/energy_full)'') variables.batteries;
in
{
    target = "${variables.homeDir}/bin/batstatus";
    source =
        if ((builtins.length variables.batteries) == 0)
        then
            pkgs.writeScript "batstatus.sh" ''
                #!${pkgs.stdenv.shell}
                echo
            ''
        else
            pkgs.writeScript "batstatus.sh" ''
                #!${pkgs.stdenv.shell}
                ${pkgs.coreutils}/bin/printf "%.1f\n" $(${pkgs.bc}/bin/bc -l <<< "(${now}) / (${full}) * 100")
            '';
}
