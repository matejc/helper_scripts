{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  pname = "swiftpoint";
  version = "dev";

  src = pkgs.fetchurl {
    url = "https://swiftpointdrivers.blob.core.windows.net/pro/beta/linux/Swiftpoint%20X1%20Control%20Panel%203.0.7.20-a1956a80.tar.xz";
    sha256 = "sha256-l+S03mautR552BPAMlhsYh/OofO4R83JPWQ7fMzdsl0=";
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/swiftpoint
    find ./lib -xtype l -delete
    cp -r ./* $out/share/swiftpoint/
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/share/swiftpoint/'Swiftpoint X1 Control Panel'
    makeWrapper $out/share/swiftpoint/'Swiftpoint X1 Control Panel' $out/bin/swiftpoint \
      --prefix LD_LIBRARY_PATH : "$out/share/swiftpoint/lib:${pkgs.lib.makeLibraryPath (with pkgs; [
        libusb1 xorg.libX11 libgcc.lib libglvnd zlib glib fontconfig freetype xorg.libXext xorg.libXrender
        xorg.libxcb libxkbcommon dbus libsForQt5.qt5.qtbase openssl_1_1
      ])}" \
      --set QT_PLUGIN_PATH "$out/share/swiftpoint/plugins" \
      --set QT_QPA_PLATFORM_PLUGIN_PATH "$out/share/swiftpoint/plugins/platforms" \
      --set QT_QPA_PLATFORM xcb
  '';
}
