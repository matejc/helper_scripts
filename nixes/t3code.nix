{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = "t3code";
  version = "0.0.15";

  src = pkgs.fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    sha256 = "sha256-Z8y7SWH55+ZC7cRpgo0cdG273rbDiFS3pXQt3up7sDg=";
  };
  appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/t3-code-desktop.desktop $out/share/applications/t3-code-desktop.desktop
      cat $out/share/applications/t3-code-desktop.desktop
      substituteInPlace $out/share/applications/t3-code-desktop.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox %U' "Exec=$out/bin/t3code %U"

      for res in 16x16 22x22 32x32 48x48 64x64 72x72 96x96 128x128 256x256
      do
        mkdir -p "$out/share/icons/hicolor/$res/apps"
        ${pkgs.imagemagick}/bin/magick ${appimageContents}/usr/share/icons/hicolor/1024x1024/apps/t3-code-desktop.png -resize $res $out/share/icons/hicolor/$res/apps/t3-code-desktop.png
      done
    '';
  }
