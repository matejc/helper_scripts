{ pkgs }:
let
  applist = [
    {mimetypes = ["text/plain" "text/css"]; applicationExec = "${pkgs.sublime3}/bin/sublime";}
    {mimetypes = ["text/html"]; applicationExec = "${pkgs.firefox}/bin/firefox";}
  ];

  zeroArgv = cmd: builtins.head (pkgs.lib.splitString " " cmd);
  lastInPath = path: pkgs.lib.last (pkgs.lib.splitString "/" path);

  mimetype_list = pkgs.lib.flatten (map (item: (map (m: rec {
    mimetype = m;
    applicationExec = item.applicationExec;
    desktopFileName = lastInPath desktopFilePath;
    desktopFilePath = desktop_file (zeroArgv (lastInPath applicationExec)) applicationExec;
  }) item.mimetypes)) applist);

  desktop_file = desktopFileName: applicationExec:
    pkgs.writeTextFile rec {
      name = "${builtins.unsafeDiscardStringContext desktopFileName}.desktop";
      text = ''
        [Desktop Entry]
        Hidden=false
        Exec=${applicationExec}
        Type=Application
        NoDisplay=false
        Version=1.0
        StartupNotify=false
        Terminal=false
        Name=${desktopFileName}
      '';
    };

  defaults_files = map (item: item.desktopFilePath) mimetype_list;
  defaults_list = map (item: item.mimetype+"="+item.desktopFileName+";") mimetype_list;
  defaults_list_str = pkgs.lib.concatStringsSep "\n" defaults_list;
  
  mimeapps_list_file = pkgs.writeText "mimeapps.list" ''
    [Default Applications]
    ${defaults_list_str}

    [Added Associations]
    ${defaults_list_str}
  '';

  applications = pkgs.stdenv.mkDerivation {
    name = "applications";
    buildCommand = ''
      mkdir -p $out/share/applications
      for DESKTOP_FILE in ${toString (defaults_files)}
      do
        ln -sv $DESKTOP_FILE $out/share/applications || true
      done

      ln -sv ${mimeapps_list_file} $out/share/applications/mimeapps.list
    '';
  };

in applications
