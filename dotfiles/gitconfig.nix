{
  variables,
  pkgs,
  lib,
  ...
}:
let
  push_sh = pkgs.writeShellScript "push.sh" ''
    set -e

    export PATH="$PATH:${pkgs.gum}/bin"

    echor() {
        echo "> $@" >&2
        "$@"
    }

    REMOTE="$1"
    BRANCH="$2"

    if [ -z "$REMOTE" ]
    then
        REMOTE="$(gum filter --limit=1 --height=10 --value="$(git config branch.$(git symbolic-ref -q --short HEAD).remote)" $(git remote))"
    fi

    if [ -z "$BRANCH" ]
    then
        BRANCH="$(gum filter --limit=1 --height=10 --value="$(git symbolic-ref -q --short HEAD)" $(git branch --format="%(refname:short)"))"
    fi

    if [ -n "$REMOTE" ] && [ -n "$BRANCH" ]
    then
        echor git push "$REMOTE" "$BRANCH"
    else
        exit 1
    fi
  '';
  commit_sh = pkgs.writeShellScript "commit.sh" ''
    set -e

    export PATH="$PATH:${pkgs.gum}/bin"

    echo_confirm() {
        echo "> $@" >&2
        echo >&2
        gum confirm "Commit changes?" && "$@"
    }

    if git diff --staged --quiet
    then
        exit 1
    fi

    SUMMARY="$@"

    if [ -z "$SUMMARY" ]
    then
        TYPE=$(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")
        SCOPE=$(gum input --placeholder "scope")

        test -n "$SCOPE" && SCOPE="($SCOPE)"

        SUMMARY=$(gum input --value "$TYPE$SCOPE: " --placeholder "Summary of this change")
    fi

    DESCRIPTION=""
    gum confirm "Enter details?" && DESCRIPTION=$(gum write --placeholder "Details of this change")

    if [ -n "$SUMMARY" ] && [ -n "$DESCRIPTION" ]
    then
        echo_confirm git commit -m "$SUMMARY" -m "$DESCRIPTION"
    elif [ -n "$SUMMARY" ]
    then
        echo_confirm git commit -m "$SUMMARY"
    else
        exit 1
    fi
  '';

  pickaxe_diff_sh = pkgs.writeShellScript "pickaxe-diff.sh" ''
    set -euo pipefail

    export PATH="$PATH:${pkgs.patchutils_0_4_2}/bin"

    path=$1
    old_file=$2
    new_file=$5

    # Generate the original diff without calling ourselves.
    diff_output=$(
        git diff --no-color --no-ext-diff \
            --no-index -p -- "$old_file" "$new_file" || :
    )

    # Filter out unrelated hunks.
    filtered=$(
        printf '%s\n' "$diff_output" |
            grepdiff "$GREPDIFF_REGEX" \
                --output-matching=hunk \
                --only-match=mod |
            sed -n '/^@@ /,$p'
    )

    # Only print files containing matching hunks.
    if [[ -n "$filtered" ]]; then
        printf 'diff --git a/%s b/%s\n' "$path" "$path"
        printf '%s\n' "$filtered"
    fi
  '';

  hunks_sh = pkgs.writeShellScript "hunks.sh" ''
    set -euo pipefail

    export PATH="${pkgs.fzf}/bin:${pkgs.delta}/bin:${pkgs.ripgrep}/bin:$PATH"

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
        --format='%h %s' \
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
            --preview-window 'right,75%,border-left' \
            --bind 'pgdn:preview-page-down' \
            --bind 'pgup:preview-page-up' \
            --bind 'ctrl-/:toggle-preview'
  '';
in
{
  target = "${variables.homeDir}/.gitconfig";
  source = pkgs.writeText "gitconfig" ''
    [user]
        name = ${variables.fullName}
        email = ${variables.email}
        signingkey = ${variables.homeDir}/.ssh/${variables.signing.keyName}
    [core]
        editor = ${variables.programs.editor}
        excludesfile = ${variables.homeDir}/.gitignore
        pager = ${pkgs.delta}/bin/delta
    [interactive]
        diffFilter = ${pkgs.delta}/bin/delta --color-only
    [delta]
        navigate = true    # use n and N to move between diff sections
        light = false      # set to true if you're in a terminal w/ a light background color (e.g. the default macOS terminal)
        side-by-side = false
        line-numbers = true
    [merge]
        conflictstyle = zdiff3
    [diff]
        algorithm = histogram
        colorMoved = plain
        mnemonicPrefix = true
        renames = true
    [color]
        branch = auto
        diff = auto
        interactive = auto
        status = auto
    [alias]
        lol = log --graph --decorate --pretty=oneline --abbrev-commit --branches --remotes --tags
        l = log --graph --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s\n%Cgreen%cr %C(bold blue)%an%Creset %Cgreen%G?%Creset\n' --abbrev-commit --branches --remotes --tags
        inplace-rebase = !git checkout "$1" && git rebase "$2" && git checkout - && echo
        stash-pull = !git stash && git pull "$@" && git stash pop && echo
        grep-history = !git rev-list --all --date-order | PAGER=cat xargs git grep -n
        grep-all = !git show-ref | ${pkgs.gawk}/bin/awk '{print $2}' | PAGER=cat xargs git grep -n
        find-first = "!f() { res=$(git log -S \"$@\" --reverse --oneline | head -n 1 | ${pkgs.gawk}/bin/awk '{print $1}') && test -n \"$res\" && git show $res; }; f"
        find-last = "!f() { res=$(git log -S \"$@\" --oneline | head -n 1 | ${pkgs.gawk}/bin/awk '{print $1}') && test -n \"$res\" && git show $res; }; f"
        x = "!f() { git add -p && ${commit_sh} \"$3\" && ${push_sh} \"$1\" \"$2\"; }; f"
        hunks = !${hunks_sh}
    [pull]
        rebase = true
    [commit]
        gpgsign = true
        verbose = true
    [gpg]
        format = ssh
    [gpg "ssh"]
        allowedSignersFile = ${lib.toFile "allowed_signers" (lib.concatMapStringsSep "\n" (pubKey: "${variables.email} ${pubKey}") variables.signing.allowedSigners)}
    [credential]
        helper = store
    [include]
        path = ~/workarea/.gitconfig_include
    [column]
        ui = auto
    [branch]
        sort = -committerdate
    [tag]
        sort = version:refname
    [init]
        defaultBranch = main
    [push]
        default = simple
        autoSetupRemote = true
        followTags = true
    [fetch]
        prune = true
        pruneTags = true
        all = true
    [help]
        autocorrect = prompt
    [rerere]
        enabled = true
        autoupdate = true
    [rebase]
        autoSquash = true
        autoStash = true
  '';
}
