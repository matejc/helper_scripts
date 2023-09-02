{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
  name = "wlvncc";

  src = fetchFromGitHub {
    owner = "any1";
    repo = "wlvncc";
    rev = "2b9a886edd38204ef36e9f9f65dd32aaa3784530";
    sha256 = "sha256-0HbZEtDaLjr966RS+2GHc7N4nsivPIv57T/+AJliwUI=";
  };

  nativeBuildInputs = [ meson cmake pkgconfig ninja ];

  buildInputs = [ libxkbcommon pixman wayland libdrm mesa libglvnd ffmpeg aml lzo openssl zlib libjpeg libpng ];

}
