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
          rev = "6604534e44090c917db714faa58d47861657690c";
          hash = "sha256-6fCtyVdTzoQejwoextAu7dCLoy5fyD3WVh+Qm7t2Nhg=";
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
      rev = "fa73520d1d3a8db161bfe4c37ca05e3198fb7a59";
      hash = "sha256-XKkr0dR5NENqN5N0gLRZqAH/CfHOYx8opjp5gzTJ8/s=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (final) pname src version;
      hash = final.cargoHash;
    };
    cargoHash = "sha256-iFl3ibmkghHUaiOQXNWBCBDcK/JvFGbkAOg9mPC/z3A=";
  }
)
