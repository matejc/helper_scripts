{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.services.grafana-agent;

  defaultConfig = import ./config.nix { inherit pkgs lib config; inherit (cfg) lokiUrl prometheusUrl; };

  configJSON = builtins.toJSON (lib.attrsets.recursiveUpdate defaultConfig cfg.config);
in {
  options.services.grafana-agent = {
    enable = mkEnableOption "grafana-agent";

    config = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Config
      '';
    };

    lokiUrl = mkOption {
      type = types.str;
      default = null;
      description = ''
        Loki url
      '';
    };

    prometheusUrl = mkOption {
      type = types.str;
      default = null;
      description = ''
        Prometheus url
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

    environment.etc."grafana-agent.json".text = configJSON;

    systemd.services.grafana-agent = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = " A Grafana Agent service";
      serviceConfig = {
        User = "grafana-agent";
        Group = "grafana-agent";
        ExecStart = "${cfg.package}/bin/agent -config.file=/etc/grafana-agent.json";
        Restart = "always";
      };
    };
  };
}
