{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "teleport";
  version = "11.3.2";

  src = builtins.fetchurl "https://cdn.teleport.dev/teleport-v${version}-linux-amd64-bin.tar.gz";

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
