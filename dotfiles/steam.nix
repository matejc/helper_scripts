{ variables, pkgs, lib, ... }:
let
  steam-xrun = pkgs.writeShellScriptBin "steam-xrun" ''
    export PATH="$PATH:${lib.makeBinPath [ pkgs.openbox pkgs.xsel pkgs.xwayland-run pkgs.steam ]}"
    export DISPLAY=:10
    trap 'kill $(jobs -p)' EXIT
    xwayland-run $DISPLAY -ac -- openbox --startup "bash -c '${lib.concatStringsSep " & " (["wl-paste -n --watch xsel -bi"] ++ variables.steam.xrun)} & steam; openbox --exit'"
  '';
  steamtinkerlaunch = pkgs.writeShellScriptBin "steamtinkerlaunch" ''
    unset WAYLAND_DISPLAY
    exec ${pkgs.steamtinkerlaunch}/bin/steamtinkerlaunch "$@"
  '';
in
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

    case "$release" in
        "latest")
            ;;
        *)
            release="tags/$release"
            ;;
    esac

    # Make a temporary working directory
    echo "Making sure temporary directory exists..."
    mkdir -p /tmp/proton-ge-custom
    cd /tmp/proton-ge-custom

    steam_dir=~/.steam/steam

    # Verify Steam data directory exists
    if [[ ! -d "$steam_dir" ]]; then
        echo "Error: Steam (native) data directory not found." >&2
        echo "Please launch Steam at least once to populate it." >&2
        exit 1
    fi

    # Make a Steam compatibility tools folder if it does not exist
    mkdir -p "$steam_dir/compatibilitytools.d"

    # Fetch release info
    echo "Fetching release info..."
    release_json=$(curl -s --max-time 10 \
        https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/$release)

    if [[ -z "$release_json" || "$release_json" != *'"tag_name"'* ]]; then
        echo "Error: Failed to fetch release info from GitHub." >&2
        exit 1
    fi

    # Resolve release URL for current architecture
    echo "Fetching release for your arch..."

    case "$(uname -m)" in
        aarch64|arm64) tarball_pattern='\-aarch64\.tar\.gz$' ;;
        x86_64)        tarball_pattern='GE-Proton[0-9]+-[0-9]+\.tar\.gz$' ;;
        *)
            echo "Error: Unsupported architecture: $(uname -m)." >&2
            echo "GE-Proton is only available for x86_64 and aarch64." >&2
            exit 1
            ;;
    esac

    tarball_url=$(echo "$release_json" |
        grep browser_download_url |
        cut -d\" -f4 |
        grep -E "$tarball_pattern" |
        head -n1 || true)

    tarball_name=$(basename "$tarball_url")
    release_name=''${tarball_name%.tar.gz}

    if [[ -z "$tarball_url" ]]; then
        echo "Error: Could not find a matching release for your arch ($(uname -m))." >&2
        exit 1
    fi

    # Skip if already installed
    if [[ -d "$steam_dir/compatibilitytools.d/$release_name" ]]; then
        echo "$release release $release_name is already installed."
        exit 0
    fi

    # Resolve checksum URL
    checksum_url=$(echo "$release_json" |
        grep browser_download_url |
        cut -d\" -f4 |
        grep "$release_name.sha512sum$" || true)

    if [[ -z "$checksum_url" ]]; then
        echo "Error: Could not find a checksum for $tarball_name in the release." >&2
        exit 1
    fi

    # Use cached tarball from tmp if valid, resume if incomplete
    if [[ -f "$tarball_name" ]]; then
        echo "Found cached release: $release_name"
        echo "Verifying download..."

        if curl -sL "$checksum_url" | sha512sum -c - &>/dev/null; then
            echo "Cached release OK, skipping download."
        else
            echo "Cached release is incomplete, resuming download..."
            curl -C - -L "$tarball_url" -o "$tarball_name" --progress-bar
            echo "Verifying download..."

            if ! curl -sL "$checksum_url" | sha512sum -c - &>/dev/null; then
                echo "Resumed download corrupt, falling back to fresh download..."
                rm -f "$tarball_name"
                curl -L "$tarball_url" -o "$tarball_name" --progress-bar
                echo "Verifying download..."

                if ! curl -sL "$checksum_url" | sha512sum -c -; then
                    echo "Error: Verification failed! The downloaded release may be corrupt." >&2
                    exit 1
                fi
            fi
        fi

    # Nuke the temporary working directory and download the tarball
    else
        echo "Cleaning temporary directory..."
        rm -rf /tmp/proton-ge-custom
        mkdir /tmp/proton-ge-custom
        cd /tmp/proton-ge-custom
        echo "Downloading release: $release_name..."
        curl -L "$tarball_url" -o "$tarball_name" --progress-bar
        echo "Verifying download..."

        if ! curl -sL "$checksum_url" | sha512sum -c -; then
            echo "Error: Verification failed! The downloaded release may be corrupt." >&2
            exit 1
        fi
    fi

    # Extract the GE-Proton tarball to the Steam compatibility tools folder
    echo "Extracting $tarball_name to the Steam compatibility tools folder..."
    tar -xf "$tarball_name" -C "$steam_dir/compatibilitytools.d/" \
        || { echo "Error: Extraction failed!" >&2; exit 1; }

    echo "Done :)"
  '';
} {
  target = "${variables.homeDir}/bin/steam-xrun";
  source = "${steam-xrun}/bin/steam-xrun";
} {
  target = "${variables.homeDir}/.steam/steam/compatibilitytools.d/SteamTinkerLaunch/steamtinkerlaunch";
  source = "${steamtinkerlaunch}/bin/steamtinkerlaunch";
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
    "version" "2"
    "commandline" "/steamtinkerlaunch run"
    "commandline_waitforexitandrun" "/steamtinkerlaunch waitforexitandrun"
  }
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
}] ++ (lib.optionals (variables.steam?wine-exec && variables.steam.wine-exec == true) [{
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
}]) ++ (lib.optionals (variables.steam?tui && variables.steam.tui == true) ([{
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
  '' else throw "Steam: AppID(${app_id}) has invalid compatibility tool: ${if v ? compatibilityTool then v.compatibilityTool else "empty"}");
}) (variables.steam.run or {}))))
