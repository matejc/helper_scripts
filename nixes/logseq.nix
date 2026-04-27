{ pkgs ? import <nixpkgs> {} }:
let
  pname = "logseq";
  version = "0.10.15";
  src = pkgs.fetchurl {
    url = "https://github.com/logseq/logseq/releases/download/${version}/Logseq-linux-x64-${version}.AppImage";
    sha256 = "sha256-i5EQUvSW1ix+8NT8nCs6mGH2B9xF7G4mB7vBhDJ7JdE=";
  };
  appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/Logseq.desktop $out/share/applications/Logseq.desktop
      install -Dm444 ${appimageContents}/usr/share/icons/hicolor/256x256/apps/Logseq.png $out/share/icons/hicolor/256x256/apps/Logseq.png
      substituteInPlace $out/share/applications/Logseq.desktop \
        --replace-fail 'Exec=Logseq %u' "Exec=systemd-run --user --scope --collect -- $out/bin/logseq %u"
    '';
  }
