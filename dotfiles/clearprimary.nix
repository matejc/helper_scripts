{ variables, config, pkgs, lib }:
let
  app = import "${builtins.fetchGit {
    url = "git://github.com/matejc/clearprimary";
    ref = "main";
  }}" { inherit pkgs; };
in {
  target = "${variables.homeDir}/bin/clearprimary";
  source = "${app}/bin/clearprimary";
}
