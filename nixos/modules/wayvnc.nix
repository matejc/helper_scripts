{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.wayvnc;
  envFile = pkgs.writeScript "sway-env.sh" ''
    export XDG_RUNTIME_DIR=/run/user/${toString config.users.users.${cfg.user}.uid}
    export WAYLAND_DISPLAY=wayland-1
    export XDG_SESSION_TYPE=wayland
    export WLR_BACKENDS=headless
    export WLR_RENDERER=pixman
    export WLR_NO_HARDWARE_CURSORS=1
    unset DISPLAY
  '';
in
{

  ###### interface

  options = {

    services.wayvnc = {
      enable = mkEnableOption "wayvnc server";

      listen = mkOption {
        type = types.str;
        default = "localhost:5900";
        description = ''
          Specifies where wayvnc listens.
        '';
      };

      user = mkOption {
        type = types.str;
        description = ''
          Specifies the user.
        '';
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    security.pam.services.su.startSession = true;

    systemd = {
      services.wayvnc = {
        wantedBy = [ "multi-user.target" ];
        after = [ "sway.service" ];
        description = "wayvnc service";
        serviceConfig = {
          Type = "simple";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
          ExecStart = ''${config.security.wrapperDir}/su - ${cfg.user} -c "source ${envFile} && ${pkgs.wayvnc}/bin/wayvnc"'';
          ExecStop  = "${pkgs.coreutils}/bin/kill -INT $MAINPID";
        };
      };

      services.sway = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        description = "headless sway session service";
        serviceConfig = {
          Type = "simple";
          ExecStart = ''${config.security.wrapperDir}/su - ${cfg.user} -c "source ${envFile} && ${pkgs.sway}/bin/sway"'';
          ExecStop  = "${pkgs.coreutils}/bin/kill -INT $MAINPID";
        };
      };

    };
  };

}
