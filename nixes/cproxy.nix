{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "cproxy";
  version = "4.2.2";
  src = fetchFromGitHub {
    owner = "NOBLES5E";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-WU2goAiTPE8cTK3dDSX+RHvVBoY5QMBTZc1bu8ZOQn8=";
  };
  cargoHash = "sha256-MTBaraHZ60QhgaQn95pmFb23nC6D+KLWAmS186qyaFg=";
}
