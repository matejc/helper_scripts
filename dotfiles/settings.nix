{ pkgs }:
let
  variables = rec {
    prefix = "/home/matejc/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/matejc";
    monitorPrimary = "eDP1";
    monitorTwo = "DP2";
    monitorThree = "DP2";
    soundCard = "0";
    ethernetInterfaces = [ "enp0s25" "tun0" ];
    wirelessInterfaces = [ "wlp3s0" ];
    mounts = [ "/" "/home" ];
    temperatureFiles = [ "${variables.homeDir}/.temp1_input" ];
    batteries = [ "0" "1" ];
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "cotman.matej@gmail.com";
    editor = "${pkgs.nano}/bin/nano";
    font = "Cantarell 12";
    wallpaper = "${variables.homeDir}/Pictures/pexels-photo-207985.jpeg";
    lockImage = "${variables.homeDir}/Pictures/pexels-photo-414331_1_1_blur.jpg";
    inherit startScript;
    inherit restartScript;
    timeFormat = "%a %d %b %Y %H:%M:%S";
    backlightSysDir = "/sys/class/backlight/intel_backlight";
    terminal = "${pkgs.alacritty}/bin/alacritty";
    dropDownTerminal = "${pkgs.xfce.terminal}/bin/xfce4-terminal --drop-down";
    browser = "${pkgs.firefox-beta-bin}/bin/firefox";
    i3minator = {
      chat = {
        workspace = "1";
        command = "${pkgs.rambox}/bin/rambox";
        timeout = "3";
      };
      chat2 = {
        workspace = "1";
        command = "pidgin";
        timeout = "1";
      };
      console = {
        workspace = "2";
        command = terminal;
        timeout = "1";
      };
      editor = {
        workspace = "3";
        command = "sublime3";
        timeout = "2";
      };
      browser = {
        workspace = "4";
        command = browser;
        timeout = "2";
      };
    };
    polybar.bars = [ "my" ];
  };

  dotFilePaths = [
    ./i3config.nix
    # ./i3status.nix
    ./gitconfig.nix
    ./gitignore.nix
    ./autolock.nix
    ./i3lock-wrapper.nix
    ./lockscreen.nix
    ./thissession.nix
    # ./atom_ctags.nix
    # ./atom_ctags-symbols.nix
    ./oath.nix
    ./i3minators.nix
    ./git-annex-helpers.nix
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
    # ./atom.nix
    ./jstools.nix
    ./tray.nix
    ./zsh.nix
    ./xfce4-terminal.nix
    ./monitor.nix
    ./polybar.nix
  ];

  restartScript = pkgs.writeScript "restart-script.sh" ''
    #!${pkgs.stdenv.shell}

    export PATH="${pkgs.polybar.override { i3Support = true; }}/bin:$PATH"

    ${pkgs.procps}/bin/pkill polybar
    ${pkgs.lib.concatMapStringsSep "\n" (bar: ''polybar ${bar} &'') variables.polybar.bars}

    ${pkgs.procps}/bin/pkill dunst
    ${pkgs.dunst}/bin/dunst &

    ${pkgs.feh}/bin/feh --bg-fill ${variables.wallpaper}

    echo "DONE"
  '';

  startScript = pkgs.writeScript "start-script.sh" ''
    #!${pkgs.stdenv.shell}
    xinput_custom_script.sh
    ${variables.homeDir}/bin/temp-init
    ${variables.homeDir}/bin/autolock &
    ${pkgs.sparkleshare}/bin/sparkleshare &

    ${pkgs.i3minator}/bin/i3minator start chat
    ${pkgs.i3minator}/bin/i3minator start chat2
    ${pkgs.i3minator}/bin/i3minator start console
    ${pkgs.i3minator}/bin/i3minator start editor
    ${pkgs.i3minator}/bin/i3minator start browser

    echo "DONE"
  '';

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
