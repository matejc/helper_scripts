{pkgs ? import <nixpkgs> {}}:
let

  hawaiiSchemas = pkgs.stdenv.mkDerivation {
    name = "hawaii-schemas";
    phases = "buildPhase";
    buildPhase = ''
      mkdir -p $out/share/glib-2.0/schemas

      cp ${pkgs.hawaii.hawaii-workspace}/share/gsettings-schemas/hawaii-workspace/glib-2.0/schemas/* $out/share/glib-2.0/schemas/

      substituteInPlace $out/share/glib-2.0/schemas/org.hawaiios.desktop.lockscreen.gschema.xml \
        --replace "${pkgs.hawaii.hawaii-workspace}/share/backgrounds" "${pkgs.hawaii.hawaii-wallpapers}/share/backgrounds"
      substituteInPlace $out/share/glib-2.0/schemas/org.hawaiios.desktop.background.gschema.xml \
        --replace "${pkgs.hawaii.hawaii-workspace}/share/backgrounds" "${pkgs.hawaii.hawaii-wallpapers}/share/backgrounds"

      #cp ${pkgs.gnome3.gsettings_desktop_schemas}/share/gsettings-schemas/gsettings-desktop-schemas-3.20.0/glib-2.0/schemas/* $out/share/glib-2.0/schemas/

      export GSETTINGS_SCHEMAS_PATH="$out/share"
      export XDG_DATA_DIRS="$GSETTINGS_SCHEMAS_PATH"

      ${pkgs.glib.dev}/bin/glib-compile-schemas $out/share/glib-2.0/schemas --targetdir=$out/share/glib-2.0/schemas

      ${pkgs.glib.dev}/bin/gsettings list-schemas
    '';
  };

  qt5 = pkgs.qt56;

  env = pkgs.buildEnv {
    name = "hawaii-env";
    paths = [
      qt5.qtquickcontrols.out
      qt5.qtquickcontrols2.out
      qt5.qtdeclarative.out
      qt5.qtwayland.out
      qt5.qtgraphicaleffects.out
      qt5.qtbase.out
    ] ++ (with pkgs; [
      hawaii.fluid
      hawaii.greenisland
      hawaii.hawaii-icon-theme
      hawaii.hawaii-plymouth-theme
      hawaii.hawaii-shell
      hawaii.hawaii-system-preferences
      hawaii.hawaii-wallpapers
      hawaii.hawaii-widget-styles
      hawaii.hawaii-workspace
      hawaii.libhawaii
      hawaii.qtconfiguration
      hawaiiSchemas

      weston glib.dev gnome3.dconf
      mesa mesa.out mesa_drivers
    ]);
  };

  envVars = pkgs.writeScript "envVars" ''
    #!/bin/sh
    export VNCFONTS="${pkgs.xorg.fontmiscmisc}/lib/X11/fonts/misc,${pkgs.xorg.fontcursormisc}/lib/X11/fonts/misc"

    export PATH="$PATH:${env}/bin"

    export GSETTINGS_SCHEMAS_PATH="${env}/share"
    export XDG_DATA_DIRS="$GSETTINGS_SCHEMAS_PATH"
    export LD_LIBRARY_PATH=${env}/lib:$LD_LIBRARY_PATH
    export QT_PLUGIN_PATH=${env}/lib/qt5/plugins
    export QT_QPA_PLATFORM=greenisland
    #export GDK_BACKEND=wayland
    #export CLUTTER_BACKEND=wayland
    #export SDL_VIDEODRIVER=wayland
    export DISPLAY=:99
    export WAYLAND_DISPLAY=greenisland-seat0
    export QML2_IMPORT_PATH="${env}/lib/qt5/qml"
    export XDG_RUNTIME_DIR=/tmp/hawaii/greenisland
    export HOME=/tmp/hawaii
    export QML_IMPORT_PATH="${env}/lib/qt5/imports"
    export RUNTIME_XDG_DATA_DIRS="${env}/share"
    export RUNTIME_XDG_CONFIG_DIRS="${env}/etc/xdg"
    export PKG_CONFIG_PATH=${env}/lib/pkgconfig/:$PKG_CONFIG_PATH
    export GREENISLAND_QPA_INTEGRATION=kms
    export GBM_DRIVERS_PATH=${pkgs.mesa_drivers}/lib/dri

    echo $@
    "$@"
  '';

  s = name: pkgs.writeScript "strace.sh" ''
    #!/bin/sh
    source ${envVars} true
    ${pkgs.strace}/bin/strace -o /tmp/strace_${name}.log $@
  '';

  hawaiiBin = pkgs.writeScript "hawaii.sh" ''
    #!/bin/sh
    source ${envVars} true

    find $HOME

    #su matejc -c "${envVars} ${pkgs.dbus.out}/bin/dbus-launch ${s "matejc-hawaii"} ${env}/bin/hawaii $@"
    ${s "hawaii"} ${env}/bin/hawaii $@
  '';

  hawaiiRun = pkgs.writeScript "hawaii-run.sh" ''
    #!/bin/sh
    source ${envVars} true
    set -e

    mkdir -p $XDG_RUNTIME_DIR
    #chown -R matejc:users $XDG_RUNTIME_DIR
    chmod -R 0700 $XDG_RUNTIME_DIR

    mkdir -p $HOME/.config/greenisland
    echo '{ "kms": { "device": "/dev/dri/card0", "hwcursor": true } }' > $HOME/.config/greenisland/platform.json

    echo ${env}


    # openvt -v -f -c 8 --
    ${pkgs.dbus.out}/bin/dbus-launch  openvt -v -f -c 8 -- ${s "launcher"} greenisland-launcher --mode=eglfs --execute="${hawaiiBin}"
  '';
in pkgs.stdenv.mkDerivation {
  name = "hawaii";
  shellHook = ''
    alias envVars="${envVars}"
    source ${envVars} true
    sudo ${hawaiiRun}
  '';
}
