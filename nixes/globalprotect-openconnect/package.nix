{ callPackage, rustPlatform, fetchurl, perl, openconnect, pkg-config
, webkitgtk, libsoup, stdenv, buildEnv }:
let
  pname = "globalprotect-openconnect";
  version = "2.1.0";
  src = fetchurl {
    url = "https://github.com/yuezk/GlobalProtect-openconnect/releases/download/v${version}/globalprotect-openconnect-${version}.tar.gz";
    hash = "sha256-uXKV0QaRFWw+UBOLaavIQxeVyTXV3B/+lX1P5snx1IM=";
  };
in
  rustPlatform.buildRustPackage rec {
    inherit pname version src;

    preConfigure = ''
      substituteInPlace crates/gpapi/src/lib.rs \
        --replace-fail "/usr/bin/" "$out/bin/" \
        --replace-fail 'dotenvy_macro::dotenv!("GP_CLIENT_BINARY");' "\"$out/bin/gpclient\";" \
        --replace-fail 'dotenvy_macro::dotenv!("GP_SERVICE_BINARY");' "\"$out/bin/gpservice\";" \
        --replace-fail 'dotenvy_macro::dotenv!("GP_GUI_BINARY");' "\"$out/bin/gpgui\";" \
        --replace-fail 'dotenvy_macro::dotenv!("GP_GUI_HELPER_BINARY");' "\"$out/bin/gpgui-helper\";" \
        --replace-fail 'dotenvy_macro::dotenv!("GP_AUTH_BINARY");' "\"$out/bin/gpauth\";"
    '';

    cargoBuildFlags = [ "-p gpclient" "-p gpservice" "-p gpauth" ];

    nativeBuildInputs = [ perl pkg-config ];
    buildInputs = [ openconnect libsoup webkitgtk ];

    cargoSha256 = "sha256-ggWS7LXJRn1/gwUxM1MToxlYcZ4Sr8tRLLwvRy7uM/0=";
  }
