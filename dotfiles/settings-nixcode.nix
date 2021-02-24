{ pkgs, lib ? pkgs.lib }:
let
  fvim = pkgs.callPackage ../nixes/fvim.nix { };

  variables = rec {
    prefix = "/home/matejc/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/matejc";
    locale.all = "en_US.UTF-8";
    monitors = [
      { name = "eDP-1"; mode = "1920x1080"; }
    ];
    soundCard = "0";
    ethernetInterfaces = [ "enp0s31f6" ];
    wirelessInterfaces = [ "wlp0s20f3" ];
    mounts = [ "/" ];
    temperatureFiles = [ "/sys/devices/virtual/thermal/thermal_zone2/temp" ];
    batteries = [ "0" ];
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "matej.cotman@eficode.com";
    font = {
      family = "FiraMono Nerd Font";
      style = "Regular";
      size = "10";
    };
    wallpaper = "${variables.homeDir}/Pictures/arch-bridge.jpg";
    lockImage = "${variables.homeDir}/Pictures/arch-bridge-blur.png";
    inherit startScript;
    inherit restartScript;
    timeFormat = "%a %d %b %Y %H:%M:%S";
    backlightSysDir = "/sys/class/backlight/intel_backlight";
    terminal = programs.terminal;
    dropDownTerminal = programs.dropdown;
    #dropDownTerminal = "${pkgs.xfce.terminal}/bin/xfce-terminal --drop-down";
    i3-msg = "/run/current-system/sw/bin/swaymsg";
    i3BarEnable = false;
    sway = {
      enable = false;
      disabledInputs = [ "2:14:ETPS/2_Elantech_Touchpad" ];
      trackpoint = {
        identifier = "2:14:ETPS/2_Elantech_TrackPoint";
        accel = "-0.3";
      };
    };
    lockscreen = "${homeDir}/bin/lockscreen";
    term = null;
    rofi.theme = "${homeDir}/.config/rofi/themes/material";
    programs = {
      filemanager = "${pkgs.dolphin}/bin/dolphin";
      nm-applet = "${pkgs.networkmanagerapplet}/bin/nm-applet";
      cmst = "${pkgs.cmst}/bin/cmst --minimized";
      #terminal = "${pkgs.xfce.terminal}/bin/xfce4-terminal";
      terminal = "${pkgs.konsole}/bin/konsole";
      dropdown = if sway.enable then "${homeDir}/bin/terminal-dropdown" else "${pkgs.tdrop}/bin/tdrop -ma -w 98% -x 1% -h 90% terminal";
      #dropdown = if sway.enable then "${homeDir}/bin/terminal-dropdown" else "${pkgs.xfce.terminal}/bin/xfce4-terminal --drop-down";
      browser = "${pkgs.chromium}/bin/chromium";
      ff = "${pkgs.firefox}/bin/firefox";
      l = "${pkgs.exa}/bin/exa -gal --git";
      a = "${pkgs.atom}/bin/atom";
      code = "${pkgs.vscodium}/bin/codium";
      s = "${pkgs.sublime3}/bin/sublime3 --new-window";
      slack = "${pkgs.slack}/bin/slack";
      mykeepassxc = "${pkgs.keepassx-community}/bin/keepassxc ${homeDir}/.secure/p.kdbx";
      myweechat = "${pkgs.konsole}/bin/konsole -e ${pkgs.mosh}/bin/mosh weechat@fornax -- attach-weechat";
      editor = "${pkgs.nano}/bin/nano";
    };
    polybar.bars = [ "my" ];
    vims.f = "${fvim}/bin/fvim --nvim ${variables.homeDir}/bin/nvim";
    vims.q = "${pkgs.neovim-qt}/bin/nvim-qt --nvim ${variables.homeDir}/bin/nvim";
  };

  dotFilePaths = [
    ./i3config.nix
    ./i3status.nix
    ./gitconfig.nix
    ./gitignore.nix
    ./autolock.nix
    ./i3lock-wrapper.nix
    #./lockscreen.nix
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
    #./polybar.nix
    ./i3_workspace.nix
    ./rofi.nix
    ./rofi-themes.nix
    ./xresources.nix
    ./mount.nix
    ./screenshooter.nix
    ./xfce-terminal-dropdown.nix
    ./waybar.nix
    ./launcher.nix
    ./wofi.nix
    ./bemenu.nix
    ./kitty.nix
    ./mako.nix
    ./screenshot.nix
    ./bash.nix
    ./starship.nix
    ./keepassxc-browser.nix
  ];

#  export PATH="${pkgs.polybar.override { i3Support = true; pulseSupport = true; }}/bin:$PATH"
#  ${pkgs.procps}/bin/pkill polybar
#  ${pkgs.lib.concatMapStringsSep "\n" (bar: ''polybar ${bar} &'') variables.polybar.bars}

  restartScript = pkgs.writeScript "restart-script.sh" ''
    #!${pkgs.stdenv.shell}

    ${pkgs.procps}/bin/pkill dunst
    ${pkgs.dunst}/bin/dunst &

    ${pkgs.feh}/bin/feh --bg-fill ${variables.wallpaper}

    ${pkgs.xorg.xrdb}/bin/xrdb -load ${variables.homeDir}/.Xresources

    systemctl --user restart picom &

    echo "DONE"
  '';

  startScript = pkgs.writeScript "start-script.sh" ''
    #!${pkgs.stdenv.shell}

    ${variables.programs.mykeepassxc} &
    ${variables.programs.browser} &
    ${variables.programs.slack} &
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
