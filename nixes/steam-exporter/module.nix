{ pkgs, lib, config, ... }:
let
  cfg = config.services.steam-exporter;
  package = import ./default.nix { inherit pkgs; };
in
{
  options.services.steam-exporter = {
    enable = lib.mkEnableOption "Enable steam-exporter";
    userId = lib.mkOption {
      type = lib.types.str;
      description = ''
        Steam user id (To get your Steam User ID. Login and go to 'view profile'.
        It should be in the URL bar where xxxxxx is: https://steamcommunity.com/profiles/xxxxxx)
      '';
    };
    steamKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/steam-exporter/key";
      description = "To get a steam key, sign up for one here: https://steamcommunity.com/dev";
    };
    sleep = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "How long to sleep in seconds";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Listening port";
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.steam-exporter = {
      isSystemUser = true;
      group = "steam-exporter";
      home = "/var/lib/steam-exporter";
      createHome = true;
    };
    users.groups.steam-exporter = {};
    systemd.services.steam-exporter = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Steam Exporter";
      serviceConfig = {
        Type = "simple";
        User = "steam-exporter";
        Group = "steam-exporter";
        ExecStart = pkgs.writeScript "steam-exporter.sh" ''
          #!${pkgs.stdenv.shell}
          set -e
          export STEAM_KEY="$(cat ${cfg.steamKeyPath})"
          ${package}/bin/steam-exporter ${cfg.userId} -port ${toString cfg.port} -sleep ${toString cfg.sleep}
        '';
        Restart = "always";
      };
    };
  };
}
