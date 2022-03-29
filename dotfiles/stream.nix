{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/stream-to";
  source = pkgs.writeScript "stream-to.sh" ''
    #!${pkgs.stdenv.shell}
    set -e

    export PATH="${lib.makeBinPath [ pkgs.ffmpeg pkgs.youtube-dl pkgs.gnugrep pkgs.gawk ]}:$PATH"

    VBR="5000k"
    FPS="30"
    QUAL="medium"

    while getopts u:f:o: flag
    do
        case "$flag" in
            u) SOURCE=$(youtube-dl -f $(youtube-dl -F "$OPTARG" | grep -v '[audio|video]\ only' | awk '($4+0) <= 1080 {format=$1} END {printf format}') -g "$OPTARG");;
            f) SOURCE=$OPTARG;;
            o) URL=$OPTARG;;
        esac
    done

    ffmpeg \
      -re -vsync 1 -i "$SOURCE" \
      -c:v libx264 -preset $QUAL -r $FPS -b:v $VBR \
      -vf "format=yuv420p" -g $(($FPS * 2)) -c:a aac -b:a 128k -ar 44100 \
      -f flv "$URL"

  '';
}
