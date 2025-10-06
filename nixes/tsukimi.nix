{ pkgs ? import <nixpkgs> { }, nixpkgs ? <nixpkgs> }:
let

  pkgsRustNightly = import nixpkgs {
    overlays = [
      (import (pkgs.fetchFromGitHub {
        owner = "oxalica";
        repo = "rust-overlay";
        rev = "8249aa3442fb9b45e615a35f39eca2fe5510d7c3";
        hash = "sha256-9cpKYWWPCFhgwQTww8S94rTXgg8Q8ydFv9fXM6I8xQM=";
      }))
    ];
    system = pkgs.system;
  };

  cargo = pkgsRustNightly.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
  rustc = pkgsRustNightly.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
  rustPlatform = pkgsRustNightly.makeRustPlatform {
    inherit cargo rustc;
  };
in
(pkgsRustNightly.tsukimi.override { inherit rustPlatform cargo rustc; }).overrideAttrs (final: old: {
  pname = "tsukimi";
  version = "25.5.0";

  src = pkgs.fetchFromGitHub {
    owner = "tsukinaha";
    repo = "tsukimi";
    rev = "7dec0591d7c4b6a2154af22969fb7018481383c2";
    hash = "sha256-DcIoFQccEowM/k+Lh4xB0MUVEzN6laxNtRRnxskxdVs=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
  inherit (final) pname src version;
    hash = final.cargoHash;
  };
  cargoHash = "sha256-s1+sC7gPX0W0gaTXw6nOgotFuPTy1A+ZZ39G4++nUro=";
})
