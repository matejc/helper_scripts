{ stdenv, fetchurl, lib, makeWrapper, libglvnd, zlib, glib, nss, nspr
, fontconfig, freetype, expat, xorg, alsaLib, dbus, libxkbcommon, wayland
, pulseaudio, cairo, libdrm, speechd, cups, postgresql, unixODBC
, gnome2, gdk-pixbuf, atk, gnome3, gst_all_1 }:
let
  version = "0.4.10";
in
stdenv.mkDerivation rec {
  pname = "goneovim";
  inherit version;

  src = fetchurl {
    url =
      "https://github.com/akiyosi/goneovim/releases/download/v${version}/Goneovim-${version}-linux.tar.bz2";
    sha256 = "0kmzs30f28fw1czsic1gv9xw588p1357fqr018szjxxmd491d50k";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/goneovim
    mv ./* $out/share/goneovim/
    chmod +x $out/share/goneovim/plugins/platforminputcontexts/libfcitxplatforminputcontextplugin.so

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
       $out/share/goneovim/goneovim

    makeWrapper $out/share/goneovim/goneovim $out/bin/goneovim \
      --set LD_LIBRARY_PATH "$out/share/goneovim:${lib.makeLibraryPath [
        stdenv.cc.cc libglvnd zlib glib nss nspr fontconfig freetype expat
        xorg.libX11 xorg.libxcb xorg.libXcomposite xorg.libXcursor
        xorg.libXdamage xorg.libXext xorg.libXfixes xorg.libXi xorg.libXrender
        xorg.libXtst alsaLib dbus libxkbcommon wayland cairo libdrm speechd
        gnome2.pango gdk-pixbuf atk gnome3.gtk cups postgresql unixODBC
        gst_all_1.gst-plugins-base gst_all_1.gstreamer pulseaudio
        #libsForQt5.qt5.qtvirtualkeyboard libsForQt5.qt5.qtxmlpatterns
        #libsForQt5.qt5.qtwebsockets libsForQt5.qt5.qtwebview
        #libsForQt5.qt5.qtsensors libsForQt5.qt5.qtremoteobjects
        #libsForQt5.qt5.qtscxml libsForQt5.qt5.qtbase
        #libsForQt5.qt5.qtdeclarative libsForQt5.qt5.qt3d
        #libsForQt5.qt5.qtpurchasing libsForQt5.qt5.qtlocation
        #libsForQt5.qt5.qtconnectivity libsForQt5.qt5.qtcharts
        #libsForQt5.qt5.qtdatavis3d libsForQt5.qt5.qtlottie
        #libsForQt5.qt5.qtspeech libsForQt5.qt5.qtserialport
        #libsForQt5.fcitx5-qt libsForQt5.fcitx-qt5
        #libsForQt5.qt5.qtserialbus libsForQt5.qt5.qttools
        #libsForQt5.qt5.qtmultimedia
      ]}" \
      --set QT_PLUGIN_PATH "$out/share/goneovim/plugins"
  '';

  dontStrip = true;
}
