{ variables, config, pkgs, lib }:
with lib;
mapAttrsToList (name: exec: {
  target = "${variables.homeDir}/bin/${name}";
  source = pkgs.writeScript "${name}.sh" ''
    #!${pkgs.stdenv.shell}
    exec ${exec} "$@"
  '';
}) variables.programs
