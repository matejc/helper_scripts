{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
  name = "lemminx";
  # https://github.com/redhat-developer/vscode-xml/blob/master/package.json
  src = builtins.fetchurl "https://download.jboss.org/jbosstools/vscode/snapshots/lemminx-binary/LATEST/lemminx-linux.zip";
  nativeBuildInputs = [ unzip ];
  phases = "unpackPhase installPhase";
  unpackPhase = ''
    unzip $src -d .
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp lemminx-linux $out/bin/lemminx
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/bin/lemminx
  '';
}
