{ name, pkgs ? import (fetchTarball "https://github.com/matejc/nixpkgs/archive/mylocal193.tar.gz") {} }:
let
  dotfiles = import ../dotfiles/default.nix
    { inherit name; exposeScript = true; }
    { inherit pkgs; lib = pkgs.lib; config = pkgs.config; };
in
  dotfiles
