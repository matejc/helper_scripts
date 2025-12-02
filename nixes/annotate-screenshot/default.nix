{
  pkgs ? import <nixpkgs> { },
  niri ? pkgs.niri,
}:
pkgs.stdenv.mkDerivation {
  pname = "annotate-screenshot";
  version = "0.1.0";
  src = ./annotate-screenshot.sh;
  dontUnpack = true;
  buildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/annotate-screenshot
    wrapProgram $out/bin/annotate-screenshot \
      --prefix PATH : "${
        pkgs.lib.makeBinPath ([
          pkgs.coreutils
          pkgs.satty
          niri
        ])
      }"
  '';
}
