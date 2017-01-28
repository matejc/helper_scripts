{ pkgs }:
let
  variables = {
    prefix = "/home/matejc/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/matejc";
    monitorPrimary = "eDP1";
    monitorTwo = "VGA1";
    monitorThree = "DP1";
    soundCard = "0";
    ethernetInterfaces = [ "enp0s25" "tun0" ];
    wirelessInterfaces = [ "wlp3s0" ];
    mounts = [ "/" "/home" ];
    temperatureFiles = [ "${variables.homeDir}/.temp1_input" ];
    batteries = [ "0" "1" ];
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "cotman.matej@gmail.com";
    editor = "nano";
    font = "pango:Cantarell 12";
    wallpaper = "${variables.homeDir}/Pictures/27058-Overflowed.jpg";
    lockImage = "${variables.homeDir}/Pictures/bl1920_nixos_1.png";
    inherit startScript;
    timeFormat = "%a %d %b %Y %H:%M:%S";
  };

  dotFilePaths = [
    ./i3config.nix
    ./i3status.nix
    ./gitconfig.nix
    ./gitignore.nix
    ./autolock.nix
    ./i3lock-wrapper.nix
    ./lockscreen.nix
    ./thissession.nix
    ./atom_ctags.nix
    ./atom_ctags-symbols.nix
    ./oath.nix
    ./i3minators.nix
    ./git-annex-helpers.nix
    ./blackscreen.nix
    ./httpserver.nix
    ./wcontrol.nix
    ./batstatus.nix
  ];

  startScript = pkgs.writeScript "start-script.sh" ''
    #!${pkgs.stdenv.shell}
    xinput_custom_script.sh

    TEMPFILE="${variables.homeDir}/.temp1_input"
    rm $TEMPFILE
    if [ -f "/sys/devices/virtual/hwmon/hwmon0/temp1_input" ]; then
      ln -s /sys/devices/virtual/hwmon/hwmon0/temp1_input $TEMPFILE
    else
      ln -s /sys/devices/virtual/hwmon/hwmon1/temp1_input $TEMPFILE
    fi

    sleep 1
    ${pkgs.i3minator}/bin/i3minator start w1
    sleep 1
    ${pkgs.i3minator}/bin/i3minator start w3
    sleep 1
    ${pkgs.i3minator}/bin/i3minator start w4
    ${variables.homeDir}/bin/autolock &
    echo "DONE"
  '';

  activationScript = ''
    mkdir -p ${variables.homeDir}/.nixpkgs
    ln -fs ${variables.nixpkgsConfig} ${variables.homeDir}/.nixpkgs/config.nix

    mkdir -p ${variables.homeDir}/.themes
    ln -fs /run/current-system/sw/share/themes/* ${variables.homeDir}/.themes/

    mkdir -p ${variables.homeDir}/bin
    ln -fs ${variables.binDir}/* ${variables.homeDir}/bin/
    ln -fs ${variables.startScript} ${variables.homeDir}/bin/start-script.sh

    if [ -f "${variables.homeDir}/.atom/packages/atom-beautify/src/beautifiers/yapf.coffee" ]; then
      ${pkgs.gnused}/bin/sed -i -e's|@run(".*yapf"|@run("${pkgs.python3Packages.yapf}/bin/yapf"|' "${variables.homeDir}/.atom/packages/atom-beautify/src/beautifiers/yapf.coffee"
      ${pkgs.gnused}/bin/sed -i -e's|@run(".*isort"|@run("${pkgs.python3Packages.isort}/bin/isort"|' "${variables.homeDir}/.atom/packages/atom-beautify/src/beautifiers/yapf.coffee"
    fi
    if [ -f "${variables.homeDir}/.atom/packages/atom-beautify/src/beautifiers/autopep8.coffee" ]; then
      ${pkgs.gnused}/bin/sed -i -e's|@run(".*autopep8"|@run("${pkgs.python3Packages.autopep8}/bin/autopep8"|' "${variables.homeDir}/.atom/packages/atom-beautify/src/beautifiers/autopep8.coffee"
      ${pkgs.gnused}/bin/sed -i -e's|@run(".*isort"|@run("${pkgs.python3Packages.isort}/bin/isort"|' "${variables.homeDir}/.atom/packages/atom-beautify/src/beautifiers/autopep8.coffee"
    fi
  '';
in {
  inherit variables dotFilePaths activationScript;
}
