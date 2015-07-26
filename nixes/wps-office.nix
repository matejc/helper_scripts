{ stdenv, fetchurl, buildEnv, makeWrapper, dpkg, elfutils, xlibs, phonon
, freetype, fontconfig, glib, zlib, libpng12, qt4, cups
}:

let

  wpsEnv = buildEnv {
    name = "wps-office-env";
    paths = [ xlibs.libX11 stdenv.cc freetype phonon fontconfig glib zlib
      libpng12 xlibs.libSM xlibs.libICE xlibs.libXrender xlibs.libXext qt4
      cups ];
  };

  arch =
    if stdenv.system == "x86_64-linux" then "amd64"
    else if stdenv.system == "i686-linux" then "i386"
    else throw "unsupported system";

in stdenv.mkDerivation rec {
  name = "wps-office_${version}";
  version = "9.1.0.4961-a18p1";

  src = {
    outPath = "/var/public/${name}_${arch}.deb";
    name = "${name}.deb";
  };

  buildInputs = [ dpkg wpsEnv makeWrapper ];

  unpackPhase = ''
    mkdir pkg
    dpkg-deb -x $src pkg
    sourceRoot=pkg
  '';

  installPhase = ''
    mkdir -p $out

    cp -r ./{opt,etc} $out/
    cp -r ./usr/* $out/


    for i in $out/bin/*; do
      substituteInPlace $i \
        --replace "/opt/kingsoft/wps-office" "$out/opt/kingsoft/wps-office"
      wrapProgram $i \
        --prefix PATH ':' ${elfutils}/bin \
        --set LD_LIBRARY_PATH "$out/opt/kingsoft/wps-office/office6:${wpsEnv}/lib"
    done

    for i in $out/opt/kingsoft/wps-office/office6/{wps,wpp,et}; do
      patchelf \
        --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $i
    done
  '';

  meta = with stdenv.lib; {
    description = "Kingsoft Office is a simple, powerful office suite with a confortable interface";
    homepage = http://wps-community.org/;
    license = licenses.unfree;
    maintainers = [ maintainers.matejc ];
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
