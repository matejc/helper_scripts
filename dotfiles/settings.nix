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
    mounts = [ "/" "/home" ];
    temperatureFiles = [ "${variables.homeDir}/.temp1_input" ];
    batteries = [ ];
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "cotman.matej@gmail.com";
    editor = "${pkgs.nano}/bin/nano";
    font = "Source Code Pro Semibold 11";
    terminalFont = "Source Code Pro Semibold 11";
    wallpaper = "${variables.homeDir}/Pictures/pexels-photo.jpg";
    lockImage = "${variables.homeDir}/Pictures/water-plant-green-fine-layers_blur.jpg";
    inherit startScript;
    inherit restartScript;
    timeFormat = "%a %d %b %Y %H:%M:%S";
    backlightSysDir = "/sys/class/backlight/intel_backlight";
    terminal = programs.terminal;
    dropDownTerminal = "${homeDir}/bin/scratchterm ${pkgs.termite}/bin/termite";
    /* dropDownTerminal = "${pkgs.xfce4-13.xfce4-terminal}/bin/xfce4-terminal --drop-down"; */
    i3-msg = "/run/current-system/sw/bin/i3-msg";
    i3BarEnable = false;
    lockscreen = "${homeDir}/bin/lockscreen";
    term = null;
    browser = "chromium";
    programs = {
        # terminal = "${pkgs.alacritty}/bin/alacritty -e ${homeDir}/bin/tmux-new-session";
        terminal = "${pkgs.xfce4-13.xfce4-terminal}/bin/xfce4-terminal";
        dropdown-terminal = "${pkgs.xfce4-13.xfce4-terminal}/bin/xfce4-terminal --drop-down";
        /* terminal = "${pkgs.termite}/bin/termite"; */
        chromium = "${pkgs.chromium}/bin/chromium";
        ff = "${pkgs.firefox-devedition-bin}/bin/firefox-devedition";
        l = "${pkgs.exa}/bin/exa -gal --git";
        s = "${pkgs.sublime3}/bin/sublime3";
        n = "${pkgs.ne}/bin/ne";
        yt = "${pkgs.python3Packages.mps-youtube}/bin/mpsyt";
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
    ./autolock.nix
    ./i3lock-wrapper.nix
    ./lockscreen.nix
    #./swaylockscreen.nix
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
    ./polybar.nix
    ./i3_workspace.nix
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
    ./sync.nix
    ./mkchromecast.nix
    ./freecad.nix
    ./bcrypt.nix
    ./termite.nix
    /* ./way-cooler.nix */
  ];

  restartScript = pkgs.writeScript "restart-script.sh" ''
    #!${pkgs.stdenv.shell}

    xinput_custom_script.sh

    ${pkgs.procps}/bin/pkill dunst
    ${pkgs.dunst}/bin/dunst &

    export PATH="${pkgs.polybar.override { i3Support = true; pulseSupport = true; }}/bin:$PATH"
    ${pkgs.procps}/bin/pkill polybar
    ${pkgs.lib.concatMapStringsSep "\n" (bar: ''polybar ${bar} &'') variables.polybar.bars}

    ${pkgs.feh}/bin/feh --bg-fill ${variables.wallpaper}

    echo "DONE"
  '';

  startScript = pkgs.writeScript "start-script.sh" ''
    #!${pkgs.stdenv.shell}

    # ${pkgs.xorg.xrandr}/bin/xrandr ${lib.concatImapStringsSep " " (i: v: "--output ${v.name} ${if 1 == i then (if v ? mode then "--mode ${v.mode}" else "--auto") else "--off"}") variables.monitors}

    ${variables.homeDir}/bin/temp-init
    ${variables.homeDir}/bin/mykeepassxc &
    ${pkgs.signal-desktop}/bin/signal-desktop &
    ${pkgs.tdesktop}/bin/telegram-desktop &
    ${pkgs.slack}/bin/slack &
    ${pkgs.rambox}/bin/rambox &
    ${variables.browser} &

    # ${variables.homeDir}/bin/autolock &

    echo "DONE"
  '';
    # ${variables.homeDir}/bin/autolock &
    # ${pkgs.lib.concatMapStringsSep "\n" (item: ''${pkgs.i3minator}/bin/i3minator start ${item}'') (builtins.attrNames variables.i3minator)}

  activationScript = ''
    mkdir -p ${variables.homeDir}/.nixpkgs
    ln -fs ${variables.nixpkgsConfig} ${variables.homeDir}/.nixpkgs/config.nix

    mkdir -p ${variables.homeDir}/bin
    ln -fs ${variables.binDir}/* ${variables.homeDir}/bin/
    ln -fs ${variables.startScript} ${variables.homeDir}/bin/start-script.sh
    ln -fs ${variables.restartScript} ${variables.homeDir}/bin/restart-script.sh

    rm -rf ${variables.homeDir}/.local/share/xonsh/xonsh_script_cache
  '';
in {
  inherit variables dotFilePaths activationScript;
}
