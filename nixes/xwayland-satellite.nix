{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "xwayland-satellite";
  version = "0.4";
  src = fetchFromGitHub {
    owner = "Supreeeme";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-dwF9nI54a6Fo9XU5s4qmvMXSgCid3YQVGxch00qEMvI=";
  };
  nativeBuildInputs = [ pkg-config clang ];
  LIBCLANG_PATH = "${libclang.lib}/lib";
  buildInputs = [ xcb-util-cursor xorg.libxcb.dev ];
  cargoSha256 = "sha256-nKPSkHbh73xKWNpN/OpDmLnVmA3uygs3a+ejOhwU3yA=";
  doCheck = false;
}
