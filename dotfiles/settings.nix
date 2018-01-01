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
    terminal = programs.terminal;
    dropDownTerminal = "${homeDir}/bin/i3wm-dropdown";
    browser = "chromium";
    programs = {
        terminal = "${pkgs.alacritty}/bin/alacritty -e ${homeDir}/bin/tmux-new-session";
        chromium = "${pkgs.chromium}/bin/chromium";
        firefox-devedition = "${pkgs.firefox-devedition-bin}/bin/firefox-devedition";
        l = "${pkgs.exa}/bin/exa -gal --git";
        s = "${pkgs.sublime3}/bin/sublime3 --add";
        n = "${pkgs.nano}/bin/nano -wc";
    };
    i3minator = {
      chat = {
        workspace = "1";
        command = "${pkgs.franz}/bin/franz";
        timeout = "0.1";
      };
      console = {
        workspace = "2";
        command = terminal;
        timeout = "0.3";
      };
      editor = {
        workspace = "3";
        command = "sublime3";
        timeout = "0.1";
      };
      browser = {
        workspace = "4";
        command = browser;
        timeout = "0.1";
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
    ./i3_workspace.nix
    ./programs.nix
    ./any2mp3.nix
  ];

  restartScript = pkgs.writeScript "restart-script.sh" ''
    #!${pkgs.stdenv.shell}

    xinput_custom_script.sh

    export PATH="${pkgs.polybar.override { i3Support = true; }}/bin:$PATH"

    ${pkgs.procps}/bin/pkill polybar
    ${pkgs.lib.concatMapStringsSep "\n" (bar: ''polybar ${bar} &'') variables.polybar.bars}

    ${pkgs.procps}/bin/pkill dunst
    ${pkgs.dunst}/bin/dunst &

    ${pkgs.xorg.xrandr}/bin/xrandr --output ${variables.monitorOne} --off --output ${variables.monitorTwo} --off --output ${variables.monitorPrimary} --auto

    ${pkgs.feh}/bin/feh --bg-fill ${variables.wallpaper}

    echo "DONE"
  '';

  startScript = pkgs.writeScript "start-script.sh" ''
    #!${pkgs.stdenv.shell}
    ${variables.homeDir}/bin/temp-init
    ${variables.homeDir}/bin/autolock &
    ${pkgs.sparkleshare}/bin/sparkleshare &

    ${pkgs.lib.concatMapStringsSep "\n" (item: ''${pkgs.i3minator}/bin/i3minator start ${item}'') (builtins.attrNames variables.i3minator)}

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
