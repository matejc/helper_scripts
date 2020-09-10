{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.gitconfig";
  source = pkgs.writeText "gitconfig" ''
    [user]
        name = ${variables.fullName}
        email = ${variables.email}
    [core]
        editor = ${variables.editor}
        excludesfile = ${variables.homeDir}/.gitignore
        pager = env PATH="$PATH:${pkgs.perl}/bin" ${pkgs.gitAndTools.diff-so-fancy}/bin/diff-so-fancy | ${pkgs.less}/bin/less --tabs=4 -RFX
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
