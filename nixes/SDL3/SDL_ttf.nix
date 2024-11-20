{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  SDL3 = callPackage ./default.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "SDL3_ttf";
  version = "unstable-2024-11-14";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_ttf";
    rev = "4a8bda9197cc4d6fafd188bc9df6c7e8749a43a2";
    hash = "sha256-oY8F5kWo75DFJbIAhv7i6IkD/ETMY4p1zZhNghri0og=";
  };

  postInstall = ''
    sed -i 's|''${prefix}//nix/store|/nix/store|g' $out/lib/pkgconfig/sdl3-ttf.pc
  '';

  nativeBuildInputs = [
    SDL3
    pkg-config
    cmake
  ];

  buildInputs = [
    SDL3
    freetype
    harfbuzz
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libGL
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.libobjc
  ];

  strictDeps = true;
})
