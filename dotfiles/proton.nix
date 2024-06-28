{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/protonge-update";
  source = pkgs.writeShellScript "protonge-update.sh" ''
    set -euo pipefail

    # make temp working directory
    echo "Creating temporary working directory..."
    rm -rf /tmp/proton-ge-custom
    mkdir /tmp/proton-ge-custom
    cd /tmp/proton-ge-custom

    # download tarball
    echo "Fetching tarball URL..."
    tarball_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
    tarball_name=$(basename $tarball_url)
    echo "Downloading tarball: $tarball_name..."
    curl -# -L $tarball_url -o $tarball_name 2>&1

    # download checksum
    echo "Fetching checksum URL..."
    checksum_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
    checksum_name=$(basename $checksum_url)
    echo "Downloading checksum: $checksum_name..."
    curl -# -L $checksum_url -o $checksum_name 2>&1

    # check tarball with checksum
    echo "Verifying tarball $tarball_name with checksum $checksum_name..."
    sha512sum -c $checksum_name
    # if result is ok, continue

    # make steam directory if it does not exist
    echo "Creating Steam directory if it does not exist..."
    mkdir -p ~/.steam/root/compatibilitytools.d
    mkdir -p ~/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d

    # extract proton tarball to steam directory
    echo "Extracting $tarball_name to Steam directory..."
    tar -xf $tarball_name -C ~/.steam/root/compatibilitytools.d/
    tar -xf $tarball_name -C ~/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d/

    echo "All done :)"
  '';
} {
  target = "${variables.homeDir}/bin/wine-exec";
  source = pkgs.writeShellScript "wine-exec.sh" ''
    set -e
    args="$@"
    argn="$#"

    function usage() {
      echo "Usage: $0 <init|run> <<prefix> [cmd]|cmd>" >&2
      return 1
    }

    function check_args() {
      if [ $argn -ge $1 ]
      then
        for a in $args
        do
          if [ -z "$a" ]
          then
            usage
          fi
        done
      else
        usage
      fi
    }

    check_args 2
    action="$1"

    export SDL_VIDEODRIVER=x11

    export WINE="${pkgs.wineWowPackages.stableFull}/bin/wine"
    export WINEPREFIX="$2"
    export WINEARCH=win64

    if [[ "$action" = "init" ]]
    then
      mkdir -p "$WINEPREFIX"
      "$WINE" wineboot
    elif [[ "$action" = "run" ]]
    then
      check_args 3
      "$WINE" "''${@:3}"
    elif [[ "$action" = "winetricks" ]]
    then
      ${pkgs.winetricks}/bin/winetricks "''${@:3}"
    else
      usage
    fi
  '';
} {
  target = "${variables.homeDir}/bin/proton-exec";
  source = pkgs.writeShellScript "proton-exec.sh" ''
    set -e
    args="$@"
    argn="$#"

    function usage() {
      echo "Usage: $0 <app_id> <run> <<prefix> [cmd]|cmd>" >&2
      return 1
    }

    function check_args() {
      if [ $argn -ge $1 ]
      then
        for a in $args
        do
          if [ -z "$a" ]
          then
            usage
          fi
        done
      else
        usage
      fi
    }

    check_args 3
    app_id="$1"
    action="$2"

    export SDL_VIDEODRIVER=x11

    if [[ "$action" = "launch" ]]
    then
      protontricks-launch --appid "$app_id" "''${@:3}"
    elif [[ "$action" = "run" ]]
    then
      protontricks -c "''${@:3}" "$app_id"
    elif [[ "$action" = "protontricks" ]]
    then
      ${pkgs.protontricks}/bin/protontricks "''${@:3}"
    elif [[ "$action" = "winetricks" ]]
    then
      ${pkgs.winetricks}/bin/winetricks "''${@:3}"
    else
      usage
    fi
  '';
}]
