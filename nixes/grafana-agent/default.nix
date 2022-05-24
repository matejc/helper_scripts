{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.services.grafana-agent;
in {
  options.services.grafana-agent = {
    enable = mkEnableOption "grafana-agent";

    configFile = mkOption {
      type = types.str;
      default = "/etc/grafana-agent.yaml";
      description = ''
        Config file
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.grafana-agent;
      description = ''
        Package
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.grafana-agent.isSystemUser = true;
    users.users.grafana-agent.group = "grafana-agent";
    users.users.grafana-agent.extraGroups = [ "systemd-journal" ];
    users.groups.grafana-agent = {};

    systemd.services.grafana-agent = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = " A Grafana Agent service";
      serviceConfig = {
        User = "grafana-agent";
        Group = "grafana-agent";
        ExecStart = "${cfg.package}/bin/agent -config.file=${cfg.configFile}";
        Restart = "always";
      };
    };
  };
}
