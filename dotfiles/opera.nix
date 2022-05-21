{ variables, config, pkgs, lib }:
let
  libffmpegso = let
    env = pkgs.buildEnv {
      name = "env";
      paths = with pkgs; [
        xorg.libX11 xorg.libXrender glib gtk3 atk at-spi2-core pango cairo gdk-pixbuf
        freetype fontconfig xorg.libXcomposite alsa-lib xorg.libXdamage
        xorg.libXext xorg.libXfixes mesa nss nspr expat dbus
        xorg.libXtst xorg.libXi xorg.libXcursor xorg.libXrandr
        xorg.libXScrnSaver xorg.libxshmfence cups
        libcap libdrm libnotify
        libxkbcommon
        # libnw-specific (not chromium dependencies)
        ffmpeg xorg.libxcb
        # chromium runtime deps (dlopen’d)
        sqlite udev
        libuuid
        stdenv.cc.cc
      ];
    };
  in pkgs.runCommand "libffmpeg.so" {
    src = pkgs.fetchzip {
      url = "https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/releases/download/0.64.0/0.64.0-linux-x64.zip";
      sha256 = "sha256-494rHyqq8vbVPn4d4Q3PrVF73eQOs5p+09KxAAFn1is=";
    };
  } ''
    cp $src/libffmpeg.so $out
    chmod 0755 $out
    patchelf --set-rpath "${env}/lib" "$out"
  '';

  opera = let
    mirror = "https://get.geo.opera.com/pub/opera/desktop";
  in pkgs.opera.overrideDerivation (old: rec {
    pname = "opera";
    version = "87.0.4390.25";
    src = pkgs.fetchurl {
      url = "${mirror}/${version}/linux/${pname}-stable_${version}_amd64.deb";
      sha256 = "sha256-2MzKjDJtZGF4och6jExmI2Yu0otHz+Y7R9cgceAARio=";
    };
    postUnpack = ''
      cp -v ${libffmpegso} ./usr/lib/x86_64-linux-gnu/opera/libffmpeg.so
    '';
  });
in {
  target = "${variables.homeDir}/bin/opera";
  source = "${opera}/bin/opera";
}
