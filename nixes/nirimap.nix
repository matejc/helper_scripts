{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "nirimap";
  version = "20251205";
  src = fetchFromGitHub {
    owner = "matejc";
    repo = pname;
    rev = "a5fd28537925fdc74beffae0824d959ec1bd9b54";
    hash = "sha256-xMXqTOoRvbFvRoqdHRSp+B097XiWKTAdaqKySFV1W/U=";
  };
  cargoHash = "sha256-aDeMZ9WyuMNRcCgxGBmMJvPQeMqXd9Eppsesb+vUKZA=";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gtk4 gtk4-layer-shell ];
}
