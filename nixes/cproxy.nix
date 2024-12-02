{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "cproxy";
  version = "4.2.1";
  src = fetchFromGitHub {
    owner = "NOBLES5E";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-vk2LMTwLCVkykIMWGqC94GCacRySLnaQzmo7pjLVJQA=";
  };
  cargoHash = "sha256-I7ZDOVfX2vfMfeHXbRtObC9PC/kqUbacim1uyGKg+WI=";
}
