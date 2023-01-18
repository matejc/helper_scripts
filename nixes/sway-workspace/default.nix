{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  build = rustPlatform.buildRustPackage {
    pname = "sway-workspace";
    version = "0.1.0";

    src = ./.;

    cargoSha256 = "sha256-V8jqHCxvpBGjHCar3CNn78mWtKifcdOB32D7HIR64Qc=";
  };

  shell = mkShell {
    nativeBuildInputs = with pkgs; [ rustc cargo ];
    RUST_BACKTRACE = 1;
  };
in {
  inherit build shell;
}
