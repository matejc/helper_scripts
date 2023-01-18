{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  workspace = rustPlatform.buildRustPackage {
    pname = "sway-workspace";
    version = "dev";

    src = ./workspace;

    cargoSha256 = "sha256-yX6nMWQ71fvTSbzSy2tQ5Ck+WfUUWDSZxFEdjo+o584=";
  };

  shell = mkShell {
    nativeBuildInputs = with pkgs; [ rustc cargo ];
    RUST_BACKTRACE = 1;
  };
in {
  inherit workspace shell;
}
