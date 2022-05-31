{ pkgs ? import <nixpkgs> { } }:
let
  nixGL = (import (builtins.fetchGit {
    url = https://github.com/guibou/nixGL;
    ref = "refs/heads/main";
  }) { enable32bits = false; }).auto;
in
  nixGL.nixGLDefault
