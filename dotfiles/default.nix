{ config, pkgs, lib, ... }:
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
    ethernetInterface = "enp0s25";
    wirelessInterface = "wlp3s0";
    vpnInterface = "vpn0";
    mounts = [ "/" "/home" ];
    temperatureFiles = [ "/tmp/temp1_input" ];
    batteries = [ "0" "1" ];
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "cotman.matej@gmail.com";
    editor = "nano";
    font = "pango:Cantarell 10";
    wallpaper = "${variables.homeDir}/Pictures/3.jpg";
    inherit startScript;
  };

  dotFilePaths = [
    ./i3config.nix
    ./i3status.nix
    ./gitconfig.nix
    ./gitignore.nix
  ];

  startScript = pkgs.writeScript "start-script.sh" ''
    #!${pkgs.stdenv.shell}
    echo start
  '';

  extra = ''
    mkdir -p ${variables.homeDir}/.nixpkgs
    ln -fs ${variables.nixpkgsConfig} ${variables.homeDir}/.nixpkgs/config.nix

    mkdir -p ${variables.homeDir}/.themes
    ln -fs /run/current-system/sw/share/themes/* ${variables.homeDir}/.themes/

    mkdir -p ${variables.homeDir}/bin
    ln -fs ${variables.binDir}/* ${variables.homeDir}/bin/
    ln -fs ${variables.startScript} ${variables.homeDir}/bin/start-script.sh

    rm /tmp/temp1_input
    if [ -f "/sys/devices/virtual/hwmon/hwmon0/temp1_input" ]; then
      ln -s /sys/devices/virtual/hwmon/hwmon0/temp1_input /tmp/temp1_input
    else
      ln -s /sys/devices/virtual/hwmon/hwmon1/temp1_input /tmp/temp1_input
    fi
  '';


  dotFileFun = nixFilePath:
    let
      nix = import nixFilePath { inherit variables config pkgs lib; };
    in {
      source = nix.source;
      target = nix.target;
    };
  dotAttrs = map dotFileFun dotFilePaths;
  dotFilesScript = pkgs.writeScript "dot-files-script.sh" ''
    #!${pkgs.stdenv.shell}

    ${lib.concatMapStringsSep "\n" (d: ''
      if [[ -L "${d.target}" ]]; then
        rm "${d.target}"
      elif [[ -f "${d.target}" ]]; then
        mv "${d.target}" "${d.target}.backup.`date --iso-8601=seconds`"
      fi
      mkdir -p "`dirname "${d.target}"`" && \
        ln -s "${d.source}" "${d.target}"
    '') dotAttrs}

    ${extra}
  '';
in {
  system.activationScripts.dotfiles = ''
    ${dotFilesScript} || true
  '';
}
