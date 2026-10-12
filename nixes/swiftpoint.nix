{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation {
  pname = "swiftpoint";
  version = "dev";

  src = pkgs.fetchurl {
    url = "https://swiftpointdrivers.blob.core.windows.net/pro/public/linux/Swiftpoint%20X1%20Control%20Panel%203.1.4.0-33507352.tar.xz";
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
    mkdir -p $out/etc/udev/rules.d
    ln -s $out/share/swiftpoint/60-Swiftpoint.rules $out/etc/udev/rules.d/
  '';
}
