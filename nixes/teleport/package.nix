{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "teleport";
  version = "12.0.1";

  src = builtins.fetchurl {
    url = "https://cdn.teleport.dev/teleport-v${version}-linux-amd64-bin.tar.gz";
    sha256 = "sha256:0y5f6vgybd39zp5lhvhkbzcpgfyy34nz4ayylv56g5b14jg3v9dc";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp tctl $out/bin/
    cp tsh $out/bin/
    cp teleport $out/bin/

    for file in $out/bin/*
    do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $file
      wrapProgram $file \
        --prefix PATH : ${lib.makeBinPath [ stdenv.cc.libc.bin ]}
    done
  '';
}
