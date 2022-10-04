{ pkgs, lib, config, ... }:
with lib;
let
  pname = "nextcloud-spreed-signaling";
  version = "0.2.0";

  package = pkgs.buildGoPackage rec {
    inherit pname version;
    goPackagePath = "github.com/strukturag/nextcloud-spreed-signaling";
    src = pkgs.fetchgit {
      url = https://github.com/strukturag/nextcloud-spreed-signaling;
      rev = "refs/tags/v${version}";
      #rev = "61000f5f698a9bdf6f5a5ea2c56f0d412fac55c3";
      sha256 = "1fz4h520jbvndb96fpi78698lj0287a89hgql1ykcg5j8pzf5q45";
      #sha256 = "0dlga6cczjadnwaxs3sc6jrphxpv472dnhlq2wgizmsi10hrjpvl";
    };
    preBuild = ''
      export GOPATH="/build/go/src/${goPackagePath}:$GOPATH"
      ${pkgs.easyjson}/bin/easyjson -all /build/go/src/${goPackagePath}/src/signaling/api_signaling.go
      ${pkgs.easyjson}/bin/easyjson -all /build/go/src/${goPackagePath}/src/signaling/api_backend.go
      ${pkgs.easyjson}/bin/easyjson -all /build/go/src/${goPackagePath}/src/signaling/api_proxy.go
      ${pkgs.easyjson}/bin/easyjson -all /build/go/src/${goPackagePath}/src/signaling/natsclient.go
      ${pkgs.easyjson}/bin/easyjson -all /build/go/src/${goPackagePath}/src/signaling/room.go
    '';
    goDeps = ./deps.nix;
    subPackages = [ "src/server" ];
    postInstall = ''
      mv $out/bin/server $out/bin/signaling
    '';
  };

  usrsctp = pkgs.stdenv.mkDerivation rec {
    name = "usrsctp-${version}";
    version = "20200525";
    src = pkgs.fetchurl {
      url = "https://github.com/sctplab/usrsctp/archive/a6647318b57c0a05d590c8c21fc22aba87f08749.tar.gz";
      sha256 = "05za3bp26wyrkskdf5rmnbmi1657idvqpi3c0d8z108sf92xna8b";
    };
    buildInputs = with pkgs; [
      which libtool automake autoconf cmake
    ];
    preConfigure = ''
      ./bootstrap
    '';
  };
  janus = pkgs.stdenv.mkDerivation rec {
    name = "janus-gateway-${version}";
    version = "0.9.2";
    src = pkgs.fetchurl {
      url = "https://github.com/meetecho/janus-gateway/archive/v${version}.tar.gz";
      sha256 = "0ibjwgzan1ssjcdmvsmi1cy98addgjzd5hz22gvgnqjqybd9x0mn";
    };
    buildInputs = with pkgs; [
      autogen autoconf automake libtool pkg-config curl jansson libconfig glib
      libnice srtp gengetopt libwebsockets libuv usrsctp
    ];
    preConfigure = ''
      ./autogen.sh
    '';
    configureFlags = [ "--disable-rabbitmq" "--disable-mqtt" "--disable-boringssl" ];
    preInstall = ''
      make configs
    '';
  };

  cfg = config.services.nextcloud-spreed-signaling;
  gnatsdConf = pkgs.writeText "gnatsd.conf" ''
    cluster {
      port: 4244  # port for inbound route connections
      routes = [
        # You can add other servers here to build up a cluster.
        #nats-route://otherserver:4244
      ]
    }
  '';
  serverConf = pkgs.writeText "server.conf" ''
    [http]
    # IP and port to listen on for HTTP requests.
    # Comment line to disable the listener.
    listen = ${cfg.address}:${toString cfg.port}

    # HTTP socket read timeout in seconds.
    #readtimeout = 15

    # HTTP socket write timeout in seconds.
    #writetimeout = 15

    [https]
    # IP and port to listen on for HTTPS requests.
    # Comment line to disable the listener.
    #listen = 127.0.0.1:8443

    # HTTPS socket read timeout in seconds.
    #readtimeout = 15

    # HTTPS socket write timeout in seconds.
    #writetimeout = 15

    # Certificate / private key to use for the HTTPS server.
    certificate = ${cfg.certificate}
    key = ${cfg.certificateKey}

    [app]
    # Set to "true" to install pprof debug handlers.
    # See "https://golang.org/pkg/net/http/pprof/" for further information.
    debug = false

    [sessions]
    # Secret value used to generate checksums of sessions. This should be a random
    # string of 32 or 64 bytes.
    hashkey = ${cfg.hashkey}

    # Optional key for encrypting data in the sessions. Must be either 16, 24 or
    # 32 bytes.
    # If no key is specified, data will not be encrypted (not recommended).
    blockkey = ${cfg.blockkey}

    [clients]
    # Shared secret for connections from internal clients. This must be the same
    # value as configured in the respective internal services.
    #internalsecret =

    [backend]
    # Comma-separated list of backend ids from which clients are allowed to connect
    # from. Each backend will have isolated rooms, i.e. clients connecting to room
    # "abc12345" on backend 1 will be in a different room than clients connected to
    # a room with the same name on backend 2. Also sessions connected from different
    # backends will not be able to communicate with each other.
    backends = backend1

    # Allow any hostname as backend endpoint. This is extremely insecure and should
    # only be used while running the benchmark client against the server.
    allowall = false

    # Common shared secret for requests from and to the backend servers if
    # "allowall" is enabled. This must be the same value as configured in the
    # Nextcloud admin ui.
    #secret =

    # Timeout in seconds for requests to the backend.
    timeout = 10

    # Maximum number of concurrent backend connections per host.
    connectionsperhost = 8

    # If set to "true", certificate validation of backend endpoints will be skipped.
    # This should only be enabled during development, e.g. to work with self-signed
    # certificates.
    #skipverify = false

    # Backend configurations as defined in the "[backend]" section above. The
    # section names must match the ids used in "backends" above.
    [backend1]
    # URL of the Nextcloud instance
    url = ${cfg.nextcloudUrl}

    # Shared secret for requests from and to the backend servers. This must be the
    # same value as configured in the Nextcloud admin ui.
    secret = ${cfg.secret}

    # Limit the number of sessions that are allowed to connect to this backend.
    # Omit or set to 0 to not limit the number of sessions.
    sessionlimit = 10

    #[another-backend]
    # URL of the Nextcloud instance
    #url = https://cloud.otherdomain.invalid

    # Shared secret for requests from and to the backend servers. This must be the
    # same value as configured in the Nextcloud admin ui.
    #secret = the-shared-secret

    [nats]
    # Url of NATS backend to use. This can also be a list of URLs to connect to
    # multiple backends. For local development, this can be set to ":loopback:"
    # to process NATS messages internally instead of sending them through an
    # external NATS backend.
    url = nats://localhost:4222

    [mcu]
    # The type of the MCU to use. Currently only "janus" and "proxy" are supported.
    # Leave empty to disable MCU functionality.
    type = janus

    # For type "janus": the URL to the websocket endpoint of the MCU server.
    # For type "proxy": a space-separated list of proxy URLs to connect to.
    url = ws://localhost:8188

    # For type "janus": the maximum bitrate per publishing stream (in bits per
    # second).
    # Defaults to 1 mbit/sec.
    #maxstreambitrate = 1048576

    # For type "janus": the maximum bitrate per screensharing stream (in bits per
    # second).
    # Default is 2 mbit/sec.
    #maxscreenbitrate = 2097152

    # For type "proxy": timeout in seconds for requests to the proxy server.
    #proxytimeout = 2

    # For type "proxy": type of URL configuration for proxy servers.
    # Defaults to "static".
    #
    # Possible values:
    # - static: A space-separated list of proxy URLs is given in the "url" option.
    # - etcd: Proxy URLs are retrieved from an etcd cluster (see below).
    #urltype = static

    # If set to "true", certificate validation of proxy servers will be skipped.
    # This should only be enabled during development, e.g. to work with self-signed
    # certificates.
    #skipverify = false

    # For type "proxy": the id of the token to use when connecting to proxy servers.
    #token_id = server1

    # For type "proxy": the private key for the configured token id to use when
    # connecting to proxy servers.
    #token_key = privkey.pem

    # For url type "etcd": Comma-separated list of static etcd endpoints to
    # connect to.
    #endpoints = 127.0.0.1:2379,127.0.0.1:22379,127.0.0.1:32379

    # For url type "etcd": Options to perform endpoint discovery through DNS SRV.
    # Only used if no endpoints are configured manually.
    #discoverysrv = example.com
    #discoveryservice = foo

    # For url type "etcd": Path to private key, client certificate and CA
    # certificate if TLS authentication should be used.
    #clientkey = /path/to/etcd-client.key
    #clientcert = /path/to/etcd-client.crt
    #cacert = /path/to/etcd-ca.crt

    # For url type "etcd": Key prefix of MCU proxy entries. All keys below will be
    # watched and assumed to contain a JSON document. The entry "address" from this
    # document will be used as proxy URL, other contents in the document will be
    # ignored.
    #
    # Example:
    # "/signaling/proxy/server/one" -> {"address": "https://proxy1.domain.invalid"}
    # "/signaling/proxy/server/two" -> {"address": "https://proxy2.domain.invalid"}
    #keyprefix = /signaling/proxy/server

    [turn]
    # API key that the MCU will need to send when requesting TURN credentials.
    apikey = ${cfg.turnSecret}

    # The shared secret to use for generating TURN credentials. This must be the
    # same as on the TURN server.
    secret = ${cfg.turnSecret}

    # A comma-separated list of TURN servers to use. Leave empty to disable the
    # TURN REST API.
    servers = turn:localhost:3478?transport=udp,turn:localhost:3478?transport=tcp

    [geoip]
    # License key to use when downloading the MaxMind GeoIP database. You can
    # register an account at "https://www.maxmind.com/en/geolite2/signup" for
    # free. See "https://dev.maxmind.com/geoip/geoip2/geolite2/" for further
    # information.
    # Leave empty to disable GeoIP lookups.
    #license =

    # Optional URL to download a MaxMind GeoIP database from. Will be generated if
    # "license" is provided above. Can be a "file://" url if a local file should
    # be used. Please note that the database must provide a country field when
    # looking up IP addresses.
    #url =

    [geoip-overrides]
    # Optional overrides for GeoIP lookups. The key is an IP address / range, the
    # value the associated country code.
    #127.0.0.1 = DE
    #192.168.0.0/24 = DE

    [stats]
    # Comma-separated list of IP addresses that are allowed to access the stats
    # endpoint. Leave empty (or commented) to only allow access from "127.0.0.1".
    #allowed_ips =
  '';
in {

  options = {
    services.nextcloud-spreed-signaling = {
      enable = mkEnableOption "Whether to enable nextcloud-spreed-signaling.";

      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Listen address";
      };

      port = mkOption {
        type = types.int;
        default = 8080;
        description = "Listen port";
      };

      nextcloudUrl = mkOption {
        type = types.str;
        default = "https://cloud.foo.invalid";
        description = "Listen address";
      };

      secret = mkOption {
        type = types.str;
        description = "Nextcloud admin secret";
      };

      certificate = mkOption {
        type = types.str;
        default = "/etc/nginx/ssl/server.crt";
        description = "Path to certificate file";
      };

      certificateKey = mkOption {
        type = types.str;
        default = "/etc/nginx/ssl/server.key";
        description = "Path to certificate key file";
      };

      hashkey = mkOption {
        type = types.str;
        description = "Secret value used to generate checksums of sessions. This should be a random string of 32 or 64 bytes.";
      };

      blockkey = mkOption {
        type = types.str;
        description = "Optional key for encrypting data in the sessions. Must be either 16, 24 or 32 bytes";
      };

      turnSecret = mkOption {
        type = types.str;
        description = "Turn secret";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {
    environment.systemPackages = [ package ];

    users.users.signaling =
      { description = "nextcloud-spreed-signaling daemon user";
        group = "signaling";
        isSystemUser = true;
      };

    users.groups.signaling = { };

    systemd.services.signaling = {
      description = "nextcloud-spreed-signaling server";
      wantedBy = [ "network.target" "multi-user.target" ];
      after = [ "network.service" ];
      serviceConfig = {
        Type = "simple";
        User  = "signaling";
        Group = "signaling";
        ExecStart = "${package}/bin/signaling --config=${serverConf}";
      };
    };

    users.users.nats =
      { description = "nats daemon user";
        group = "nats";
        isSystemUser = true;
      };

    users.groups.nats = { };

    systemd.services.nats = {
      description = "nats server";
      wantedBy = [ "network.target" "multi-user.target" ];
      after = [ "network.service" ];
      serviceConfig = {
        Type = "simple";
        User  = "nats";
        Group = "nats";
        ExecStart = "${pkgs.nats-server}/bin/nats-server --config=${gnatsdConf}";
      };
    };

    users.users.janus =
      { description = "janus daemon user";
        group = "janus";
        isSystemUser = true;
      };

    users.groups.janus = { };

    systemd.services.janus = {
      description = "janus server";
      wantedBy = [ "network.target" "multi-user.target" ];
      after = [ "network.service" ];
      serviceConfig = {
        Type = "simple";
        User  = "janus";
        Group = "janus";
        ExecStart = "${janus}/bin/janus --full-trickle";
      };
    };

    services.coturn = {
      enable = true;
      static-auth-secret = cfg.turnSecret;
      use-auth-secret = true;
      realm = cfg.nextcloudUrl;
      no-tls = true;
      no-dtls = true;
      extraConfig = ''
        prod
        fingerprint
        no-multicast-peers
      '';
    };

  };
}
