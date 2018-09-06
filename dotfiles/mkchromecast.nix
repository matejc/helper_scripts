{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/mkchromecast-yt-pl";
  source = pkgs.writeScript "mkchromecast-youtube-playlist.sh" ''
    #!${pkgs.stdenv.shell}

    returnVal=()
    convertArgsStrToArray() {
        local concat=""
        local t=""
        returnVal=()

        for word in $@; do
            local len=`expr "$word" : '.*"'`

            [ "$len" -eq 1 ] && concat="true"

            if [ "$concat" ]; then
                t+=" $word"
            else
                word=''${word#\"}
                word=''${word%\"}
                returnVal+=("$word")
            fi

            if [ "$concat" -a "$len" -gt 1 ]; then
                t=''${t# }
                t=''${t#\"}
                t=''${t%\"}
                returnVal+=("$t")
                t=""
                concat=""
            fi
        done
    }

    is_playing="0"
    function interuptplay {
        if [[ "$is_playing" == "0" ]]
        then
            echo "Exiting ..."
            exit 0
        fi
    }

    set -e

    SORTARG="$1"
    URLARG="$2"

    convertArgsStrToArray "''${@:3}"
    MKCHROMECASTARGS=$returnVal

    if [ -z "''${SORTARG//[0-9]}" ] && [ -n "$SORTARG" ]
    then
        index="$SORTARG"
    elif [ "''${SORTARG}" == "shuffle" ]
    then
        index="0"
        ytdlargs="--playlist-random"
    else
        echo "Usage: $0 <N|shuffle> <url> [mkchromecast args]" >&2
        exit 1
    fi

    mapfile -t urls_array < <(${pkgs.youtubeDL}/bin/youtube-dl --flat-playlist --print-json $ytdlargs "$URLARG" | ${pkgs.jq}/bin/jq -r '.url')
    length="''${#urls_array[@]}"

    echo "[starting] playlist of $length entries, from $index"

    trap "interuptplay" INT

    set +e

    for i in $(${pkgs.coreutils}/bin/seq $index $length)
    do
        url="https://www.youtube.com/watch?v=''${urls_array[$i]}"
        is_playing="1"
        echo "[start][$i] $url ..."
        ${pkgs.mkchromecast}/bin/mkchromecast --youtube "$url" ''${MKCHROMECASTARGS[@]}
        echo "[stop][$i] $url"
        is_playing="0"
        sleep 1
    done
  '';
}]
