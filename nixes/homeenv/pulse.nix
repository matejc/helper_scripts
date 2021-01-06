{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.pulse;
  configFile = pkgs.writeText "default.pa" ''
    load-module module-esound-protocol-tcp auth-anonymous=1
    load-module module-native-protocol-tcp auth-ip-acl=${cfg.acl}
  '';
in
{

  ###### interface

  options = {

    services.pulse = {
      enable = mkEnableOption "Pulseaudio";

      package = mkOption {
        type = types.package;
        default = pkgs.pulseaudio;
        defaultText = "pkgs.pulseaudio";
        description = ''
          The package to use for the pulseaudio daemon's binary.
        '';
      };

      acl = mkOption {
        type = types.str;
        default = "127.0.0.1;172.24.32.0/20";
        description = ''
          ACL rules for auth.
        '';
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    home.file.".pulse/default.pa".source = configFile;

    systemd.user = {
      services.pulse = {
        Unit = {
          Description = "Pulseaudio daemon";
        };
        Service = {
          ExecStart = "${cfg.package}/bin/pulseaudio -L module-native-protocol-tcp --daemonize=no --log-target=journal";
          LockPersonality = "yes";
          MemoryDenyWriteExecute = "yes";
          NoNewPrivileges = "yes";
          Restart = "on-failure";
          RestrictNamespaces = "yes";
          SystemCallArchitectures = "native";
          SystemCallFilter = "@system-service";
          Type = "notify";
          UMask = "0077";
        };
      };
    };
  };
}
