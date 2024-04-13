{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xrdp;
  confDir = pkgs.runCommand "xrdp.conf" { preferLocalBuild = true; } ''
    mkdir $out

    cp ${cfg.package}/etc/xrdp/{km-*,xrdp,sesman,xrdp_keyboard}.ini $out

    cat > $out/startwm.sh <<EOF
    #!/bin/sh
    . /etc/profile
    ${cfg.defaultWindowManager}
    EOF
    chmod +x $out/startwm.sh

    substituteInPlace $out/xrdp.ini \
      --replace "#rsakeys_ini=" "rsakeys_ini=/run/xrdp/rsakeys.ini" \
      --replace "certificate=" "certificate=${cfg.sslCert}" \
      --replace "key_file=" "key_file=${cfg.sslKey}" \
      --replace LogFile=xrdp.log LogFile=/dev/null \
      --replace EnableSyslog=true EnableSyslog=false

    substituteInPlace $out/sesman.ini \
      --replace LogFile=xrdp-sesman.log LogFile=/dev/null \
      --replace EnableSyslog=1 EnableSyslog=0
  '';


  xrdp-start = pkgs.writeScriptBin "xrdp-start" ''
    #!${pkgs.stdenv.shell}

    # prepare directory for unix sockets (the sockets will be owned by loggedinuser:xrdp)
    mkdir -p /tmp/.xrdp || true
    chmod 3777 /tmp/.xrdp

    # generate a self-signed certificate
    if [ ! -s ${cfg.sslCert} -o ! -s ${cfg.sslKey} ]; then
      mkdir -p $(dirname ${cfg.sslCert}) || true
      mkdir -p $(dirname ${cfg.sslKey}) || true
      ${pkgs.openssl.bin}/bin/openssl req -x509 -newkey rsa:2048 -sha256 -nodes -days 365 \
        -subj /C=US/ST=CA/L=Sunnyvale/O=xrdp/CN=www.xrdp.org \
        -config ${cfg.package}/share/xrdp/openssl.conf \
        -keyout ${cfg.sslKey} -out ${cfg.sslCert}
      chmod 440 ${cfg.sslKey} ${cfg.sslCert}
    fi
    if [ ! -s ${config.home.homeDirectory}/.xrdp/rsakeys.ini ]; then
      mkdir -p ${config.home.homeDirectory}/.xrdp
      ${cfg.package}/bin/xrdp-keygen xrdp ${config.home.homeDirectory}/.xrdp/rsakeys.ini
    fi

    ${cfg.package}/bin/xrdp --nodaemon --port ${toString cfg.port} --config ${confDir}/xrdp.ini "$@"
  '';

  xrdp-sesman-start = pkgs.writeScriptBin "xrdp-sesman-start" ''
    #!${pkgs.stdenv.shell}

    ${cfg.package}/bin/xrdp-sesman --nodaemon --config ${confDir}/sesman.ini "$@"
  '';
in
{

  ###### interface

  options = {

    services.xrdp = {

      enable = mkEnableOption "xrdp, the Remote Desktop Protocol server";

      package = mkOption {
        type = types.package;
        default = pkgs.xrdp;
        defaultText = "pkgs.xrdp";
        description = ''
          The package to use for the xrdp daemon's binary.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 3389;
        description = ''
          Specifies on which port the xrdp daemon listens.
        '';
      };

      sslKey = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/.xrdp/key.pem";
        example = "/path/to/your/key.pem";
        description = ''
          ssl private key path
          A self-signed certificate will be generated if file not exists.
        '';
      };

      sslCert = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/.xrdp/cert.pem";
        example = "/path/to/your/cert.pem";
        description = ''
          ssl certificate path
          A self-signed certificate will be generated if file not exists.
        '';
      };

      defaultWindowManager = mkOption {
        type = types.str;
        default = "xterm";
        example = "xfce4-session";
        description = ''
          The script to run when user log in, usually a window manager, e.g. "icewm", "xfce4-session"
          This is per-user overridable, if file ~/startwm.sh exists it will be used instead.
        '';
      };

    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [ cfg.package xrdp-start xrdp-sesman-start ];
    systemd.user = {
      services.xrdp = {
        Unit = {
          Description = "xrdp daemon";
        };
        Service = {
          ExecStart = "${xrdp-start}/bin/xrdp-start";
        };
      };

      services.xrdp-sesman = {
        Unit = {
          Description = "xrdp session manager";
          X-RestartIfChanged = false;
        };
        Service = {
          ExecStart = "${xrdp-sesman-start}/bin/xrdp-sesman-start";
          ExecStop  = "${pkgs.coreutils}/bin/kill -INT $MAINPID";
        };
      };

    };
  };

}
