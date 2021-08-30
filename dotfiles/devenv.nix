{ variables, config, pkgs, lib }:
let
  src = builtins.fetchGit git://github.com/matejc/devenv;
  package = import src { inherit pkgs; };
in
{
  target = "${variables.homeDir}/bin/devenv";
  source = "${package}/bin/devenv";
}
