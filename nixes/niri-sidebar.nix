{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "niri-sidebar";
  version = "dev";
  src = fetchFromGitHub {
    # owner = "Vigintillionn";
    owner = "smatheusblu";
    repo = pname;
    rev = "b8abfbfca0355f16654e866ccaa6776f50ff1f45";
    hash = "sha256-NEBsOYZMDosdSLfKTrmrtAVpRMcqqtUoPby3QKWLLAs=";
  };
  cargoHash = "sha256-zZlfwAxWE1ZZy6k7QoBOamCGigGShd89sD27vfvgR00=";
}
