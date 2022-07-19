{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/nwg-launchers/nwgbar/bar.json";
  source = pkgs.writeText "nwgbar.json" ''
[
  {
    "name": "Lock screen",
    "exec": "swaylock -f -c 000000",
    "icon": "system-lock-screen"
  },
  {
    "name": "Sleep",
    "exec": "systemctl suspend",
    "icon": "system-suspend"
  },
  {
    "name": "Logout",
    "exec": "swaymsg exit",
    "icon": "system-log-out"
  },
  {
    "name": "Reboot",
    "exec": "systemctl reboot",
    "icon": "system-reboot"
  },
  {
    "name": "Shutdown",
    "exec": "systemctl -i poweroff",
    "icon": "system-shutdown"
  }
]
  '';
}
