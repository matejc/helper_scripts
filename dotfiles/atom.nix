{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/a";
  source = pkgs.writeScript "atom.sh" ''
    #!${pkgs.stdenv.shell}

    export PATH="${pkgs.aspell}/bin:${pkgs.hunspell}/bin:${pkgs.python27Packages.pycodestyle}/bin:${pkgs.python27Packages.isort}/bin:$NIX_USER_PROFILE_DIR/atomenv/bin:$PATH"

    mkdir -p ${variables.homeDir}/.openoffice.org/3/user/wordbook
    ln -sf ${pkgs.hunspellDicts.en-us}/share/hunspell/* ${variables.homeDir}/.openoffice.org/3/user/wordbook/

    ${pkgs.atom}/bin/atom "$@" &
  '';
}
