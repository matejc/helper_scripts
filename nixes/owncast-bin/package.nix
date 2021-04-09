{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation rec {
  version = "0.0.6";
  name = "owncast-${version}";
  src = fetchurl {
    url = "https://github.com/owncast/owncast/releases/download/v${version}/${name}-linux-64bit.zip";
    sha256 = "sha256-1wQFkeISbB6z3fQXVsNoRDeHjBfwSSYHQrzQm+Vx3YA=";
  };

  buildInputs = [ unzip makeWrapper ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/{bin,share/owncast}/
    mv ./* $out/share/owncast/

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/share/owncast/owncast

    makeWrapper $out/share/owncast/owncast $out/bin/owncast \
      --prefix "PATH" ":" "${ffmpeg.bin}/bin:${which}/bin"
  '';
}
