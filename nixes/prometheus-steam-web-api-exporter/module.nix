{ pkgs, lib, config, ... }:
let
  cfg = config.services.prometheus-steam-web-api-exporter;
  package = import ./default.nix { inherit pkgs; };
in
{
  options.services.prometheus-steam-web-api-exporter = {
    enable = lib.mkEnableOption "Enable steam-exporter";
    steamIDs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        Steam user id list (To get your Steam User ID. Login and go to 'view profile'.
      '';
    };
    steamKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/prometheus-steam-web-api-exporter/key";
      description = "To get a steam key, sign up for one here: https://steamcommunity.com/dev";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 6630;
      description = "Listening port";
    };
    address = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Listening address";
    };
    collectors = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["playtime" "price" "achievements"]);
      default = [ "playtime" "achievements" "price" ];
      description = "List of collectors";
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.prometheus-steam-exporter = {
      isSystemUser = true;
      group = "prometheus-steam-exporter";
      home = "/var/lib/prometheus-steam-web-api-exporter";
      createHome = true;
    };
    users.groups.prometheus-steam-exporter = {};
    systemd.services.prometheus-steam-web-api-exporter = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Prometheus Steam Web API Exporter";
      serviceConfig = {
        Type = "simple";
        User = "prometheus-steam-exporter";
        Group = "prometheus-steam-exporter";
        ExecStart = pkgs.writeScript "prometheus-steam-web-api-exporter.sh" ''
          #!${pkgs.stdenv.shell}
          set -e
          export STEAM_API_KEY="$(cat ${cfg.steamKeyPath})"
          ${package}/bin/prometheus-steam-web-api-exporter --port=${toString cfg.port} --address=${cfg.address} --steam-ids=${lib.concatStringsSep "," cfg.steamIDs} --collectors=${lib.concatStringsSep "," cfg.collectors}
        '';
        Restart = "always";
      };
    };
  };
}
