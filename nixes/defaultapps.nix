# 1. declare mimetypes and assign application to it inside 'applist' variable
# 2. backup
# 3. ln -sf `nix-build defaultapps.nix`/* ~/.local/share/applications/

# and now
# xdg-open /path/to/some/file.ext
# will open with correct application

let
  pkgs = import <nixpkgs> {};

  applist = [
    {mimetypes = ["text/plain" "text/css"]; applicationName = "Sublime"; applicationExec = "${pkgs.sublime3}/bin/sublime";}
    {mimetypes = ["text/html"]; applicationName = "Firefox"; applicationExec = "${pkgs.firefox}/bin/firefox";}
  ];

  mimetype_list = pkgs.lib.flatten (map (item: (map (m: rec {
    mimetype = m; desktopFileName = (pkgs.lib.last (pkgs.lib.splitString "/" desktopFilePath)); desktopFilePath = (desktop_file item.applicationName item.applicationExec);
  }) item.mimetypes)) applist);

  defaults_list_str = pkgs.lib.concatStringsSep "\n" (map (item: item.mimetype+"="+item.desktopFileName+";") mimetype_list);

  defaults_list_file = pkgs.writeText "defaults.list" defaults_list_str;
  
  desktop_file = applicationName: applicationExec: pkgs.writeText "${applicationName}.desktop" ''
    [Desktop Entry]
    Hidden=false
    Exec=${applicationExec}
    Type=Application
    NoDisplay=false
    Version=1.0
    StartupNotify=false
    Terminal=false
    Name=${applicationName}
  '';
  
  desktop_files = map (item: desktop_file item.applicationName item.applicationExec) applist;

  mimeapps_list_file = pkgs.writeText "mimeapps.list" ''
    [Default Applications]
    ${defaults_list_str}

    [Added Associations]
    ${defaults_list_str}
  '';

  applications = pkgs.stdenv.mkDerivation {
    name = "applications";
    buildCommand = ''
      mkdir -p $out
      for DESKTOP_FILE in ${toString (desktop_files)}
      do
        ln -s $DESKTOP_FILE $out
      done

      ln -s ${defaults_list_file} $out/defaults.list
      ln -s ${mimeapps_list_file} $out/mimeapps.list
    '';
  };

in applications