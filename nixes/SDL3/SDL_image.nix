{ pkgs ? import <nixpkgs> {},
  enableSdltest ? (!pkgs.stdenv.hostPlatform.isDarwin)
}:
with pkgs;
let
  inherit (darwin.apple_sdk.frameworks) Foundation;
  SDL3 = callPackage ./default.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "SDL3_image";
  version = "unstable-2024-11-03";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL_image";
    rev = "b1c8ec7d75e3d8398940c9e04a8b82886ae6163d";
    hash = "sha256-X2gU7Jx6Lf0lh+hmiLT5HayRyqE4YmMTzV/YRo3q724=";
  };

  postInstall = ''
    sed -i 's|''${prefix}//nix/store|/nix/store|g' $out/lib/pkgconfig/sdl3-image.pc
  '';

  nativeBuildInputs = [
    SDL3
    pkg-config
    cmake
  ];

  buildInputs = [
    SDL3
    giflib
    xorg.libXpm
    libjpeg
    libpng
    libtiff
    libwebp
    zlib
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ Foundation ];

  strictDeps = true;

  enableParallelBuilding = true;
})
