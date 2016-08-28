{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.i3status.conf";
  source = pkgs.writeText "i3status" ''
  general {
          output_format = "i3bar"
          colors = true
          interval = 5
  }

  ${lib.concatMapStringsSep "\n" (i: ''order += "disk ${i}"'') variables.mounts}
  order += "ethernet ${variables.ethernetInterface}"
  order += "wireless ${variables.wirelessInterface}"
  order += "ethernet ${variables.vpnInterface}"
  ${lib.concatMapStringsSep "\n" (i: ''order += "battery ${i}"'') variables.batteries}
  ${lib.concatImapStringsSep "\n" (pos: i: ''order += "cpu_temperature ${toString pos}"'') variables.temperatureFiles}
  order += "load"
  order += "volume master"
  order += "tztime local"

  wireless ${variables.wirelessInterface} {
          format_up = "%quality at %essid, %bitrate, %ip"
          format_down = "W: down"
  }

  ethernet ${variables.ethernetInterface} {
          # if you use %speed, i3status requires the cap_net_admin capability
          format_up = "%ip (%speed)"
          format_down = "E: down"
  }

  ethernet ${variables.vpnInterface} {
          # if you use %speed, i3status requires the cap_net_admin capability
          format_up = "%ip"
          format_down = "V: down"
  }

  ${lib.concatMapStringsSep "\n" (i: ''
  battery ${i} {
      format = "%status %percentage %remaining"
      path = "/sys/class/power_supply/BAT%d/uevent"
      low_threshold = 10
  }
  '') variables.batteries}

  tztime local {
          format = "%Y-%m-%d %H:%M:%S"
  }

  load {
          format = "%1min"
  }

  ${lib.concatImapStringsSep "\n" (pos: i: ''
  cpu_temperature ${toString pos} {
        format = "%degrees °C"
        path = "${i}"
  }
  '') variables.temperatureFiles}

  ${lib.concatMapStringsSep "\n" (i: ''
  disk "${i}" {
          format = "${i}:%free"
  }
  '') variables.mounts}

  volume master {
          format = "♪ %volume"
          device = "default"
          mixer = "Master"
          mixer_idx = ${variables.soundCard}
  }
  '';
}
