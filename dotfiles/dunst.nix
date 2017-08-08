{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/dunst/dunstrc";
  source = pkgs.writeText "dunstrc" ''
[global]
    font = Source Code Pro 10

[frame]
    width = 0
    color = "6092BE"

[urgency_low]
    background = "#40729E"
    foreground = "#FFFFFF"
    timeout = 10

[urgency_normal]
    background = "#40729E"
    foreground = "#FFFFFF"
    timeout = 20

[urgency_critical]
    background = "#801515"
    foreground = "#D46A6A"
    timeout = 60
  '';
}
