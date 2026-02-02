{ pkgs ? import <nixpkgs> {} }:
pkgs.zed-editor.overrideAttrs (final: old: {
  src = pkgs.fetchFromGitHub {
    owner = "zed-industries";
    repo = "zed";
    rev = "e68da53bed255e75b62af496f7b3e015440327bf";  # for markdown-rs-preview: https://github.com/zed-industries/zed/issues/10696
    hash = "sha256-dDjjVb2+2xJENjn/G0em6x1Iks0DNsu/oVoDWi6OaTE=";
  };
  cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    inherit (final) pname src version;
    hash = final.cargoHash;
  };
  cargoHash = "sha256-Jvzjv7ujf9bHSqZqQkHSCvC0BVywCBvsHevAfoJwzF4=";
  RUST_BACKTRACE = "full";
})
