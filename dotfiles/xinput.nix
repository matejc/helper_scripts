{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/xinput_custom_script.sh";
  source = pkgs.writeScript "xinput_custom_script.sh" ''
    #!${pkgs.stdenv.shell}

    # To enable vertical scrolling
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
    # To enable horizontal scrolling in addition to vertical scrolling
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
    # To enable middle button emulation (using left- and right-click simultaneously)
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Middle Button Emulation" 1
    ${pkgs.xlibs.xinput}/bin/xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Middle Button Timeout" 50
  '';
}
