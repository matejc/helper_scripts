{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  src = fetchFromGitHub {
    owner = "hmgle";
    repo = "graftcp";
    rev = "b8f775f4b2f2e738f0db165cd708d516b203e8cc";
    hash = "sha256-hpiPpZpD5hNdR6UsZI67fyw1u2YyLSp6chpLxDYs21c=";
  };

  graftcp_go = buildGoModule {
    pname = "graftcp";
    version = "unstable-2024-10-27";
    inherit src;
    sourceRoot = "${src.name}/local";
    vendorHash = "sha256-jXX5YPl9ubqvL4edSIWkcVQqtDVoi88ZhoLaG/Gykm8=";
    buildInputs = [ graftcp_gcc ];
    LIBRARY_PATH = "${graftcp_gcc}/lib";
  };

  graftcp_gcc = stdenv.mkDerivation {
    pname = "graftcp";
    version = "unstable-2024-10-27";
    inherit src;
    buildInputs = [ go ];
    makeFlags = [ "graftcp" "libgraftcp.a" ];
    installPhase = ''
      mkdir -p $out/lib
      substituteInPlace ./Makefile --replace-fail 'PREFIX = /usr/local' "PREFIX = $out"
      make install_graftcp
      mv -v *.a $out/lib/
    '';
  };
in graftcp_go
