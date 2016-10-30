{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.atom/packages/atom-ctags/vendor/ctags-linux";
  source = pkgs.writeScript "atom-ctags-linux" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.ctags}/bin/ctags $@
  '';
}
