{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/cast-yt";
  source = pkgs.writeScript "cast-youtube-dl.sh" ''
    #!${pkgs.stdenv.shell}
    function exitcast {
        ${variables.homeDir}/bin/nodeenv castnow $CASTARGS --quiet --exit --command s
    }
    trap "exitcast" EXIT
    ${pkgs.youtube-dl}/bin/youtube-dl -o - -- "$1" | ${variables.homeDir}/bin/nodeenv castnow --quiet ''${@:2} -
  '';
} {
  target = "${variables.homeDir}/bin/cast-yt-pl";
  source = pkgs.writeScript "cast-youtube-dl-playlist.sh" ''
    #!${pkgs.stdenv.shell}

    set -e

    SORTARG="$1"
    URLARG="$2"
    CASTARGS="''${@:3}"

    function exitcast {
        ${variables.homeDir}/bin/nodeenv castnow $CASTARGS --quiet --exit --command s
    }
    trap "exitcast" EXIT

    if [ -z "''${SORTARG//[0-9]}" ] && [ -n "$SORTARG" ]
    then
        index="$SORTARG"
    elif [ "''${SORTARG}" == "shuffle" ]
    then
        index="0"
        ytdlargs="--playlist-random"
    else
        echo "Usage: $0 <N|shuffle> <url> [castnow args]" >&2
        exit 1
    fi

    mapfile -t urls_array < <(${pkgs.youtube-dl}/bin/youtube-dl --flat-playlist --print-json $ytdlargs "$URLARG" | ${pkgs.jq}/bin/jq -r '.url')
    length="''${#urls_array[@]}"

    echo "[starting] playlist of $length entries, from $index"

    for i in $(${pkgs.coreutils}/bin/seq $index $length)
    do
        url="https://www.youtube.com/watch?v=''${urls_array[$i]}"
        echo "[start][$i] $url ..."
        ${pkgs.youtube-dl}/bin/youtube-dl -o - -- "$url" | ${variables.homeDir}/bin/nodeenv castnow --quiet $CASTARGS -
        echo "[stop][$i] $url"
    done
  '';
} {
  target = "${variables.homeDir}/bin/cast-desktop";
  source = pkgs.writeScript "cast-desktop.sh" ''
    #!${pkgs.stdenv.shell}
    SCREEN_DIMEN="$(${pkgs.xorg.xdpyinfo}/bin/xdpyinfo | ${pkgs.gawk}/bin/awk '/dimensions:/{printf $2}')"
    ${pkgs.ffmpeg}/bin/ffmpeg -video_size $SCREEN_DIMEN -framerate 10 -f x11grab -i :0.0+0,0 -f matroska - | ${variables.homeDir}/bin/nodeenv castnow --quiet ''${@:2} -
  '';
}]
