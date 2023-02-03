{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "teleport";
  version = "11.3.2";

  src = builtins.fetchurl {
    url = "https://cdn.teleport.dev/teleport-v${version}-linux-amd64-bin.tar.gz";
    sha256 = "sha256:1c6c9m7k5nzymmpgk2izdzz80bgwmn3fdcf5zlm98n9b224xb6x8";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp tctl $out/bin/
    cp tsh $out/bin/
    cp teleport $out/bin/

    for file in $out/bin/*
    do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $file
    done
  '';
}
