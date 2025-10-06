{ pkgs ? import <nixpkgs> {} }:
let
  pname = "movemaster";
  version = "0.5.3";

  src = pkgs.stdenv.mkDerivation {
    pname = "${pname}-appimage";
    inherit version;
    src = pkgs.fetchurl {
      name = "movemaster-lin-en.rar";
      url = "https://drive.usercontent.google.com/download?id=10QwQF3zKD-V7z_psJpIvOoL5Gfx2pIMd&export=download&authuser=0&confirm=t";
      sha256 = "sha256-4npSVHf8c9NRUYgru2CRsmn3bVQIdbZwOyqSVt9sLWY=";
    };
    nativeBuildInputs = [ pkgs.unrar ];
    installPhase = ''
      cp ./MoveMaster-${version}.AppImage $out
      mkdir -p $update
      cp -r ./update/* $update/
    '';
    outputs = [ "out" "update" ];
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

      source "${pkgs.makeWrapper}/nix-support/setup-hook"
      wrapProgram $out/bin/movemaster --chdir "$out/share/movemaster"
    '';
  }
