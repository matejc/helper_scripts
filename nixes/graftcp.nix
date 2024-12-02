{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  src = fetchFromGitHub {
    owner = "hmgle";
    repo = "graftcp";
    rev = "78ccc721c0ec50d07d2f10807d62fe3292ec1605";
    hash = "sha256-mZYfhJRKkwB1TeH7M5guU2XNpZT221VwjPtjsofniAA=";
  };

  graftcp_go = buildGoModule {
    pname = "graftcp";
    version = "unstable-2024-10-27";
    inherit src;
    sourceRoot = "${src.name}/local";
    vendorHash = "sha256-Nvw1XPcoHlKrUktXNb7KvCnaAKUJ3NEm9ZVSo5Jpsec=";
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
