{ pkgs ? import <nixpkgs> {} }:
let
  pname = "movemaster";
  version = "0.5.3";

  src = pkgs.stdenv.mkDerivation {
    pname = "${pname}-appimage";
    inherit version;
    src = pkgs.fetchurl {
      name = "movemaster-lin-en.zip";
      url = "https://drive.usercontent.google.com/download?id=1rUZT56WmOH76DPhLBzDKb-E7v-5xM__q&export=download&authuser=0&confirm=t";
      sha256 = "sha256-4AXBNFfoRUc0NBjMBE+de5Q2VAMNdu33bHpTBwgdfM8=";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    installPhase = ''
      cp ./MoveMaster-${version}.AppImage $out
      mkdir -p $update
      cp -r ./update/* $update/
      mkdir -p $docs
      cp *.pdf $docs/
    '';
    outputs = [ "out" "update" "docs" ];
  };
  appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
      install -D ${appimageContents}/movemaster_evue.desktop $out/share/applications/movemaster_evue.desktop
      substituteInPlace $out/share/applications/movemaster_evue.desktop \
        --replace-fail 'Exec=AppRun' "Exec=$out/bin/movemaster" \

      install -d $out/share/icons/hicolor/
      cp -r ${appimageContents}/usr/share/icons/hicolor/* $out/share/icons/hicolor/

      install -d $out/share/movemaster/update
      cp -r ${src.update}/* $out/share/movemaster/update/

      install -d $out/share/movemaster/docs
      cp ${src.docs}/* $out/share/movemaster/docs/

      source "${pkgs.makeWrapper}/nix-support/setup-hook"
      wrapProgram $out/bin/movemaster --chdir "$out/share/movemaster"
    '';
  }
