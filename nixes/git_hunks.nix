{ pkgs ? import <nixpkgs> {} }:
let
  pickaxe_diff_sh = pkgs.writeShellScript "pickaxe-diff.sh" ''
    set -euo pipefail

    export PATH="${pkgs.patchutils_0_4_2}/bin:${pkgs.git}/bin:$PATH"

    path=$1
    old_file=$2
    new_file=$5

    diff_output=$(
        git diff --no-color --no-ext-diff \
            --no-index -p -- "$old_file" "$new_file" || :
    )

    filtered=$(
        printf '%s\n' "$diff_output" |
            grepdiff "$GREPDIFF_REGEX" \
                --output-matching=hunk \
                --only-match=mod |
            sed -n '/^@@ /,$p'
    )

    if [[ -n "$filtered" ]]; then
        printf 'diff --git a/%s b/%s\n' "$path" "$path"
        printf '%s\n' "$filtered"
    fi
  '';
in
  pkgs.writeShellScriptBin "git-hunks" ''
    set -euo pipefail

    export PATH="${pkgs.git}/bin:${pkgs.fzf}/bin:${pkgs.delta}/bin:${pkgs.ripgrep}/bin:$PATH"

    if [[ $# -eq 0 ]]; then
        echo "Usage: git hunks <regex> [path...]" >&2
        exit 1
    fi

    pattern=$1
    shift

    export GREPDIFF_REGEX="$pattern"
    export GIT_EXTERNAL_DIFF="${pickaxe_diff_sh}"

    git log \
        --reverse \
        --date=format:'%Y-%m-%d %H:%M' \
        --format='%h  %ad  %s (%an)' \
        -G "$pattern" \
        -- "$@" |
        fzf \
            --no-sort \
            --layout=reverse \
            --preview '
              git --no-pager show --format= --ext-diff {1} |
                delta --paging=never --dark --file-style=omit --hunk-header-style="file line-number syntax" |
                rg --passthru --color=always \
                   --colors "match:fg:black" \
                   --colors "match:bg:yellow" \
                   -- "$GREPDIFF_REGEX"
            ' \
            --preview-window 'right,75%,border-left,hidden,wrap' \
            --bind 'pgdn:preview-page-down' \
            --bind 'pgup:preview-page-up' \
            --bind 'enter:show-preview' \
            --bind 'up:transform:
              if [ "''${FZF_PREVIEW_COLUMNS:-0}" -gt 0 ]; then
                echo preview-up
              else
                echo up
              fi
            ' \
            --bind 'down:transform:
              if [ "''${FZF_PREVIEW_COLUMNS:-0}" -gt 0 ]; then
                echo preview-down
              else
                echo down
              fi
            ' \
            --bind 'esc:transform:
              if [ "''${FZF_PREVIEW_COLUMNS:-0}" -gt 0 ]; then
                echo hide-preview
              else
                echo abort
              fi
            '
  ''
