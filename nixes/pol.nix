{ pkgs ? import <nixpkgs> {}, destination ? "/var/lib/POL" }:
let
  src = pkgs.fetchgit {
    url = git://github.com/PlayOnLinux/POL-POM-4;
    rev = "refs/tags/4.2.7";
    sha256 = "1rx9shxyz7j88r4h1gk5m0rfqc17a8dhyq3gqnqpbcxknqbypgb4";
  };

  pydeps = pkgs.buildEnv {
    name = "pydeps";
    paths = with pkgs.pythonPackages; [ wxPython ];
  };

  sysdeps = pkgs.buildEnv {
    name = "sysdeps";
    paths = with pkgs; [ bash which python coreutils gnused netcat gawk gnugrep
      gnutar procps cabextract imagemagick wget curl gnupg1compat xterm gettext
      icoutils unzip p7zip wineUnstable sudo xdg-user-dirs bzip2 findutils perl
      file ];
    ignoreCollisions = true;
  };

  setupBin = pkgs.writeScriptBin "pol-setup" ''
    #!${pkgs.stdenv.shell}
    test -f ${destination}/playonlinux || {
      mkdir -p ${destination} &&
      cp -r ${src}/* ${destination};
    }

    export PATH="${sysdeps}/bin"

    interpreter="`realpath ${pkgs.glibc}/lib/ld-linux*so.2`"
    interpreter32="`realpath ${pkgs.pkgsi686Linux.glibc}/lib/ld-linux*so.2`"

    {
      chmod -R u+w ${destination}/bin &&
      ${pkgs.findutils}/bin/find ${destination}/bin -iname "*.bz2" -exec bzip2 -d '{}' \; &&
      ${pkgs.patchelf}/bin/patchelf --set-interpreter $interpreter --set-rpath "${pkgs.xlibs.libX11}/lib" ${destination}/bin/check_dd_amd64 &&
      ${pkgs.patchelf}/bin/patchelf --set-interpreter $interpreter32 --set-rpath "${pkgs.pkgsi686Linux.xlibs.libX11}/lib" ${destination}/bin/check_dd_x86 &&
      ${pkgs.findutils}/bin/find ${destination}/bin -type f -exec bzip2 -z '{}' \; ;
    }

    RPATH32="${pkgs.pkgsi686Linux.xlibs.libX11}/lib:${pkgs.pkgsi686Linux.xlibs.libXext}/lib:${pkgs.pkgsi686Linux.freetype}/lib:${pkgs.pkgsi686Linux.alsaLib}/lib"

    ${pkgs.findutils}/bin/find $HOME/.PlayOnLinux/wine/linux-x86/ -type f -exec ${pkgs.patchelf}/bin/patchelf \
      --set-interpreter $interpreter32 '{}' \;

    ${pkgs.findutils}/bin/find $HOME/.PlayOnLinux/wine/linux-x86/ -type f -exec ${pkgs.patchelf}/bin/patchelf \
      --set-rpath "$RPATH32" '{}' \;

    ${pkgs.findutils}/bin/find $HOME/.PlayOnLinux/wineprefix/ -iwholename "*drive_c/windows/system32*" -type f -exec ${pkgs.patchelf}/bin/patchelf \
      --set-interpreter $interpreter32 '{}' \;

    ${pkgs.findutils}/bin/find $HOME/.PlayOnLinux/wineprefix/ -iwholename "*drive_c/windows/system32*" -type f -exec ${pkgs.patchelf}/bin/patchelf \
      --set-rpath "$RPATH32" '{}' \;

    true
  '';

  runEnv = pkgs.writeScriptBin "pol-env" ''
    #!${pkgs.stdenv.shell}
    cd ${destination}
    export PATH="${destination}:${sysdeps}/bin"
    export PYTHONPATH="${pydeps}/lib/${pkgs.python.libPrefix}/site-packages:${destination}"

    "$@"
  '';

in pkgs.buildEnv {
  name = "PlayOnLinux";
  paths = [ setupBin runEnv ];
  pathsToLink = [ "/bin" ];
}
