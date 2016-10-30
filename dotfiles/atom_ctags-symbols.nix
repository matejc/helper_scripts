{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.atom/packages/symbols-tree-view/vendor/universal-ctags-linux";
  source = pkgs.writeScript "atom-universal-ctags-linux" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.ctags}/bin/ctags $@
  '';
}
