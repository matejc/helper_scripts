{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/blackscreen";
  source = pkgs.writeScript "blackscreen" ''
    #!${pkgs.stdenv.shell}
    cd ${variables.homeDir}/workarea/black-screen
    nodeenv electron .
  '';
}
