{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  src = fetchFromGitHub {
    owner = "hmgle";
    repo = "graftcp";
    rev = "e062ffe20673c222bc68e297070be1e10e46be47";
    hash = "sha256-wGLsqCdH+QtBp5mn7lOhsr1g4d+R9ZMp5Z6I5mo+Bbw=";
  };

  version = "unstable-2025-04-17";

  graftcp_go = buildGoModule {
    pname = "graftcp";
    inherit version src;
    sourceRoot = "${src.name}/local";
    vendorHash = "sha256-+yRSi65wAYPSIe/rJ2Fc9lMPBZ+vb4Fefw0s7H7E7HM=";
    buildInputs = [ graftcp_gcc ];
    LIBRARY_PATH = "${graftcp_gcc}/lib";
  };

  graftcp_gcc = stdenv.mkDerivation {
    pname = "graftcp";
    inherit version src;
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
