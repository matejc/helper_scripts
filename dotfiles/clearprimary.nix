{ variables, config, pkgs, lib }:
let
  app = import "${builtins.fetchGit {
    url = "https://github.com/matejc/clearprimary";
    ref = "main";
  }}" { inherit pkgs; };
in {
  target = "${variables.homeDir}/bin/clearprimary";
  source = "${app}/bin/clearprimary";
}
