{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/protonge-update";
  source = pkgs.writeShellScript "protonge-update.sh" ''
    set -euo pipefail

    release="$1"

    if [ -z "$release" ]
    then
      echo "Usage: $0 <release>" >&2
      exit 1
    fi

    if [ -d "$HOME/.steam/steam/compatibilitytools.d/$release" ]
    then
      echo "Release already exist: '$HOME/.steam/steam/compatibilitytools.d/$release'" >&2
      exit 0
    fi

    # make temp working directory
    echo "Creating temporary working directory..."
    rm -rf /tmp/proton-ge-custom
    mkdir /tmp/proton-ge-custom
    cd /tmp/proton-ge-custom

    # download tarball
    echo "Fetching tarball URL..."
    tarball_url=$(curl -s "https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/$release" | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
    tarball_name=$(basename $tarball_url)
    echo "Downloading tarball: $tarball_name..."
    curl -# -L $tarball_url -o $tarball_name 2>&1

    # download checksum
    echo "Fetching checksum URL..."
    checksum_url=$(curl -s "https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/$release" | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
    checksum_name=$(basename $checksum_url)
    echo "Downloading checksum: $checksum_name..."
    curl -# -L $checksum_url -o $checksum_name 2>&1

    # check tarball with checksum
    echo "Verifying tarball $tarball_name with checksum $checksum_name..."
    sha512sum -c $checksum_name
    # if result is ok, continue

    # make steam directory if it does not exist
    echo "Creating Steam directory if it does not exist..."
    mkdir -p ~/.steam/steam/compatibilitytools.d
    mkdir -p ~/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d

    # extract proton tarball to steam directory
    echo "Extracting $tarball_name to Steam directory..."
    tar -xf $tarball_name -C ~/.steam/steam/compatibilitytools.d/
    tar -xf $tarball_name -C ~/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d/

    echo "All done :)"
  '';
} {
  target = "${variables.homeDir}/.steam/steam/compatibilitytools.d/SteamTinkerLaunch/steamtinkerlaunch";
  source = "${pkgs.steamtinkerlaunch}/bin/steamtinkerlaunch";
} {
  target = "${variables.homeDir}/.steam/steam/compatibilitytools.d/SteamTinkerLaunch/compatibilitytool.vdf";
  source = pkgs.writeText "compatibilitytool.vdf" ''
  "compatibilitytools"
  {
    "compat_tools"
    {
      "Proton-stl" // Internal name of this tool
      {
        // Can register this tool with Steam in two ways:
        //
        // - The tool can be placed as a subdirectory in compatibilitytools.d, in which case this
        //   should be '.'
        //
        // - This manifest can be placed directly in compatibilitytools.d, in which case this should
        //   be the relative or absolute path to the tool's dist directory.
        "install_path" "."

        // For this template, we're going to substitute the display_name key in here, e.g.:
        "display_name" "Steam Tinker Launch"

        "from_oslist"  "windows"
        "to_oslist"    "linux"
      }
    }
  }
  '';
} {
  target = "${variables.homeDir}/.steam/steam/compatibilitytools.d/SteamTinkerLaunch/toolmanifest.vdf";
  source = pkgs.writeText "toolmanifest.vdf" ''
  "manifest"
  {
    "commandline" "/steamtinkerlaunch run"
    "commandline_waitforexitandrun" "/steamtinkerlaunch waitforexitandrun"
  }
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
} {
  target = "${variables.homeDir}/bin/steam-tui";
  source = pkgs.writeShellScript "steam-tui" ''
    export STEAM_TUI_SCRIPT_DIR="$HOME/.config/steam-tui/scripts"
    export STEAM_APP_DIR="${variables.steam.library}/steamapps/common"
    mkdir -p "$HOME/.cache/steam-tui"
    mkdir -p "$HOME/.config/steam-tui/scripts"
    exec ${pkgs.steam-tui}/bin/steam-tui "$@" 2>"$HOME/.cache/steam-tui/log"
  '';
}] ++ (lib.mapAttrsToList (app_id: v: {
  target = "${variables.homeDir}/.config/steam-tui/scripts/${app_id}.sh";
  source = pkgs.writeShellScript "${app_id}.sh" (if v ? compatibilityTool && v.compatibilityTool == "SteamTinkerLaunch" then ''
    exec ${pkgs.steam-run}/bin/steam-run env DISPLAY=:0 "${pkgs.steamtinkerlaunch}/bin/steamtinkerlaunch" settings ${app_id}
  '' else if v ? compatibilityTool && lib.hasPrefix "GE-Proton" v.compatibilityTool then ''
    ${variables.homeDir}/bin/protonge-update "${v.compatibilityTool}"
    mkdir -p "$HOME/.steam/steam/steamapps/compatdata/${app_id}"
    exec ${pkgs.steam-run}/bin/steam-run env DISPLAY=:0 STEAM_COMPAT_DATA_PATH="$HOME/.steam/steam/steamapps/compatdata/${app_id}" STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam" "$HOME/.steam/steam/compatibilitytools.d/${v.compatibilityTool}/proton" waitforexitandrun "$@"
  '' else builtins.throw "Steam: AppID(${app_id}) has invalid compatibility tool: ${if v ? compatibilityTool then v.compatibilityTool else "empty"}");
}) (variables.steam.run or {}))
