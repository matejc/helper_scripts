#!/usr/bin/env bash

niri msg --json event-stream |
  jq --unbuffered -c 'select(.WindowFocusChanged or .WindowOpenedOrChanged)' |
  while IFS= read -r _; do
    title=$(niri msg --json focused-window | jq -r '.title // empty')
    echo "Application title: $title"
    tail -n +2 ~/.config/Swiftpoint\ X1\ Control\ Panel/autosave.spcf |
      jq --unbuffered -r --arg title "$title" '
        (.RootProfile.Groups[]
        | select(any(.Applications[]?; (.Name|trim) == ($title|trim)))
        | .Name) // "Desktop"
      ' | xargs -I{} echo "Profile Set {}" | nc -w 1 -U /tmp/swiftpoint.x1.v2.command
  done
