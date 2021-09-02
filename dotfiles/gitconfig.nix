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
    [pull]
        rebase = true
  '';
}
