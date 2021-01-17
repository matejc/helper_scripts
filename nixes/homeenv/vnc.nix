{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vnc;
  xstartup = pkgs.writeScript "xstartup" ''
    #!/bin/sh
    . /etc/profile
    [ -x $HOME/.profile ] && . $HOME/.profile
    [ -r $HOME/.Xresources ] && ${pkgs.xorg.xrdb}/bin/xrdb $HOME/.Xresources
    ${pkgs.dbus}/bin/dbus-launch --exit-with-session ${cfg.startCmd}
  '';
in
{

  ###### interface

  options = {

    services.vnc = {

      enable = mkEnableOption "TigerVNC, the VNC server";

      package = mkOption {
        type = types.package;
        default = pkgs.tigervnc;
        defaultText = "pkgs.tigervnc";
        description = ''
          The package to use for the VNC daemon's binary.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 5999;
        description = ''
          Specifies on which port VNC server listens.
        '';
      };

      display = mkOption {
        type = types.int;
        default = 99;
        description = ''
          Specifies display number.
        '';
      };

      startCmd = mkOption {
        type = types.str;
        default = "i3";
        description = ''
          Desktop/window manager command.
        '';
      };

      password = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          VNC password.
        '';
      };

      locale = mkOption {
        type = types.str;
        default = "en_US.UTF-8";
        description = ''
          VNC Locale.
        '';
      };

    };
  };


  ###### implementation

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user = {
      services.vnc = {
        Unit = {
          Description = "vnc server";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          EnvironmentFile = builtins.toString (pkgs.writeText "vnc.env" ''
            LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"
            LC_ALL="${cfg.locale}"
            LANG="${cfg.locale}"
            LANGUAGE="${cfg.locale}"
          '');
          ExecStartPre = builtins.toString (pkgs.writeScript "vnc-pre-start.sh" ''
            #!${pkgs.stdenv.shell}
            mkdir $HOME/.vnc
            ln -fs ${xstartup} $HOME/.vnc/xstartup
            ${optionalString (cfg.password != null) ''
              ${cfg.package}/bin/vncpasswd -f <<<"${cfg.password}" >"$HOME/.vnc/passwd"
            ''}
          '');
          ExecStart = "${cfg.package}/bin/vncserver :${toString cfg.display} -localhost -fg -autokill -depth 24 -geometry 1920x1080 -rfbport ${toString cfg.port}";
          ExecStop = "${cfg.package}/bin/vncserver -kill :${toString cfg.display}";
        };
      };
    };
  };

}
