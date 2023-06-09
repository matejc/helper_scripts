{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.mylemmy;
in {
  options = {
    services.mylemmy = {
      enable = mkEnableOption "Whether to enable My Lemmy.";
      federation.enable = mkEnableOption "Whether to enable Lemmy Federation.";
      nginx.enable = mkEnableOption "Whether to enable Nginx.";

      domain = mkOption {
        type = types.str;
        description = "Domain";
      };

      admin.username = mkOption {
        type = types.str;
        description = "Admin username";
      };

      admin.password = mkOption {
        type = types.str;
        description = "Admin password";
      };

      port = mkOption {
        type = types.port;
        default = 1234;
        description = "Port";
      };

      ui.port = mkOption {
        type = types.port;
        default = 8536;
        description = "Port";
      };

      pict-rs.port = mkOption {
        type = types.port;
        default = 8080;
        description = "Port";
      };

      pict-rs.api_key = mkOption {
        type = types.str;
        description = "Api key";
      };

      email = mkOption {
        type = types.attrs;
        description = "Config attribute set";
        default = {
          # Hostname and port of the smtp server
          smtp_server = "";
          # Login name for smtp server
          smtp_login = "";
          # Password to login to the smtp server
          smtp_password = "";
          # Address to send emails from, eg "noreply@your-instance.com";
          smtp_from_address = "noreply@domain";
          # Whether or not smtp connections should use tls. Can be none, tls, or starttls
          tls_type = "none";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx = mkIf cfg.nginx.enable {
      upstreams."lemmy".servers."127.0.0.1:${builtins.toString cfg.port}" = {};
      upstreams."lemmy-ui".servers."127.0.0.1:${builtins.toString cfg.ui.port}" = {};

      virtualHosts."${cfg.domain}" = {
        enableACME = true;
        # add redirects from http to https
        forceSSL = true;
        # this whole block was lifted from https://github.com/LemmyNet/lemmy/blob/ef1aa18fd20cc03d492a81cb70cc75cf3281649f/docker/nginx.conf#L21 lines 21-32
        extraConfig = ''
          # disables emitting nginx version on error pages and in the “Server” response header field
          server_tokens off;

          gzip on;
          gzip_types text/css application/javascript image/svg+xml;
          gzip_vary on;

          # Upload limit, relevant for pictrs
          client_max_body_size 10M;

          add_header X-Frame-Options SAMEORIGIN;
          add_header X-Content-Type-Options nosniff;
          add_header X-XSS-Protection "1; mode=block";
        '';

        locations = {
          "/" = {
            # we do not use the nixos "locations.<name>.proxyPass" option because the nginx config needs to do something fancy.
            # again, lifted wholesale from https://github.com/LemmyNet/lemmy/blob/ef1aa18fd20cc03d492a81cb70cc75cf3281649f/docker/nginx.conf#L36 lines 36-55
            extraConfig = ''
              # distinguish between ui requests and backend
              # don't change lemmy-ui or lemmy here, they refer to the upstream definitions on top
              set $proxpass "http://lemmy-ui";

              if ($http_accept = "application/activity+json") {
                set $proxpass "http://lemmy";
              }
              if ($http_accept = "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"") {
                set $proxpass "http://lemmy";
              }
              if ($request_method = POST) {
                set $proxpass "http://lemmy";
              }
              proxy_pass $proxpass;

              # Cuts off the trailing slash on URLs to make them valid
              rewrite ^(.+)/+$ $1 permanent;

              # Send actual client IP upstream
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header Host $host;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };

          # again, lifted wholesale from https://github.com/LemmyNet/lemmy/blob/ef1aa18fd20cc03d492a81cb70cc75cf3281649f/docker/nginx.conf#L60 lines 60-69 (nice!)
          "~ ^/(api|pictrs|feeds|nodeinfo|.well-known)" = {
            proxyPass = "http://lemmy";
            extraConfig = ''
              # proxy common stuff
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";

              # Rate limit
              limit_req zone=lemmy_ratelimit burst=30 nodelay;

              ## Send actual client IP upstream
              #proxy_set_header X-Real-IP $remote_addr;
              #proxy_set_header Host $host;
              #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
      commonHttpConfig = ''
        limit_req_zone $binary_remote_addr zone=lemmy_ratelimit:10m rate=1r/s;
      '';
    };

    systemd.services.lemmy-ui = {
      environment = {
        LEMMY_UI_HOST = lib.mkForce "127.0.0.1:${toString cfg.ui.port}";
        LEMMY_UI_LEMMY_INTERNAL_HOST = lib.mkForce "127.0.0.1:${toString cfg.port}";
        LEMMY_UI_LEMMY_EXTERNAL_HOST = lib.mkForce cfg.domain;
        LEMMY_UI_HTTPS = "true";
      };
    };

    services.pict-rs = {
      port = cfg.pict-rs.port;
      address = "127.0.0.1";
    };

    systemd.services.lemmy.environment.LEMMY_DATABASE_URL = pkgs.lib.mkForce "postgres:///lemmy?host=/run/postgresql&user=lemmy";

    nixpkgs.overlays = [(self: super: {
      lemmy-server = super.lemmy-server.overrideAttrs (old: {
        patches = (old.patches or []) ++ [(super.fetchpatch {
          name = "fix-db-migrations.patch";
          url = "https://raw.githubusercontent.com/nix-community/nur-combined/dfe6c70c76681ad80fd566aeedd73189dd38cdc2/repos/colinsane/pkgs/patched/lemmy-server/fix-db-migrations.patch";
          hash = "sha256-zJ+3rkUtBogW8A4bH6jfBuNQbDiAoV68wxXfynda31A=";
        })];
      });
    })];

    services.lemmy = {
      enable = true;
      ui.port = cfg.ui.port;
      database.createLocally = true;
      settings = {
        # TODO: Enable this much later when you tested everything.
        # N.B. you can't change your domain name after enabling this.
        federation.enabled = cfg.federation.enable;
        # Pictrs image server configuration.
        pictrs = {
          # TODO: Set a custom pictrs API key. ( Required for deleting images )
          api_key = cfg.pict-rs.api_key;
        };
        # TODO: Email sending configuration. All options except login/password are mandatory
        email = cfg.email;
        # TODO: Parameters for automatic configuration of new instance (only used at first start)
        setup = {
          # Username for the admin user
          admin_username = cfg.admin.username;
          # Password for the admin user. It must be at least 10 characters.
          admin_password = cfg.admin.password;
          # Name of the site (can be changed later)
          site_name = "Lemmy at ${cfg.domain}";
        };
        # the domain name of your instance (mandatory)
        hostname = cfg.domain;
        # Address where lemmy should listen for incoming requests
        bind = "127.0.0.1";
        # Port where lemmy should listen for incoming requests
        port = cfg.port;
        # Whether the site is available over TLS. Needs to be true for federation to work.
        tls_enabled = true;
      };
    };
  };
}
