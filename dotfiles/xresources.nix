{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.Xresources";
  source = pkgs.writeScript "Xresources" ''
    rofi.theme: ${variables.rofi.theme}
    rofi.font: ${variables.font}
  '';
}
