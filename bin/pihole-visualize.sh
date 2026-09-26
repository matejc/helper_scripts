#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash jq

set -euo pipefail

jq --null-input -c -r '
    foreach (inputs, null) as $line (
        { previous_minute: null, output: [] };

        if $line == null then
            (now / 60 | floor) as $current_minute
            | .output = if .previous_minute == null
                           or $current_minute <= .previous_minute + 1
                        then []
                        else [range(.previous_minute + 1; $current_minute) | "."]
                        end
        else
            ($line.time | fromdateiso8601 / 60 | floor) as $minute
            | ($line | .time |= (fromdateiso8601
                | strflocaltime("%Y-%m-%dT%H:%M:%S%z"))) as $localized_line
            | .output = if .previous_minute == null
                           or $minute <= .previous_minute + 1
                        then [$localized_line]
                        else ([range(.previous_minute + 1; $minute) | "."] + [$localized_line])
                        end
            | .previous_minute = if .previous_minute == null
                                    or $minute > .previous_minute
                                 then $minute
                                 else .previous_minute
                                 end
        end;

        .output[]
    )
'
