{ pkgs ? import <nixpkgs> {} }:
let
  thoriumVersion = "126.0.6478.231";
  thoriumSrc = {
    x86_64-linux = "https://github.com/Alex313031/thorium/releases/download/M${thoriumVersion}/Thorium_Browser_${thoriumVersion}_AVX2.AppImage";
    aarch64-linux = "https://github.com/Alex313031/Thorium-Raspi/releases/download/M${thoriumVersion}/Thorium_Browser_${thoriumVersion}_arm64.AppImage";
  };

  makeThorium = system: let
    pname = "thorium";
    version = thoriumVersion;
    src = pkgs.fetchurl {
      url = thoriumSrc.${system};
      sha256 = "sha256-9JoPftspzmkIi+UO2PuoltN2Op7d1hiRaskr1gklJSw=";
    };
    appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
  in pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/thorium-browser.desktop $out/share/applications/thorium-browser.desktop
      install -Dm444 ${appimageContents}/thorium.png $out/share/icons/hicolor/512x512/apps/thorium.png
      ln -s $out/bin/thorium $out/bin/chromium
    '';
  };
in
  makeThorium "x86_64-linux"
