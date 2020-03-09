{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/launcher";
  source = pkgs.writeScript "screenshooter.sh" ''
    #!${pkgs.stdenv.shell}
    ${if variables.sway.enable then ''
      ${pkgs.wofi}/bin/wofi --show drun,run --insensitive --prompt Search
    '' else ''
      ${pkgs.rofi}/bin/rofi -show combi -combi-modi drun#run
    ''}
  '';
}]
