{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation rec {
  name = "lemminx";
  version = "0.19.2-655";
  # https://github.com/redhat-developer/vscode-xml/blob/master/package.json
  src = builtins.fetchurl {
    url = "https://download.jboss.org/jbosstools/vscode/snapshots/lemminx-binary/${version}/lemminx-linux.zip";
    sha256 = "sha256:05f6fzqg8wzki1d12v5kqx2w5xqhp955x8klxqh055a1x3sgg4jf";
  };
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
