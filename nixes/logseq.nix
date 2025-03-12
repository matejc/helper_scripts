{ pkgs ? import <nixpkgs> {} }:
let
  pname = "logseq";
  version = "0.10.9";
  src = pkgs.fetchurl {
    url = "https://github.com/logseq/logseq/releases/download/${version}/Logseq-linux-x64-${version}.AppImage";
    sha256 = "sha256-XROuY2RlKnGvK1VNvzauHuLJiveXVKrIYPppoz8fCmc=";
  };
  appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/Logseq.desktop $out/share/applications/Logseq.desktop
      install -Dm444 ${appimageContents}/usr/share/icons/hicolor/256x256/apps/Logseq.png $out/share/icons/hicolor/256x256/apps/Logseq.png
      substituteInPlace $out/share/applications/Logseq.desktop \
        --replace-fail 'Exec=Logseq %u' "Exec=$out/bin/logseq %u"
    '';
  }
