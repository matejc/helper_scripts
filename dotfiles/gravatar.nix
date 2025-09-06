{ variables, pkgs, lib, ... }:
[{
  target = "${variables.homeDir}/.face";
  source = pkgs.fetchurl {
    url = "https://0.gravatar.com/avatar/${variables.gravatar.id}?s=512";
    hash = variables.gravatar.hash;
  };
}]
