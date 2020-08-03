{ name, pkgs ? import <nixpkgs> {} }:
let
  dotfiles = import ../dotfiles/default.nix
    { inherit name; exposeScript = true; }
    { inherit pkgs; lib = pkgs.lib; config = pkgs.config; };
in
  dotfiles
