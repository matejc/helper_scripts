{ pkgs ? import <nixpkgs> {} }:
let
  quickemu = pkgs.quickemu.overrideAttrs (old: {
    patches = old.patches ++ [
      (pkgs.fetchpatch {
        name = "fix-ubuntu-24_x_download.patch";
        url = "https://github.com/quickemu-project/quickemu/commit/36082437e1c08b136b399259af28241d7ca4bf10.patch";
        hash = "sha256-cINKmbh/aV9wYxvBKJXBxaBQnsojcUn44oUtrhXaID4=";
      })
    ];
  });
in
  quickemu
