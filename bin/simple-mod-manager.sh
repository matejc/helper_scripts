#!/usr/bin/env nix-shell
#!nix-shell -p bash unar coreutils -i bash

set -e

source="${1?"First arg is source path"}"
destination="${2?"Second arg is destination path"}"

source="$(realpath "$source")"
destination="$(realpath "$destination")"

if [ ! -e "$source" ]
then
  echo "Error: Source '$source' does not exist!" >&2
  exit 1
fi

if [ ! -d "$destination" ]
then
  echo "Error: Destination '$destination' does not exist!" >&2
  exit 1
fi

_mk_contents() {
    local src="$1"
    local dst="$2"
    for srcFile in "$src"/*
    do
        fileName="$(basename "$srcFile")"
        dstFile="$dst/$fileName"
        if [ -d "$srcFile" ]
        then
            mkdir -p "$dstFile"
            _mk_contents "$srcFile" "$dstFile"
        elif [ ! -e "$dstFile" ]
        then
            echo "  Linking '$srcFile' to '$dstFile' ..."
            if [ -z "$DRYRUN" ]
            then
                ln -s "$srcFile" "$dstFile"
            fi
        fi
    done
}

install_mod() {
    local modDir="$1"
    local destination="$2"

    local rel="${destination#/}"
    local candidate

    while [[ -n "$rel" ]]; do
        candidate="$modDir/$rel"

        if [[ -d "$candidate" ]]; then
            echo "  Found matching suffix: $candidate"
            _mk_contents "$candidate" "$destination"
            return 0
        fi

        if [[ "$rel" == */* ]]; then
            rel="${rel#*/}"
        else
            break
        fi
    done

    echo "  No matching suffix found: $modDir"
    _mk_contents "$modDir" "$destination"
}

clean_mods() {
    modsPrefix="$1"
    destination="$2"
    find "$destination" -type l -print0 | while IFS= read -r -d '' subFile
    do
        if [ -L "$subFile" ] && realpath "$subFile" | grep -q "^$modsPrefix"
        then
            echo "Removing '$subFile' ..."
            if [ -z "$DRYRUN" ]
            then
                rm "$subFile"
            fi
        fi
    done
    find "$destination" -type d -empty -delete
}

process_file() {
    sourceFile="$1"
    modsDir="$2"
    echo "Processing '$sourceFile' ..."
    hash="$(echo -n "$sourceFile" | md5sum | cut -d' ' -f1)"
    modDir="$modsDir/$hash"
    mkdir -p "$modDir"
    if [ -f "$sourceFile" ]
    then
        unar -D -o "$modDir" "$sourceFile" >/dev/null
        install_mod "$modDir" "$destination"
    elif [ -d "$sourceFile" ]
    then
        cp -a "$sourceFile" "$modDir"/
        install_mod "$modDir" "$destination"
    else
        echo "Error: '$sourceFile' is not a file nor a directory!"
        return 1
    fi
}


if [ -d "$source" ]
then
    modsDir="$source/.mods/$(date -u -Is)"
    clean_mods "$source/.mods" "$destination"
    for subFile in "$source"/*
    do
        process_file "$subFile" "$modsDir"
    done
else
    echo "Error: '$source' is not a directory!"
    return 1
fi
