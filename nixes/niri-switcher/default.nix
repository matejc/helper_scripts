{
  pkgs ? import <nixpkgs> { },
  niri ? pkgs.niri,
}:
pkgs.stdenv.mkDerivation {
  pname = "niri-switcher";
  version = "0.1.0";
  src = ./niri-switcher.sh;
  dontUnpack = true;
  buildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/niri-switcher
    wrapProgram $out/bin/niri-switcher \
      --prefix PATH : "${
        pkgs.lib.makeBinPath [
          pkgs.coreutils
          pkgs.procps
          niri
        ]
      }"
  '';
}
