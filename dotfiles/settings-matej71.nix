{ pkgs, lib ? pkgs.lib }:
let
  variables = rec {
    prefix = "/home/matejc/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/matejc";
    monitors = [
      { name = "eDP1"; mode = "1920x1080"; }
      { name = "DP1"; mode = "1920x1080"; }
      { name = "HDMI1"; mode = "1920x1080"; }
    ];
    soundCard = "0";
    ethernetInterfaces = [ "enp0s25" ];
    wirelessInterfaces = [ "wlp3s0" ];
    mounts = [ "/" ];
    temperatureFiles = [ "/sys/devices/virtual/thermal/thermal_zone2/temp" ];
    batteries = [ "0" "1" ];
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "cotman.matej@gmail.com";
    editor = "${pkgs.nano}/bin/nano";
    font = {
      family = "Source Code Pro";
      extra = "Semibold";
      size = "11";
    };
    wallpaper = "${variables.homeDir}/Pictures/blade-of-grass.jpg";
    lockImage = "${variables.homeDir}/Pictures/blade-of-grass-blur.png";
    inherit startScript;
    inherit restartScript;
    timeFormat = "%a %d %b %Y %H:%M:%S";
    backlightSysDir = "/sys/class/backlight/intel_backlight";
    terminal = programs.terminal;
    dropDownTerminal = programs.dropdown;
    i3-msg = "/run/current-system/sw/bin/swaymsg";
    i3BarEnable = false;
    sway = {
      enable = true;
      disabledInputs = [ "1267:769:ELAN_Touchscreen" "1739:0:Synaptics_TM3075-002" ];
      trackpoint = {
        identifier = "2:10:TPPS/2_IBM_TrackPoint";
        accel = "-0.3";
      };
    };
    lockscreen = "${homeDir}/bin/lockscreen";
    term = null;
    browser = programs.chromium;
    rofi.theme = "${homeDir}/.config/rofi/themes/material";
    programs = {
      filemanager = "${pkgs.xfce.thunar.override { thunarPlugins = with pkgs.xfce; [ thunar-volman thunar-archive-plugin ]; }}/bin/thunar";
      cmst = "${pkgs.cmst}/bin/cmst --minimized";
      terminal = "${pkgs.xfce.terminal}/bin/xfce4-terminal";
      dropdown = if sway.enable then "${homeDir}/bin/terminal-dropdown" else "${pkgs.xfce.terminal}/bin/xfce4-terminal --drop-down";
      #dropdown = if sway.enable then "${homeDir}/bin/terminal-dropdown" else "${pkgs.tdrop}/bin/tdrop -ma --class kitty-dropdown -f '--class kitty-dropdown' terminal";
      chromium = "${pkgs.chromium}/bin/chromium";
      ff = "${pkgs.firefox}/bin/firefox";
      c = "${pkgs.vscodium}/bin/codium";
      s = "${pkgs.sublime3}/bin/sublime3 --new-window";
      mykeepassxc = "${pkgs.keepassx-community}/bin/keepassxc ${homeDir}/.secure/p.kdbx";
      spideroak = "${pkgs.spideroak}/bin/spideroak";
      nextcloud-client = "${pkgs.nextcloud-client}/bin/nextcloud";
      riot = "${pkgs.element-desktop}/bin/element-desktop";
      signal = "${pkgs.signal-desktop}/bin/signal-desktop";
      myweechat = "${pkgs.kitty}/bin/kitty --title WeeChat '${pkgs.writeScript "weechat" "${pkgs.mosh}/bin/mosh weechat@fornax -- attach-weechat"}' &";
    };
    # i3minator = {
    #   chat = {
    #     workspace = "1";
    #     command = "${pkgs.franz}/bin/franz";
    #     timeout = "0.1";
    #   };
    #   console = {
    #     workspace = "2";
    #     command = terminal;
    #     timeout = "0.3";
    #   };
    #   editor = {
    #     workspace = "3";
    #     command = "sublime3";
    #     timeout = "0.1";
    #   };
    #   browser = {
    #     workspace = "4";
    #     command = browser;
    #     timeout = "0.1";
    #   };
    #   browser2 = {
    #     workspace = "4";
    #     command = programs.mykeepassxc;
    #     timeout = "0.1";
    #   };
    # };
    polybar.bars = [ "my" ];
  };

  dotFilePaths = [
    ./i3config.nix
    ./i3status.nix
    ./gitconfig.nix
    ./gitignore.nix
    # ./autolock.nix
    ./i3lock-wrapper.nix
    ./swaylockscreen.nix
    ./thissession.nix
    # ./atom_ctags.nix
    # ./atom_ctags-symbols.nix
    ./oath.nix
    ./i3minators.nix
    # ./git-annex-helpers.nix
    ./blackscreen.nix
    ./httpserver.nix
    ./wcontrol.nix
    ./batstatus.nix
    ./alacritty.nix
    ./tmux.nix
    ./temp.nix
    ./brightness.nix
    ./xbacklight.nix
    ./volume.nix
    ./fish.nix
    ./dunst.nix
    ./yaml2nix.nix
    ./mysql-utils.nix
    ./kanban.nix
    ./atom.nix
    ./jstools.nix
    ./tray.nix
    ./zsh.nix
    ./xfce4-terminal.nix
    ./monitor.nix
    ./programs.nix
    ./any2mp3.nix
    ./sublime.nix
    ./vlc.nix
    ./xonsh.nix
    ./konsole.nix
    ./connman.nix
    ./sshproxy.nix
    ./chrome_cast_allow.nix
    ./castnow.nix
    # ./mkchromecast.nix
    ./freecad.nix
    ./bcrypt.nix
    #./termite.nix
    #./way-cooler.nix
    ./nvim.nix
    ./konsole.nix
    ./polybar.nix
    ./i3_workspace.nix
    ./rofi.nix
    ./rofi-themes.nix
    ./xresources.nix
    ./mount.nix
    ./scan.nix
    ./screenshooter.nix
    ./xfce-terminal-dropdown.nix
    ./waybar.nix
    ./launcher.nix
    ./bemenu.nix
    ./kitty.nix
    ./bash.nix
    ./starship.nix
    ./keepassxc-browser.nix
  ];

  #export PATH="${pkgs.polybar.override { i3Support = true; pulseSupport = true; }}/bin:$PATH"
  #${pkgs.procps}/bin/pkill polybar
  #${pkgs.lib.concatMapStringsSep "\n" (bar: ''polybar ${bar} &'') variables.polybar.bars}

  restartScript = pkgs.writeScript "restart-script.sh" ''
    #!${pkgs.stdenv.shell}

    #${variables.homeDir}/bin/xinput_custom_script.sh

    ${pkgs.procps}/bin/pkill dunst
    ${pkgs.dunst}/bin/dunst &

    ${pkgs.feh}/bin/feh --bg-fill ${variables.wallpaper}

    ${pkgs.xorg.xrdb}/bin/xrdb -load ${variables.homeDir}/.Xresources

    systemctl --user restart compton &

    echo "DONE"
  '';

  startScript = pkgs.writeScript "start-script.sh" ''
    #!${pkgs.stdenv.shell}

    ${variables.programs.mykeepassxc} &
    ${variables.programs.spideroak} &
    ${variables.programs.nextcloud-client} &
    ${variables.browser} &
    ${variables.programs.myweechat} &
    { sleep 2; ${variables.programs.cmst}; } &

    echo "DONE"
  '';
  # ${pkgs.xorg.xrandr}/bin/xrandr ${lib.concatImapStringsSep " " (i: v: "--output ${v.name} ${if 1 == i then (if v ? mode then "--mode ${v.mode}" else "--auto") else "--off"}") variables.monitors}
  # ${pkgs.lib.concatMapStringsSep "\n" (item: ''${pkgs.i3minator}/bin/i3minator start ${item}'') (builtins.attrNames variables.i3minator)}

  activationScript = ''
    mkdir -p ${variables.homeDir}/.nixpkgs
    ln -fs ${variables.nixpkgsConfig} ${variables.homeDir}/.nixpkgs/config.nix

    mkdir -p ${variables.homeDir}/bin
    ln -fs ${variables.binDir}/* ${variables.homeDir}/bin/
    ln -fs ${variables.startScript} ${variables.homeDir}/bin/start-script.sh
    ln -fs ${variables.restartScript} ${variables.homeDir}/bin/restart-script.sh
  '';
in {
  inherit variables dotFilePaths activationScript;
}
