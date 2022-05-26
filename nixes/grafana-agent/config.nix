{ pkgs, lib, config, lokiUrl, prometheusUrl }:
{
  integrations = {
    node_exporter = {
      enabled = true;
      relabel_configs = [{
        replacement = config.networking.hostName;
        source_labels = [ "__address__" ];
        target_label = "instance";
      }];
    };
  };
  logs = {
    configs = [{
      clients = [(lib.optionalAttrs (lokiUrl != null) {
        url = lokiUrl;
      })];
      name = "integrations";
      scrape_configs = [{
        job_name = "integrations/node_exporter_journal_scrape";
        journal = {
          labels = {
            instance = config.networking.hostName;
            job = "integrations/node_exporter";
          };
          max_age = "24h";
        };
        relabel_configs = [
          {
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          }
          {
            source_labels = [ "__journal__boot_id" ];
            target_label = "boot_id";
          }
          {
            source_labels = [ "__journal__transport" ];
            target_label = "transport";
          }
          {
            source_labels = [ "__journal_priority_keyword" ];
            target_label = "level";
          }
        ];
      }];
    }];
    positions_directory = "/tmp/positions.yaml";
  };
  metrics = {
    configs = [{
      name = "default";
      scrape_configs = [{ job_name = "agent"; }];
    }];
    global = {
      remote_write = [(lib.optionalAttrs (prometheusUrl != null) {
        url = prometheusUrl;
      })];
    };
    wal_directory = "/tmp/wal";
  };
  server = { log_level = "warn"; };
}
