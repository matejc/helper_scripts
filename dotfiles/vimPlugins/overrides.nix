{ lib, stdenv
, python, cmake, meson, vim, ruby
, which, fetchFromGitHub, fetchgit, fetchurl, fetchzip
, llvmPackages, rustPlatform
, xkb-switch, fzf, skim, stylish-haskell
, python3, boost, icu, ncurses
, ycmd, rake
, gobject-introspection, glib, wrapGAppsHook
, substituteAll
, languagetool
, Cocoa, CoreFoundation, CoreServices
, buildVimPluginFrom2Nix

# coc-go dependency
, go

# vim-go denpencies
, asmfmt, delve, errcheck, godef, golint
, gomodifytags, gotags, gotools, go-motion
, gnused, reftools, gogetdoc, gometalinter
, impl, iferr, gocode, gocode-gomod, go-tools

# vCoolor dependency
, gnome3
}:

self: super: {}
