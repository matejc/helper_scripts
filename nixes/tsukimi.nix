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
    version = "25.5.0";

    src = pkgs.fetchFromGitHub {
      owner = "tsukinaha";
      repo = "tsukimi";
      rev = "fc419ea97717b13ddfb27b9fb9377f105d4d949b";
      hash = "sha256-9jB1Lj1TxSMoF6wi4zyLEjh9/lhDzkHnUk6vHx5t+mA=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (final) pname src version;
      hash = final.cargoHash;
    };
    cargoHash = "sha256-iUaMnVo76JTUflkkZh0DnkD147Amd2UTFT2bHH3o46Q=";
  }
)
