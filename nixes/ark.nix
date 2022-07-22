{config, pkgs, lib, ...}:
let
  cfg = config.services.ark;
  libPath = "${pkgs.stdenv.cc.cc.lib}/lib:ARKDedicatedServer/linux64:ARKDedicatedServer/ShooterGame/Binaries/Linux:ARKDedicatedServer/ShooterGame/Binaries/Linux/BattlEye:ARKDedicatedServer/Engine/Binaries/Linux";
in
{
  options.services.ark = {
    enable = lib.mkEnableOption "Enable ARK Dedicated Server";
    password = lib.mkOption {
      type = lib.types.str;
      description = "Server password";
    };
    adminPassword = lib.mkOption {
      type = lib.types.str;
      description = "Server Admin password";
    };
    sessionName = lib.mkOption {
      type = lib.types.str;
      description = "Session Name";
    };
    mapName = lib.mkOption {
      type = lib.types.str;
      description = "Server Map Name";
      default = "TheIsland";
    };
    settings = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Server Settings";
      default = [
        "MaxPlayers=10" "bPvEDisableFriendlyFire=true" "serverPVE=true" "Port=7779" "QueryPort=27015" "RCONPort=27020" "RCONEnabled=True"
        "XPMultiplier=2.0" "PlayerCharacterFoodDrainMultiplier=0.1" "PlayerCharacterWaterDrainMultiplier=0.3" "PlayerDamageMultiplier=2.0" "PlayerResistanceMultiplier=0.5"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.ark = {
      home = "/var/lib/ark";
      createHome = true;
      isSystemUser = true;
      group = "ark";
    };
    users.groups.ark = {};

    nixpkgs.config.allowUnfree = true;

    networking = {
      firewall = {
        allowedTCPPorts = [ 27020 ];
        allowedUDPPorts = [ 7779 27015 ];
      };
    };

    systemd.services.ark = {
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        ${pkgs.steamcmd}/bin/steamcmd \
          +login anonymous \
          +force_install_dir /var/lib/ark/ARKDedicatedServer \
          +app_update 376030 validate \
          +quit
        ${pkgs.patchelf}/bin/patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 \
          --set-rpath "${libPath}" \
          /var/lib/ark/ARKDedicatedServer/ShooterGame/Binaries/Linux/ShooterGameServer
      '';
      script = ''
        /var/lib/ark/ARKDedicatedServer/ShooterGame/Binaries/Linux/ShooterGameServer ${cfg.mapName}?listen?SessionName=${cfg.sessionName}?ServerPassword=${cfg.password}?ServerAdminPassword=${cfg.adminPassword}?${lib.concatMapStringsSep "?" (x: "${x}") cfg.settings} -UseBattleye -server
      '';
      serviceConfig = {
        Nice = "-5";
        Restart = "always";
        User = "ark";
        WorkingDirectory = "/var/lib/ark";
        LimitNOFILE = 100000;
        ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
        ExecStop = "${pkgs.coreutils}/bin/kill -s INT $MAINPID";
        TimeoutSec = "15m";
      };
      environment = {
        LD_LIBRARY_PATH = libPath;
      };
    };
  };
}
