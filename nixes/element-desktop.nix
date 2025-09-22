{ pkgs ? import <nixpkgs> {} }:
let
  element-desktop = pkgs.element-desktop.overrideAttrs (old: {
    postInstall = ''
      DESKTOP_ITEM="$(cat "$out/share/applications/element-desktop.desktop")"
      rm "$out/share/applications"  # remove the link

      mkdir -p $out/share/applications
      echo "$DESKTOP_ITEM" > "$out/share/applications/element-desktop.desktop"

      substituteInPlace $out/share/applications/element-desktop.desktop \
        --replace-fail 'element-desktop %u' 'element-desktop --password-store=gnome-libsecret --enable-features=UseOzonePlatform --ozone-platform-hint=auto %u' \
        --replace-fail 'Icon=element' 'Icon=element-desktop'

      mkdir -p "$out/share/icons/hicolor/512x512/apps"
      ln -s $out/share/element/electron/build/icon.png $out/share/icons/hicolor/512x512/apps/element-desktop.png

      for res in 16x16 22x22 32x32 48x48 64x64 72x72 96x96 128x128 256x256
      do
        mkdir -p "$out/share/icons/hicolor/$res/apps"
        ${pkgs.imagemagick}/bin/magick $out/share/element/electron/build/icon.png -resize $res $out/share/icons/hicolor/$res/apps/element-desktop.png
      done
    '';
  });
in
  element-desktop
