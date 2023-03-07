{ variables, config, pkgs, lib }:
let
  images = pkgs.runCommand "" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p $out
    cd ${pkgs.nwg-bar}/share/nwg-bar/images/
    for file in *.svg
    do
      convert -background none -size 64x64 "$file" "$out/''${file}.png"
    done
  '';
in
{
  target = "${variables.homeDir}/.config/nwg-bar/bar.json";
  source = pkgs.writeText "nwgbar.json" ''
[
  {
    "name": "Lock screen",
    "exec": "swaylock -f -c 000000",
    "icon": "${images}/system-lock-screen.svg.png"
  },
  {
    "name": "Sleep",
    "exec": "systemctl suspend",
    "icon": "system-suspend"
  },
  {
    "name": "Logout",
    "exec": "swaymsg exit",
    "icon": "${images}/system-log-out.svg.png"
  },
  {
    "name": "Reboot",
    "exec": "systemctl reboot",
    "icon": "${images}/system-reboot.svg.png"
  },
  {
    "name": "Shutdown",
    "exec": "systemctl -i poweroff",
    "icon": "${images}/system-shutdown.svg.png"
  }
]
  '';
}
