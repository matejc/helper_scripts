{ variables, config, pkgs, lib }:
{
    target = "${variables.homeDir}/bin/batstatus";
    source = pkgs.writeScript "batstatus.sh" ''
    #!${pkgs.stdenv.shell}
        echo $(( (\
            ${lib.concatMapStringsSep "\n" (i: ''$(cat /sys/class/power_supply/BAT${i}/capacity) + \'') variables.batteries}
        0 ) / ${toString (builtins.length variables.batteries)} ))
    '';
}
