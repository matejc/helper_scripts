{ pkgs ? import <nixpkgs> {} }:
let
  version = "0.3.1";
in
pkgs.rustPlatform.buildRustPackage (final: {
  pname = "nirimap";
  inherit version;
  src = pkgs.fetchFromGitHub {
    owner = "alexandergknoll";
    repo = final.pname;
    tag = "v${version}";
    hash = "sha256-NwUQT5BGELboNBSMJkHTMTjFqxIFoMc8mEB953JP7IE=";
  };
  cargoHash = "sha256-5MlYtZwGO19/ZyN6w4+8b+iMP9fGbZqxBSj8lIWx/6o=";
  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ gtk4 gtk4-layer-shell ];
})
