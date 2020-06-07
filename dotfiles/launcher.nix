{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/launcher";
  source = pkgs.writeScript "screenshooter.sh" ''
    #!${pkgs.stdenv.shell}
    ${if variables.sway.enable then ''
      BEMENU_BACKEND=wayland ${variables.homeDir}/bin/bemenu-launcher
    '' else ''
      ${pkgs.rofi}/bin/rofi -show combi -combi-modi run
    ''}
  '';
}]
