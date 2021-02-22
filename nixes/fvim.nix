{ stdenv, fetchurl, lib, dpkg, makeWrapper, openssl, zlib, fontconfig, curl
, krb5, lttng-ust, dotnetCorePackages, xorg, expat, numactl, libglvnd }:
let
  version = "0.2.348";
  gitHash = "81a158c";
in
stdenv.mkDerivation rec {
  pname = "fvim";
  inherit version;

  src = fetchurl {
    url =
      "https://github.com/yatli/fvim/releases/download/v${version}%2B${gitHash}/fvim-linux.deb";
    sha256 = "06b0vfpjcjgx3pi1d937nl5mldj9ws0vy7lcfzspvqzjwfbknwn0";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = "dpkg -x $src ./";

  installPhase = ''
    mkdir -p $out/bin $out/share
    mv ./usr/share/* $out/share/

    makeWrapper $out/share/fvim/FVim $out/bin/fvim \
      --set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT "1" \
      --set LD_LIBRARY_PATH "$out/share/fvim:${lib.makeLibraryPath [
        openssl stdenv.cc.cc zlib fontconfig curl krb5 lttng-ust
        xorg.libX11 expat xorg.libXrandr xorg.libXi xorg.libXcursor
        numactl libglvnd
      ]}"

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
       $out/share/fvim/FVim
  '';

  dontStrip = true;
}
