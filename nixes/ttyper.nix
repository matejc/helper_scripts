{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "ttyper";
  version = "0.2.3";
  src = fetchFromGitHub {
    owner = "max-niederman";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-YHGTKp3XjXImMTkGjCyj5+p5KzC9dMkkLvA3FzUOatk=";
  };
  cargoSha256 = "sha256-+Ub96G8AG28GIwrJqInfOC0xCWM7BRf++yGI1x41mfw=";
}
