{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/fish/conf.d/autocomplete.fish";
  source = builtins.toFile "fish_autocomplete" ''
    ${builtins.readFile ./fish/kubernetes}
  '';
}]
