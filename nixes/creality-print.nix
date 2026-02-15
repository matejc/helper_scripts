{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = "CrealityPrint";
  version = "7.0.1";
  buildVersion = "4212";

  src = pkgs.fetchurl {
    url = "https://github.com/CrealityOfficial/CrealityPrint/releases/download/v${version}/CrealityPrint_Ubuntu2404-V${version}.${buildVersion}-x86_64-Release.AppImage";
    sha256 = "sha256-M+umhMXFypw1+sjTPq1tr1WXqWBSFpLD3DsaRd5e14I=";
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
    libsm
    libice
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

    DESKTOP_ITEM="$(cat "$out/share/CrealityPrint/CrealityPrint.desktop")"
    mkdir -p $out/share/applications
    echo "$DESKTOP_ITEM" > "$out/share/applications/CrealityPrint.desktop"
    substituteInPlace $out/share/applications/CrealityPrint.desktop \
      --replace-fail 'Exec=AppRun %F' "Exec=$out/bin/${pname} %F"

    for res in 16x16 22x22 32x32 48x48 64x64 72x72 96x96 128x128 256x256 512x512
    do
      mkdir -p "$out/share/icons/hicolor/$res/apps"
      ${pkgs.imagemagick}/bin/magick $out/share/CrealityPrint/CrealityPrint.png -resize $res $out/share/icons/hicolor/$res/apps/CrealityPrint.png
    done
  '';
}
