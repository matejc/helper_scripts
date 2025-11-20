#!/usr/bin/env bash

set -e

if ! command -v jq &>/dev/null
then
    echo "Error: Missing required command: jq" >&2
    exit 1
fi

output="${1:?Error: First argument is required: output name}"
ws_idx="${2:?Error: Second argument is required: Niri workspace idx}"

ws_id="$(niri msg --json workspaces | jq --arg output "$output" --argjson idx "$ws_idx" -r --unbuffered '.[]|select(.output==$output and .idx==$idx).id')"

niri msg --json event-stream | jq -r --unbuffered --argjson ws_id "$ws_id" '.WorkspaceActiveWindowChanged|select(.workspace_id == $ws_id)|.active_window_id' | xargs -I{} niri msg action set-dynamic-cast-window --id '{}'
