{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/setxbacklight";
  source = pkgs.writeScript "setxbacklight" ''
    #!${pkgs.stdenv.shell}

    if [[ $1 == 'inc' ]]; then
        ${pkgs.xorg.xbacklight}/bin/xbacklight -inc 10
    elif [[ $1 == 'dec' ]]; then
        ${pkgs.xorg.xbacklight}/bin/xbacklight -dec 10
    fi

    # notify-send Brightness "`${variables.homeDir}/bin/getxbacklight`%" -t 100
  '';
} {
  target = "${variables.homeDir}/bin/getxbacklight";
  source = pkgs.writeScript "getxbacklight" ''
    #!${pkgs.stdenv.shell}

    ${pkgs.xorg.xbacklight}/bin/xbacklight -get | ${pkgs.gawk}/bin/awk '{printf( "%0.0f", $1 )}'
  '';
}]
