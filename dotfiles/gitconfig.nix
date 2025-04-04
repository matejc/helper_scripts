{ variables, config, pkgs, lib }:
let
  dsf = pkgs.gitAndTools.diff-so-fancy.overrideDerivation (old: rec {
    version = "1.4.3";
    name = "diff-so-fancy-${version}";
    src = pkgs.fetchFromGitHub {
      owner = "so-fancy";
      repo = "diff-so-fancy";
      rev = "refs/tags/v${version}";
      sha256 = "11vkq5njjlvjipic7db44ga875n61drszw1qrdzwxmmfmnz425zz";
    };
  });
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
        inplace-rebase = !git checkout $1 && git rebase $2 && git checkout - && echo
        stash-pull = !git stash && git pull origin $1 && git stash pop && echo
        grep-history = !git rev-list --all --date-order | PAGER=cat xargs git grep -n
        grep-all = !git show-ref | ${pkgs.gawk}/bin/awk '{print $2}' | PAGER=cat xargs git grep -n
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
