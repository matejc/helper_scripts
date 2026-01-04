{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = "CrealityPrint";
  version = "7.0.0";
  buildVersion = "4127";

  src = pkgs.fetchurl {
    url = "https://github.com/CrealityOfficial/CrealityPrint/releases/download/v${version}/CrealityPrint-V${version}.${buildVersion}-x86_64-Release.AppImage";
    sha256 = "sha256-J3oVSp6mR5qmm9zNcFQTqK+A0XAJSmVYzC3hKWQOjr4=";
  };
in
pkgs.stdenv.mkDerivation {
  inherit pname;
  version = "${version}.${buildVersion}";

  src = src;

  nativeBuildInputs = with pkgs; [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    libdeflate
    bzip2
    xorg.libSM
    xorg.libICE
    webkitgtk_4_1
    libsecret
    nss
    nspr
    glib-networking
    makeWrapper
  ];

  dontBuild = true;

  unpackPhase = ''
    cp $src ./${pname}.AppImage
    chmod +x ./${pname}.AppImage
    ./${pname}.AppImage --appimage-extract
  '';

  installPhase = ''
    mkdir -p $out/share
    mv squashfs-root $out/share/${pname}
    mkdir -p $out/bin
    makeWrapper $out/share/${pname}/AppRun $out/bin/${pname} \
      --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set GIO_MODULE_DIR "${pkgs.glib-networking}/lib/gio/modules" \
      --set TMPDIR /tmp
  '';
}
