{ pkgs ? import <nixpkgs> {} }:
let
  thoriumVersion = "128.0.6613.189";
  thoriumSrc = {
    x86_64-linux = "https://github.com/Alex313031/thorium/releases/download/M${thoriumVersion}/Thorium_Browser_${thoriumVersion}_AVX2.AppImage";
    aarch64-linux = "https://github.com/Alex313031/Thorium-Raspi/releases/download/M${thoriumVersion}/Thorium_Browser_${thoriumVersion}_arm64.AppImage";
  };

  makeThorium = system: let
    pname = "thorium";
    version = thoriumVersion;
    src = pkgs.fetchurl {
      url = thoriumSrc.${system};
      sha256 = "sha256-RBPSGgwF6A4KXgLdn/YIrdFpZG2+KwMJ8MkTjSPpkhU=";
    };
    appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
  in pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/thorium-browser.desktop $out/share/applications/thorium-browser.desktop
      install -Dm444 ${appimageContents}/thorium.png $out/share/icons/hicolor/512x512/apps/thorium.png
      source "${pkgs.makeWrapper}/nix-support/setup-hook"
      wrapProgram $out/bin/thorium --add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'
      ln -s $out/bin/thorium $out/bin/chromium
    '';
  };
in
  makeThorium "x86_64-linux"
