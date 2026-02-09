{
  variables,
  config,
  pkgs,
  lib,
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
in
{
  target = "${variables.homeDir}/.gitconfig";
  source = pkgs.writeText "gitconfig" ''
    [user]
        name = ${variables.fullName}
        email = ${variables.email}
        signingkey = ${variables.signingkey}
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
        x = "!f() { git add -p && ${commit_sh} \"$3\" && ${push_sh} \"$1\" \"$2\"; }; f"
    [pull]
        rebase = true
    [commit]
        gpgsign = true
        verbose = true
    [gpg]
        program = ${pkgs.gnupg}/bin/gpg
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
