{ pkgs ? import <nixpkgs> { }, nixpkgs ? <nixpkgs> }:
let

  pkgsRustNightly = import nixpkgs {
    overlays = [
      (import (pkgs.fetchFromGitHub {
        owner = "oxalica";
        repo = "rust-overlay";
        rev = "6604534e44090c917db714faa58d47861657690c";
        hash = "sha256-6fCtyVdTzoQejwoextAu7dCLoy5fyD3WVh+Qm7t2Nhg=";
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
    rev = "3391fbba02f5da9af1b88b1259f2586e5deae6fe";
    hash = "sha256-baSZoPyzae9wi++6V0GT2df6EnfuWwECmB97xvpctOM=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
  inherit (final) pname src version;
    hash = final.cargoHash;
  };
  cargoHash = "sha256-fjFTj0iNnE6AG+5y2eAvNOolRkXZHTIsBQBEUQbqb6g=";
})
