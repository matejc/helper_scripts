{pkgs ? import <nixpkgs> {}}:
let

  hawaiiSchemas = pkgs.stdenv.mkDerivation {
    name = "hawaii-schemas";
    phases = "buildPhase";
    buildPhase = ''
      mkdir -p $out/share/glib-2.0/schemas
      #cp ${pkgs.hawaii.hawaii-workspace}/share/glib-2.0/schemas/* $out/share/glib-2.0/schemas/
      cp ${pkgs.hawaii.hawaii-workspace}/share/gsettings-schemas/hawaii-workspace/glib-2.0/schemas/* $out/share/glib-2.0/schemas/
      substituteInPlace $out/share/glib-2.0/schemas/org.hawaiios.desktop.lockscreen.gschema.xml \
        --replace "${pkgs.hawaii.hawaii-workspace}/share/backgrounds" "${pkgs.hawaii.hawaii-wallpapers}/share/backgrounds"
      substituteInPlace $out/share/glib-2.0/schemas/org.hawaiios.desktop.background.gschema.xml \
        --replace "${pkgs.hawaii.hawaii-workspace}/share/backgrounds" "${pkgs.hawaii.hawaii-wallpapers}/share/backgrounds"
      ${pkgs.glib.dev}/bin/glib-compile-schemas $out/share/glib-2.0/schemas/

      export GSETTINGS_SCHEMAS_PATH="$out/share"
      export XDG_DATA_DIRS="$GSETTINGS_SCHEMAS_PATH"
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

      weston
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
    export QT_QPA_PLATFORM=wayland
    export GDK_BACKEND=wayland
    export CLUTTER_BACKEND=wayland
    export SDL_VIDEODRIVER=wayland
    export DISPLAY=:1
    #export WAYLAND_DISPLAY=wayland-0
    export QML2_IMPORT_PATH="${env}/lib/qt5/qml"
    export XDG_RUNTIME_DIR=/home/matejc/.xdg
    export QML_IMPORT_PATH="${env}/lib/qt5/imports"
    export RUNTIME_XDG_DATA_DIRS="${env}/share"
    export RUNTIME_XDG_CONFIG_DIRS="${env}/etc/xdg"

    echo $@
    "$@"
  '';

  s = pkgs.writeScript "strace.sh" ''
    #!/bin/sh
    ${pkgs.strace}/bin/strace -o /tmp/strace.log $@
  '';

  hawaiiBin = pkgs.writeScript "hawaii.sh" ''
    #!/bin/sh
    su matejc -c "${envVars} ${pkgs.dbus.out}/bin/dbus-launch ${env}/bin/hawaii $@"
  '';

  hawaiiRun = pkgs.writeScript "hawaii-run.sh" ''
    #!/bin/sh
    set -e

    mkdir -p /home/matejc/.xdg
    chown -R matejc:users /home/matejc/.xdg
    chmod -R 0700 /home/matejc/.xdg

    echo ${hawaiiBin}

    ${envVars} openvt -v -f -c 8 -- ${s} greenisland-launcher --execute "${hawaiiBin}" --mode wayland

  '';
in pkgs.stdenv.mkDerivation {
  name = "hawaii";
  shellHook = ''
    alias envVars="${envVars}"
    source ${envVars} true
    sudo ${hawaiiRun}
  '';
}
