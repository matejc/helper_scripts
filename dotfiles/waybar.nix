{ variables, config, pkgs, lib }:
let
  config = {
    layer = "top";
    position = "bottom";
    height = 24;
    modules-left = [ "sway/workspaces" "sway/mode" ];
    modules-center = [ "sway/window" ];
    modules-right = [ "idle_inhibitor" "pulseaudio" "network" "disk" "cpu" "memory" "temperature" "backlight" "battery" "battery#bat1" "clock" "tray" ];
    "sway/mode".format = "<span style=\"italic\">{}</span>";
    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = "";
        deactivated = "";
      };
    };
    tray.spacing = 10;
    clock.format = "{:%H:%M, %a %d of %b, %Y}";
    cpu = {
        format = "{usage}% ";
        tooltip = false;
    };
    memory.format = "{}% ";
    temperature = {
      hwmon-path = lib.head variables.temperatureFiles;
      critical-threshold = 80;
      format = "{temperatureC}°C {icon}";
      format-icons = [ "" "" "" ];
    };
    backlight = {
      format = "{percent}% {icon}";
      format-icons = [ "" "" ];
    };
    battery = {
      bat = "BAT0";
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{capacity}% {icon}";
      format-charging = "{capacity}% ";
      format-plugged = "{capacity}% ";
      format-alt = "{time} {icon}";
      format-icons = [ "" "" "" "" "" ];
    };
    "battery#bat1" = {
      bat = "BAT1";
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{capacity}% {icon}";
      format-charging = "{capacity}% ";
      format-plugged = "{capacity}% ";
      format-alt = "{time} {icon}";
      format-icons = [ "" "" "" "" "" ];
    };
    network = {
      format-wifi = "{essid} ({signalStrength}%) ";
      format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
      format-linked = "{ifname} (No IP) ";
      format-disconnected = "Disconnected ⚠";
      format-alt = "{ifname}: {ipaddr}/{cidr}";
    };
    pulseaudio = {
      format = "{volume}% {icon} {format_source}";
      format-bluetooth = "{volume}% {icon} {format_source}";
      format-bluetooth-muted = " {icon} {format_source}";
      format-muted = " {format_source}";
      format-source = "{volume}% ";
      format-source-muted = "";
      format-icons = {
        headphone = "";
        hands-free = "";
        headset = "";
        phone = "";
        portable = "";
        car = "";
        default = [ "" "" "" ];
      };
      on-click = "pavucontrol";
    };
    disk = {
      interval = 30;
      format = "{free} {path}";
      path = "/";
    };
  };
in
[{
  target = "${variables.homeDir}/.config/waybar/config";
  source = pkgs.writeText "waybar.json" (builtins.toJSON config);
  #''
    #{
        #"layer": "top", // Waybar at top layer
        #"position": "bottom", // Waybar position (top|bottom|left|right)
        #"height": 24, // Waybar height (to be removed for auto height)
        #// "width": 1280, // Waybar width
        #// Choose the order of the modules
        #"modules-left": ["sway/workspaces", "sway/mode"],
        #"modules-center": ["sway/window"],
        #"modules-right": ["idle_inhibitor", "pulseaudio", "network", "disk", "cpu", "memory", "temperature", "backlight", "battery", "battery#bat1", "clock", "tray"],
        #// Modules configuration
        #// "sway/workspaces": {
        #//     "disable-scroll": true,
        #//     "all-outputs": true,
        #//     "format": "{name}: {icon}",
        #//     "format-icons": {
        #//         "1": "",
        #//         "2": "",
        #//         "3": "",
        #//         "4": "",
        #//         "5": "",
        #//         "urgent": "",
        #//         "focused": "",
        #//         "default": ""
        #//     }
        #// },
        #"sway/mode": {
            #"format": "<span style=\"italic\">{}</span>"
        #},
        #"mpd": {
            #"format": "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ",
            #"format-disconnected": "Disconnected ",
            #"format-stopped": "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ",
            #"unknown-tag": "N/A",
            #"interval": 2,
            #"consume-icons": {
                #"on": " "
            #},
            #"random-icons": {
                #"off": "<span color=\"#f53c3c\"></span> ",
                #"on": " "
            #},
            #"repeat-icons": {
                #"on": " "
            #},
            #"single-icons": {
                #"on": "1 "
            #},
            #"state-icons": {
                #"paused": "",
                #"playing": ""
            #},
            #"tooltip-format": "MPD (connected)",
            #"tooltip-format-disconnected": "MPD (disconnected)"
        #},
        #"idle_inhibitor": {
            #"format": "{icon}",
            #"format-icons": {
                #"activated": "",
                #"deactivated": ""
            #}
        #},
        #"tray": {
            #// "icon-size": 21,
            #"spacing": 10
        #},
        #"clock": {
            #// "timezone": "America/New_York",
            #// "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
            #// "format-alt": "{:%Y-%m-%d}"
            #"format": "{:%H:%M, %a %d of %b, %Y}"
        #},
        #"cpu": {
            #"format": "{usage}% ",
            #"tooltip": false
        #},
        #"memory": {
            #"format": "{}% "
        #},
        #"temperature": {
            #"thermal-zone": 3,
            #// "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
            #"critical-threshold": 80,
            #// "format-critical": "{temperatureC}°C {icon}",
            #"format": "{temperatureC}°C {icon}",
            #"format-icons": ["", "", ""]
        #},
        #"backlight": {
            #// "device": "acpi_video1",
            #"format": "{percent}% {icon}",
            #"format-icons": ["", ""]
        #},
        #"battery": {
            #"bat": "BAT0",
            #"states": {
                #// "good": 95,
                #"warning": 30,
                #"critical": 15
            #},
            #"format": "{capacity}% {icon}",
            #"format-charging": "{capacity}% ",
            #"format-plugged": "{capacity}% ",
            #"format-alt": "{time} {icon}",
            #// "format-good": "", // An empty format will hide the module
            #// "format-full": "",
            #"format-icons": ["", "", "", "", ""]
        #},
        #"battery#bat1": {
            #"bat": "BAT1",
            #"states": {
                #"warning": 30,
                #"critical": 15
            #},
            #"format": "{capacity}% {icon}",
            #"format-charging": "{capacity}% ",
            #"format-plugged": "{capacity}% ",
            #"format-alt": "{time} {icon}",
            #"format-icons": ["", "", "", "", ""]
        #},
        #"network": {
            #// "interface": "wlp2*", // (Optional) To force the use of this interface
            #"format-wifi": "{essid} ({signalStrength}%) ",
            #"format-ethernet": "{ifname}: {ipaddr}/{cidr} ",
            #"format-linked": "{ifname} (No IP) ",
            #"format-disconnected": "Disconnected ⚠",
            #"format-alt": "{ifname}: {ipaddr}/{cidr}"
        #},
        #"pulseaudio": {
            #// "scroll-step": 1, // %, can be a float
            #"format": "{volume}% {icon} {format_source}",
            #"format-bluetooth": "{volume}% {icon} {format_source}",
            #"format-bluetooth-muted": " {icon} {format_source}",
            #"format-muted": " {format_source}",
            #"format-source": "{volume}% ",
            #"format-source-muted": "",
            #"format-icons": {
                #"headphone": "",
                #"hands-free": "",
                #"headset": "",
                #"phone": "",
                #"portable": "",
                #"car": "",
                #"default": ["", "", ""]
            #},
            #"on-click": "pavucontrol"
        #},
        #"custom/media": {
            #"format": "{icon} {}",
            #"return-type": "json",
            #"max-length": 40,
            #"format-icons": {
                #"spotify": "",
                #"default": "🎜"
            #},
            #"escape": true,
            #"exec": "${pkgs.python3Packages.python}/bin/python ${variables.homeDir}/.config/waybar/mediaplayer.py 2> /dev/null" // Script in resources folder
            #// "exec": "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" // Filter player based on name
        #},
        #"disk": {
            #"interval": 30,
            #"format": "{free} {path}",
            #"path": "/"
        #}
    #}
  #'';
} {
  target = "${variables.homeDir}/.config/waybar/style.css";
  source = pkgs.writeText "style.css" ''
    * {
        border: none;
        border-radius: 0;
        /* `otf-font-awesome` is required to be installed for icons */
        font-family: ${variables.font_propo.family}, Helvetica, sans-serif;
        font-size: 13px;
        font-weight: bold;
        min-height: 0;
    }

    window#waybar {
        background-color: rgba(59, 60, 53, 0.9);
        border-bottom: 3px solid rgba(100, 114, 125, 0.5);
        color: #ffffff;
    }

    window#waybar.hidden {
        opacity: 0.2;
    }

    /*
    window#waybar.empty {
        background-color: transparent;
    }
    window#waybar.solo {
        background-color: #FFFFFF;
    }
    */

    window#waybar.termite {
        background-color: #3F3F3F;
    }

    window#waybar.chromium {
        background-color: #000000;
        border: none;
    }

    #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ffffff;
        border-bottom: 3px solid transparent;
    }

    /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
    #workspaces button:hover {
        background: rgba(0, 0, 0, 0.2);
        box-shadow: inherit;
        border-bottom: 3px solid #ffffff;
    }

    #workspaces button.focused {
        background-color: #64727D;
        border-bottom: 3px solid #ffffff;
    }

    #workspaces button.urgent {
        background-color: #eb4d4b;
    }

    #mode {
        background-color: #64727D;
        border-bottom: 3px solid #ffffff;
    }

    #clock,
    #battery,
    #cpu,
    #memory,
    #disk,
    #temperature,
    #backlight,
    #network,
    #pulseaudio,
    #custom-media,
    #tray,
    #mode,
    #idle_inhibitor,
    #mpd {
        padding: 0 10px;
        margin: 0 4px;
        color: #a6e12d;

        background-color: #3b3c35;
    }

    #battery.charging {
        color: #ffffff;
        background-color: #26A65B;
    }

    @keyframes blink {
        to {
            background-color: #ffffff;
            color: #000000;
        }
    }

    #battery.critical:not(.charging) {
        background-color: #f53c3c;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
    }

    label:focus {
        background-color: #000000;
    }

    #network.disconnected {
        background-color: #f53c3c;
    }

    #pulseaudio.muted {
        background-color: #90b1b1;
        color: #2a5c45;
    }

    #custom-media {
        background-color: #66cc99;
        color: #2a5c45;
        min-width: 100px;
    }

    #custom-media.custom-spotify {
        background-color: #66cc99;
    }

    #custom-media.custom-vlc {
        background-color: #ffa000;
    }

    #temperature.critical {
        background-color: #eb4d4b;
    }

    #idle_inhibitor.activated {
        background-color: #ecf0f1;
        color: #2d3436;
    }

    #mpd.disconnected {
        background-color: #f53c3c;
    }

    #mpd.stopped {
        background-color: #90b1b1;
    }

    #mpd.paused {
        background-color: #51a37a;
    }
  '';
} {
  target = "${variables.homeDir}/.config/waybar/mediaplayer.py";
  source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Alexays/Waybar/master/resources/custom_modules/mediaplayer.py";
    sha256 = "19ghdiwy14qnr7cj28xxrlq3s230i2s16s6qnqgpfgc2c1cach68";
  };
}]
