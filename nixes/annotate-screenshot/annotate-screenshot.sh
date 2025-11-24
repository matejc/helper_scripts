#!/usr/bin/env bash

set -e

mkdir -p "$HOME/Pictures/Screenshots"

grim -g "$(slurp)" - | satty -f - --initial-tool=arrow --copy-command=wl-copy --actions-on-escape="save-to-file,save-to-clipboard,exit" --brush-smooth-history-size=5 --disable-notifications --output-filename "$HOME/Pictures/Screenshots/Annotated Screenshot From $(date '+%Y-%m-%d %H-%M-%S').png"
