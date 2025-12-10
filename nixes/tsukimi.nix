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
    system = pkgs.system;
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
      rev = "30627a8e3058d9a99eb4618345e547147b10194e";
      hash = "sha256-JlDJfAiptzyseMhKhLRjEb3mGWlNn16iOPhNK9Nkrf8=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (final) pname src version;
      hash = final.cargoHash;
    };
    cargoHash = "sha256-eKiC4THwcVRcMCCzNxr2tqmp4YY/F09yWfQp9XQPVI0=";
  }
)
