{ pkgs, lib, config, ... }:
with lib;
let
  pname = "owncast";
  version = "0.0.5";

  package = pkgs.buildGoPackage {
    inherit pname version;
    goPackagePath = "github.com/owncast/owncast";
    src = pkgs.fetchgit {
      url = https://github.com/owncast/owncast;
      rev = "refs/tags/v${version}";
      sha256 = "1bwpviypz1xsxp5f47j63ibbbbk9plp1f0k1piyh5p4cw55y9afj";
    };
    goDeps = ./deps.nix;
    postInstall = ''
      mkdir -p $out/share/owncast
      cp -r $src/static $out/share/owncast/
      cp -r $src/webroot $out/share/owncast/
    '';
  };

  cfg = config.services.owncast;
  configFile = pkgs.writeText "config.json" (
    builtins.toJSON (recursiveUpdate defaultConfig cfg.config)
  );
  defaultConfig = {
    ffmpegPath = "${pkgs.ffmpeg}/bin/ffmpeg";
    webServerPort = 8080;
    rtmpServerPort = 1935;
    instanceDetails = {
      name = "Owncast";
      title = "Owncast";
      nsfw = false;
    };
    videoSettings = {
      chunkLengthInSeconds = 4;
      streamingKey = "";
      streamQualities = [
        {
          low = null;
          videoBitrate = 500;
          scaledWidth = 540;
          audioPassthrough = true;
          framerate = 30;
          encoderPreset = "slow";
        } {
          medium = null;
          videoBitrate = 1500;
          scaledWidth = 720;
          framerate = 30;
          encoderPreset = "medium";
        } {
          high = null;
          videoBitrate = 10000;
          framerate = 30;
          encoderPreset = "ultrafast";
        }
      ];
    };
    files = {
      maxNumberInPlaylist = 4;
    };
  };
in {

  options = {
    services.owncast = {
      enable = mkEnableOption "Whether to enable Owncast.";

      homeDir = mkOption {
        type = types.str;
        default = "/var/lib/owncast";
        description = "Owncast data directory";
      };

      config = mkOption {
        type = types.attrs;
        description = "Config attribute set";
        default = {};
        example = defaultConfig;
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {
    environment.systemPackages = [ package ];

    users.users.owncast =
      { description = "Owncast daemon user";
        group = "owncast";
        isSystemUser = true;
        home = cfg.homeDir;
        createHome = true;
      };

    users.groups.owncast = { };

    systemd.services.owncast = {
      description = "Owncast server";
      wantedBy = [ "network.target" "multi-user.target" ];
      after = [ "network.service" ];
      serviceConfig = {
        Type = "simple";
        User  = "owncast";
        Group = "owncast";
        WorkingDirectory = cfg.homeDir;
        Environment = "PATH=${pkgs.bash}/bin:${pkgs.coreutils}/bin";
        ExecStartPre = pkgs.writeScript "owncast-init" ''
          #!${pkgs.stdenv.shell}
          mkdir -p ${cfg.homeDir}/{data,webroot}
          ln -sf ${package}/share/owncast/static ${cfg.homeDir}/
          cp -rn ${package}/share/owncast/webroot/* ${cfg.homeDir}/webroot/
        '';
        ExecStart = "${package}/bin/owncast --database=${cfg.homeDir}/data/owncast.db --configFile=${configFile}";
      };
    };

  };
}
