{ pkgs ? import <nixpkgs> { } }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "sway-workspace";
  version = "0.2.3";
  src = pkgs.fetchFromGitHub {
    owner = "matejc";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-8rxO/jvLLRwU7LVX4UxA65+/1BI3rK5uJXkKIGbs5as=";
  };
  cargoHash = "sha256-DitLtPFogRtqP1rTt4tvOqROJy0MWnt6vA210tSRYTw=";
}

