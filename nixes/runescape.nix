{ pkgs ? import <nixpkgs> {} }:
let
  env = pkgs.buildEnv {
    name = "runscape-env";
    paths = with pkgs; [
      /* required by launcher executable */
      xorg.libSM xorg.libXxf86vm libpng12 xorg.libX11
      webkitgtk2 glib.out pango.out cairo.out gdk_pixbuf gtk.out
      stdenv.cc.cc.lib glib_networking.out curl.out

      /* required by library additionaly downloaded by launcher - $HOME/Jagex/launcher/librs2client.so */
      SDL2 zlib mesa glew110
    ];
  };
in
pkgs.stdenv.mkDerivation rec {
  name = "runescape-launcher-2.2.2";

  src = pkgs.fetchurl {
    url = "https://content.runescape.com/downloads/ubuntu/pool/non-free/r/runescape-launcher/runescape-launcher_2.2.2_amd64.deb";
    sha256 = "02rf2s5498dgh53x08b1mr8grjijpymy0hblqywg0zrazxdvr1da";
  };

  dontPatchELF = true;
  dontStrip    = true;

  nativeBuildInputs = [ pkgs.dpkg pkgs.makeWrapper ];

  unpackCmd = "mkdir root ; dpkg-deb -x $curSrc root";

  installPhase = ''
    mkdir -p $out
    cp -r ./usr/* $out/
    substituteInPlace $out/bin/runescape-launcher \
      --replace "/usr/share/games/runescape-launcher/runescape" "$out/share/games/runescape-launcher/runescape"
    patchelf --set-interpreter $(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker) \
      $out/share/games/runescape-launcher/runescape
    wrapProgram $out/share/games/runescape-launcher/runescape \
      --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:${env}/lib:${env}/lib64"
  '';
}
