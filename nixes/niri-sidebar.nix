{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "niri-sidebar";
  version = "dev";
  src = fetchFromGitHub {
    # owner = "Vigintillionn";
    owner = "matejc";
    repo = pname;
    rev = "55cb82621fc075df48bb23bf90162193be91edde";
    hash = "sha256-+CZIaeVQ+Af6XSieQ0i2xs5mAc/cSom5fGtRAOuNtLU=";
  };
  cargoHash = "sha256-zZlfwAxWE1ZZy6k7QoBOamCGigGShd89sD27vfvgR00=";
}
