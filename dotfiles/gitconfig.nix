{ variables, config, pkgs, lib }:
let
  dsf = pkgs.gitAndTools.diff-so-fancy.overrideDerivation (old: {
    name = "diff-so-fancy-20201228";
    src = pkgs.fetchFromGitHub {
      owner = "so-fancy";
      repo = "diff-so-fancy";
      rev = "7792d3f1cf9368a6e7ee68068c30a8c4775d7ea3";
      sha256 = "1bn6ljrbkxx0f61iid52ximvp23iypp3wq3c7mzf086ba7kl87d4";
    };
  });
in
{
  target = "${variables.homeDir}/.gitconfig";
  source = pkgs.writeText "gitconfig" ''
    [user]
        name = ${variables.fullName}
        email = ${variables.email}
    [core]
        editor = ${variables.programs.editor}
        excludesfile = ${variables.homeDir}/.gitignore
        pager = ${dsf}/bin/diff-so-fancy | ${pkgs.less}/bin/less --tabs=4 -RFX
    [interactive]
        diffFilter = ${dsf}/bin/diff-so-fancy --patch
    [color]
        branch = auto
        diff = auto
        interactive = auto
        status = auto
    [alias]
        lol = log --graph --decorate --pretty=oneline --abbrev-commit --branches --remotes --tags
        l = log --graph --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s\n%Cgreen(%cr) %C(bold blue)<%an>%Creset\n' --abbrev-commit --branches --remotes --tags
        car = !git checkout $1 && git rebase $2 && git checkout - && echo
  '';
}
