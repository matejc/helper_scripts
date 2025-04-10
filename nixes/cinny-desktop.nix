{ pkgs ? import <nixpkgs> {} }:
let
  cinny-desktop = pkgs.cinny-desktop.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ (with pkgs; [ gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-good gst_all_1.gst-plugins-bad ]);
  });
in
  cinny-desktop
