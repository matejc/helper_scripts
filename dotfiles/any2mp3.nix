{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/any2mp3";
  source = pkgs.writeScript "any2mp3.sh" ''
    #!${pkgs.stdenv.shell}

    set -e

    INPUT_FILE="$1"

    if [ -d "$2" ]
    then
      OUTPUT_FILE="$2/`basename "$INPUT_FILE"`.mp3"
      WORK_FILE="$2/`basename "$INPUT_FILE"`.work"
    else
      OUTPUT_FILE="$INPUT_FILE.mp3"
      WORK_FILE="$INPUT_FILE.work"
    fi

    if [ -f "$OUTPUT_FILE" ]
    then
      echo "Output file already exists, skipping ... ($OUTPUT_FILE)!"
      exit 0;
    fi

    echo "Start $WORK_FILE ..."
    ${pkgs.ffmpeg.bin}/bin/ffmpeg -i "$INPUT_FILE" -vn -acodec libmp3lame -f mp3 "$WORK_FILE"
    ${pkgs.mp3gain}/bin/mp3gain "$WORK_FILE"

    mv "$WORK_FILE" "$OUTPUT_FILE"
    sync

    echo "Done ($OUTPUT_FILE)!"
  '';
} {
  target = "${variables.homeDir}/bin/any2mp3s";
  source = pkgs.writeScript "any2mp3s.sh" ''
    #!${pkgs.stdenv.shell}

    set -e

    if [ -d "$1" ]
    then
        INPUT_DIR="$1"
    else
        exit 1
    fi

    if [ -d "$2" ]
    then
        OUTPUT_DIR="$2"
    else
        exit 2
    fi

    find "$INPUT_DIR" -type f -exec ${variables.homeDir}/bin/any2mp3 '{}' "$OUTPUT_DIR" \;

    echo "Done ($OUTPUT_DIR)!"
  '';
}]
