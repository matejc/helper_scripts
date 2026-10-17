{
  pkgs ? import <nixpkgs> { },
}:
let
  desktop = pkgs.makeDesktopItem {
    desktopName = "Swiftpoint X1 Control Panel";
    name = "swiftpoint";
    exec = "swiftpoint";
    icon = "swiftpoint";
  };
  icon = pkgs.fetchurl {
    name = "swiftpoint.png";
    url = "https://www.swiftpoint.eu/cdn/shop/files/SP_Black.png?height=512&width=512";
    sha256 = "sha256-7l2/5dYbVjLO75p0Oh97zD3n7UqVuY7Ui/dsYNwmsKA=";
  };
in
pkgs.stdenv.mkDerivation (final: {
  pname = "swiftpoint";
  version = "3.1.4.0-33507352";

  src = pkgs.fetchurl {
    url = "https://swiftpointdrivers.blob.core.windows.net/pro/public/linux/Swiftpoint%20X1%20Control%20Panel%20${final.version}.tar.xz";
    name = "swiftpoint.tar.xz";
    sha256 = "sha256-WTJKFF5/zC9aVLOHib6p2ZrqlB57Kfxj0UjafihBGRM=";
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/swiftpoint
    find ./lib -xtype l -delete
    cp -r ./* $out/share/swiftpoint/

    # Error: share/swiftpoint/lib/libxkbcommon.so.0: no version information available (required by share/swiftpoint/lib/libQt6Gui.so.6)
    rm $out/share/swiftpoint/lib/libxkbcommon.so.0

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/share/swiftpoint/'Swiftpoint X1 Control Panel'
    makeWrapper $out/share/swiftpoint/'Swiftpoint X1 Control Panel' $out/bin/swiftpoint \
      --prefix LD_LIBRARY_PATH : "$out/share/swiftpoint/lib:${
        pkgs.lib.makeLibraryPath (
          with pkgs;
          [
            libusb1
            libx11
            libgcc.lib
            libglvnd
            zlib
            glib
            fontconfig
            freetype
            libxext
            libxrender
            libxcb
            libxkbcommon
            dbus
            qt6.qtbase
            openssl
            udev
            zstd
            krb5
            libxcb-cursor
            libxcb-wm
            libxcb-render-util
            libxcb-image
            libxcb-keysyms
            kdePackages.wayland
          ]
        )
      }" \
      --set QT_PLUGIN_PATH "$out/share/swiftpoint/plugins" \
      --set QT_QPA_PLATFORM_PLUGIN_PATH "$out/share/swiftpoint/plugins/platforms"
    mkdir -p "$out/etc/udev/rules.d"
    ln -s $out/share/swiftpoint/60-Swiftpoint.rules $out/etc/udev/rules.d/
    mkdir -p "$out/share/applications"
    cp "${desktop}/share/applications/swiftpoint.desktop" "$out/share/applications/"
    for res in 16x16 32x32 64x64 128x128 256x256 512x512
    do
      mkdir -p "$out/share/icons/hicolor/$res/apps"
      ${pkgs.imagemagick}/bin/convert "${icon}" -resize "$res" -gravity center -background none -extent "$res" "$out/share/icons/hicolor/$res/apps/swiftpoint.png"
    done
  '';
})
