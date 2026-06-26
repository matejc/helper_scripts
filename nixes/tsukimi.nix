{
  pkgs ? import <nixpkgs> { },
  nixpkgs ? <nixpkgs>,
}:
let
  pkgsRustNightly = import nixpkgs {
    overlays = [
      (import (
        pkgs.fetchFromGitHub {
          owner = "oxalica";
          repo = "rust-overlay";
          rev = "3be56bd430bfd65d3c468a50626c3a601c7dee03";
          hash = "sha256-vEl3cGHRxEFdVNuP9PbrhAWnmU98aPOLGy9/1JXzSuM=";
        }
      ))
    ];
    system = pkgs.stdenv.hostPlatform.system;
  };

  cargo = pkgsRustNightly.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
  rustc = pkgsRustNightly.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
  rustPlatform = pkgsRustNightly.makeRustPlatform {
    inherit cargo rustc;
  };
in
(pkgsRustNightly.tsukimi.override { inherit rustPlatform cargo rustc; }).overrideAttrs (
  final: old: {
    pname = "tsukimi";
    version = "26.6.3";

    src = pkgs.fetchFromGitHub {
      owner = "tsukinaha";
      repo = "tsukimi";
      rev = "refs/tags/v${final.version}";
      hash = "sha256-Q+WMwd4GEA1K0Ul8e3g+uBmaUT7nWA865vhuIioqqi4=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (final) pname src version;
      hash = final.cargoHash;
    };
    cargoHash = "sha256-P77AS0+zbi2lfgkH5TDg9JdoYAiWJVdlgHs/ThU547U=";
  }
)
