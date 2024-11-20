{ pkgs ? import <nixpkgs> {},
  libGLSupported ? pkgs.lib.elem pkgs.stdenv.hostPlatform.system pkgs.mesa.meta.platforms,
  openglSupport ? libGLSupported,
  alsaSupport ? pkgs.stdenv.hostPlatform.isLinux && !pkgs.stdenv.hostPlatform.isAndroid,
  x11Support ? !pkgs.stdenv.hostPlatform.isWindows && !pkgs.stdenv.hostPlatform.isAndroid,
  waylandSupport ?pkgs.stdenv.hostPlatform.isLinux && !pkgs.stdenv.hostPlatform.isAndroid,
  dbusSupport ?pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAndroid,
  udevSupport ?pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAndroid,
  libdecorSupport ?pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAndroid,
  pipewireSupport ?pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAndroid,
  pulseaudioSupport ?pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAndroid,
  drmSupport ? false,
  ibusSupport ? false,
  withStatic ? pkgs.stdenv.hostPlatform.isMinGW
}:
with pkgs;
stdenv.mkDerivation (finalAttrs: {
  pname = "SDL3";
  version = "3.1.6";

  src = fetchFromGitHub {
    owner = "libsdl-org";
    repo = "SDL";
    rev = "preview-${finalAttrs.version}";
    hash = "sha256-MItZt5QeEz13BeCoLyXVUbk10ZHNyubq7dztjDq4nt4=";
  };
  dontDisableStatic = if withStatic then 1 else 0;

  strictDeps = true;

  depsBuildBuild = [ pkg-config ];

  nativeBuildInputs =
    [ pkg-config cmake ]
    ++ lib.optionals waylandSupport [
      wayland
      wayland-scanner
    ];

  dlopenPropagatedBuildInputs =
    [ ]
    # Propagated for #include <GLES/gl.h> in SDL_opengles.h.
    ++ lib.optional (openglSupport && stdenv.hostPlatform.isDarwin) libGL
    # Propagated for #include <X11/Xlib.h> and <X11/Xatom.h> in SDL_syswm.h.
    ++ lib.optionals x11Support [ xorg.libX11 ];

  propagatedBuildInputs =
    lib.optionals x11Support [ xorg.xorgproto ] ++ finalAttrs.dlopenPropagatedBuildInputs;

  dlopenBuildInputs =
    lib.optionals alsaSupport [
      alsa-lib
      audiofile
    ]
    ++ lib.optional dbusSupport dbus
    ++ lib.optional libdecorSupport libdecor
    ++ lib.optional pipewireSupport pipewire
    ++ lib.optional pulseaudioSupport libpulseaudio
    ++ lib.optional udevSupport udev
    ++ lib.optionals waylandSupport [
      wayland
      libxkbcommon
    ]
    ++ lib.optionals x11Support (with xorg; [
      libICE
      libXi
      libXScrnSaver
      libXcursor
      libXinerama
      libXext
      libXrandr
      libXxf86vm
    ])
    ++ lib.optionals drmSupport [
      libdrm
      mesa
    ];

  buildInputs =
    [ libiconv ]
    ++ finalAttrs.dlopenBuildInputs
    ++ lib.optional ibusSupport ibus
    ++ lib.optionals waylandSupport [ wayland-protocols ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      AudioUnit
      Cocoa
      CoreAudio
      CoreServices
      ForceFeedback
      OpenGL
    ];

  enableParallelBuilding = true;

  # SDL is weird in that instead of just dynamically linking with
  # libraries when you `--enable-*` (or when `configure` finds) them
  # it `dlopen`s them at runtime. In principle, this means it can
  # ignore any missing optional dependencies like alsa, pulseaudio,
  # some x11 libs, wayland, etc if they are missing on the system
  # and/or work with wide array of versions of said libraries. In
  # nixpkgs, however, we don't need any of that. Moreover, since we
  # don't have a global ld-cache we have to stuff all the propagated
  # libraries into rpath by hand or else some applications that use
  # SDL API that requires said libraries will fail to start.
  #
  # You can grep SDL sources with `grep -rE 'SDL_(NAME|.*_SYM)'` to
  # list the symbols used in this way.
  postFixup =
    let
      rpath = lib.makeLibraryPath (
        finalAttrs.dlopenPropagatedBuildInputs ++ finalAttrs.dlopenBuildInputs
      );
    in
    lib.optionalString (stdenv.hostPlatform.extensions.sharedLibrary == ".so") ''
      for lib in $out/lib/*.so* ; do
        if ! [[ -L "$lib" ]]; then
          patchelf --set-rpath "$(patchelf --print-rpath $lib):${rpath}" "$lib"
        fi
      done
    '';
})
