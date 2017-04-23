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

  ${lib.concatMapStringsSep "\n" (i: ''order += "ethernet ${i}"'') variables.ethernetInterfaces}
  ${lib.concatMapStringsSep "\n" (i: ''order += "wireless ${i}"'') variables.wirelessInterfaces}

  ${lib.concatMapStringsSep "\n" (i: ''order += "battery ${i}"'') variables.batteries}
  ${lib.concatImapStringsSep "\n" (pos: i: ''order += "cpu_temperature ${toString pos}"'') variables.temperatureFiles}
  order += "load"
  order += "volume master"
  order += "tztime local"

  ${lib.concatMapStringsSep "\n" (i: ''
    wireless ${i} {
            format_up = "${i}: %quality at %essid, %bitrate, %ip"
            format_down = "${i}: down"
    }
  '') variables.wirelessInterfaces}

  ${lib.concatMapStringsSep "\n" (i: ''
    ethernet ${i} {
            # if you use %speed, i3status requires the cap_net_admin capability
            format_up = "${i}: %ip (%speed)"
            format_down = "${i}: down"
    }
  '') variables.ethernetInterfaces}

  ${lib.concatMapStringsSep "\n" (i: ''
  battery ${i} {
      format = "%status %percentage %remaining"
      path = "/sys/class/power_supply/BAT%d/uevent"
      low_threshold = 10
  }
  '') variables.batteries}

  tztime local {
          format = "${variables.timeFormat}"
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
          format = "♪: %volume"
          device = "default"
          mixer = "Master"
          mixer_idx = ${variables.soundCard}
  }
  '';
}
