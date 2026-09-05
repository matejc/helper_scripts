{ pkgs ? import <nixpkgs> {} }:
let
  version = "2.4.1";
  src = pkgs.fetchFromGitHub {
    owner = "ChrisDKN";
    repo = "Amethyst-Mod-Manager";
    rev = "v${version}";
    hash = "sha256-TZFllCac4V80C5nNnwQAtAWFYqga3FC+E23LNeHbayA=";
  };

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    pyside6
    requests
    py7zr
    pillow
    lz4
    zstandard
    websocket-client
    keyring
    msgpack
    bsdiff4
  ]);

  filegraph = pkgs.rustPlatform.buildRustPackage (final: {
    pname = "amethyst-filegraph";
    version = "0.1.0";
    inherit src;

    sourceRoot = "${src.name}/native/amethyst_filegraph";

    cargoLock = {
      lockFile = "${src}/native/amethyst_filegraph/Cargo.lock";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      install -Dm755 \
        target/${pkgs.stdenv.hostPlatform.rust.cargoShortTarget}/release/libamethyst_filegraph.so \
        $out/lib/amethyst_filegraph.abi3.so

      runHook postInstall
    '';
  });
in
pkgs.stdenv.mkDerivation (final: {
  pname = "amethyst-mod-manager";

  inherit src version;

  preConfigure = ''
    patchShebangs ./src/version.py
    cp ${filegraph}/lib/amethyst_filegraph.abi3.so ./src/
  '';

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    pythonEnv
  ];

  mesonFlags = [
    "--prefix=${placeholder "out"}"
  ];

  postInstall = ''
    substituteInPlace $out/bin/* --replace-fail "python3" "env PYTHONPATH=$out/${pythonEnv.sitePackages} ${pythonEnv}/bin/python3"
  '';
})
