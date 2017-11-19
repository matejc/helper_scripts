{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/autolock";
  source = pkgs.writeScript "autolock" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.xorg.xset}/bin/xset s 600
    ${pkgs.xss-lock}/bin/xss-lock ${variables.homeDir}/bin/lockscreen
  '';
}
