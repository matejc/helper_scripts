{ pkgs, lib ? pkgs.lib }:
let
  xfce = pkgs.xfce4-14;
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
    batteries = [ ];
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "cotman.matej@gmail.com";
    editor = "${pkgs.nano}/bin/nano";
    font = "Source Code Pro Semibold 11";
    terminalFont = "Source Code Pro Semibold 11";
    wallpaper = "${variables.homeDir}/Pictures/blade-of-grass.jpg";
    lockImage = "${variables.homeDir}/Pictures/blade-of-grass-blur.png";
    inherit startScript;
    inherit restartScript;
    timeFormat = "%a %d %b %Y %H:%M:%S";
    backlightSysDir = "/sys/class/backlight/intel_backlight";
    terminal = programs.terminal;
    dropDownTerminal = programs.dropdown-terminal;
    # dropDownTerminal = "${homeDir}/bin/scratchterm ${pkgs.termite}/bin/termite";
    /* dropDownTerminal = "${pkgs.xfce4-13.xfce4-terminal}/bin/xfce4-terminal --drop-down"; */
    i3-msg = "/run/current-system/sw/bin/i3-msg";
    i3BarEnable = false;
    lockscreen = "${homeDir}/bin/lockscreen";
    term = null;
    browser = programs.chromium;
    rofi.theme = "${homeDir}/.config/rofi/themes/material";
    programs = {
        #alacritty = "${pkgs.alacritty}/bin/alacritty -e ${homeDir}/bin/tmux-new-session";
        screenshooter = "${xfce.xfce4-screenshooter}/bin/xfce4-screenshooter --region --save ~/Pictures";
        # screenshooter = "${pkgs.grim}/bin/grim-g \"$(slurp)\" \"~/Pictures/Screenshoot-$(date -u -Iseconds).png\"";
        nm-applet = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        cmst = "${pkgs.cmst}/bin/cmst --minimized";
        launcher = "${pkgs.rofi}/bin/rofi -show combi";
        #terminal = "${xfce.xfce4-terminal}/bin/xfce4-terminal";
        terminal = "${pkgs.alacritty}/bin/alacritty";
        dropdown-terminal = "${xfce.xfce4-terminal}/bin/xfce4-terminal --drop-down";
        # dropdown-terminal = "${homeDir}/bin/termite-dropdown";
        /* terminal = "${pkgs.termite}/bin/termite"; */
        chromium = "${pkgs.chromium}/bin/chromium";
        ff = "${pkgs.firefox-devedition-bin}/bin/firefox-devedition";
        l = "${pkgs.exa}/bin/exa -gal --git";
        a = "${pkgs.atom}/bin/atom";
        s = "${pkgs.sublime3}/bin/sublime3 --new-window";
        v = ''env PATH="${variables.homeDir}/bin:$PATH" ${pkgs.gonvim}/bin/gonvim'';
        q = "${pkgs.neovim-qt}/bin/nvim-qt --no-ext-tabline --nvim ${variables.homeDir}/bin/nvim";
        yt = "${pkgs.python3Packages.mps-youtube}/bin/mpsyt";
        mykeepassxc = "${pkgs.keepassx-community}/bin/keepassxc ${homeDir}/.secure/p.kdbx";
        minitube = "${pkgs.minitube.override { withAPIKey = variables.youTubeApiKey; }}/bin/minitube";
        viber = "${pkgs.viber}/bin/viber";
    };
    youTubeApiKey = "AIzaSyBxg89KksVhdWOA5_Srg2_5G6jS6b10mAk";
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
    ./termite.nix
    ./way-cooler.nix
    ./coc.nvim.nix
    ./konsole.nix
    ./polybar.nix
    ./i3_workspace.nix
    ./rofi.nix
    ./rofi-themes.nix
    ./xresources.nix
    ./mount.nix
  ];

  restartScript = pkgs.writeScript "restart-script.sh" ''
    #!${pkgs.stdenv.shell}

    ${variables.homeDir}/bin/xinput_custom_script.sh

    export PATH="${pkgs.polybar.override { i3Support = true; pulseSupport = true; }}/bin:$PATH"
    ${pkgs.procps}/bin/pkill polybar
    ${pkgs.lib.concatMapStringsSep "\n" (bar: ''polybar ${bar} &'') variables.polybar.bars}

    ${pkgs.procps}/bin/pkill dunst
    ${pkgs.dunst}/bin/dunst &

    ${pkgs.feh}/bin/feh --bg-fill ${variables.wallpaper}

    ${pkgs.xorg.xrdb}/bin/xrdb -load ${variables.homeDir}/.Xresources

    echo "DONE"
  '';

  startScript = pkgs.writeScript "start-script.sh" ''
    #!${pkgs.stdenv.shell}

    ${variables.homeDir}/bin/mykeepassxc &
    ${pkgs.signal-desktop}/bin/signal-desktop &
    ${pkgs.tdesktop}/bin/telegram-desktop &
    ${pkgs.rambox}/bin/rambox &
    ${pkgs.spideroak}/bin/spideroak &
    ${variables.programs.cmst} &
    ${variables.browser} &
    ${variables.programs.viber} &

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
