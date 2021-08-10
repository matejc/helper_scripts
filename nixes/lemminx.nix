{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
  name = "lemminx";
  # https://github.com/redhat-developer/vscode-xml/blob/master/package.json
  src = fetchTarball "https://download.jboss.org/jbosstools/vscode/snapshots/lemminx-binary/LATEST/lemminx-linux.zip";
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/lemminx
  '';
}
