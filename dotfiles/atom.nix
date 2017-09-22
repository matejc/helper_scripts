{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/a";
  source = pkgs.writeScript "atom.sh" ''
    #!${pkgs.stdenv.shell}

    mkdir -p ${variables.homeDir}/.openoffice.org/3/user/wordbook
    ln -sf ${pkgs.hunspellDicts.en-us}/share/hunspell/* ${variables.homeDir}/.openoffice.org/3/user/wordbook/

    ${pkgs.atom}/bin/atom "$@"
  '';
}
