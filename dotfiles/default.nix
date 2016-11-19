{ config, pkgs, lib, ... }:
let
  variables = {
    prefix = "/home/matejc/workarea/helper_scripts";
    nixpkgsConfig = "${variables.prefix}/dotfiles/nixpkgs-config.nix";
    user = "matejc";
    homeDir = "/home/matejc";
    monitorPrimary = "HDMI-0";
    monitorTwo = "DVI-I-0";
    monitorThree = "DVI-I-1";
    soundCard = "0";
    ethernetInterfaces = ["enp3s0" "vpn0"];
    wirelessInterfaces = ["wlp3s0"];
    mounts = [ "/" ];
    temperatureFiles = [ "${variables.homeDir}/.temp1_input" ];
    batteries = [ ];
    binDir = "${variables.prefix}/bin";
    fullName = "Matej Cotman";
    email = "cotman.matej@gmail.com";
    editor = "nano";
    font = "pango:Cantarell 10";
    wallpaper = "${variables.homeDir}/Pictures/3.jpg";
    lockImage = "/etc/nixos/nixos.png";
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

  extra = ''
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


  dotFileFun = nixFilePath:
    let
      nixes = lib.toList (import nixFilePath { inherit variables config pkgs lib; });
    in map (nix: {
      source = nix.source;
      target = nix.target;
    }) nixes;
  dotAttrs = lib.flatten (map dotFileFun dotFilePaths);
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
