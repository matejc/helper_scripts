{config, pkgs, lib, ...}:
let
  cfg = config.services.astroneer;
  libPath = "${pkgs.stdenv.cc.cc.lib}/lib:ARKDedicatedServer/linux64:ARKDedicatedServer/ShooterGame/Binaries/Linux:ARKDedicatedServer/ShooterGame/Binaries/Linux/BattlEye:ARKDedicatedServer/Engine/Binaries/Linux";
in
{
  options.services.astroneer = {
    enable = lib.mkEnableOption "Enable Astroneer Dedicated Server";
  };

  config = lib.mkIf cfg.enable {
    users.users.astroneer = {
      home = "/var/lib/astroneer";
      createHome = true;
      isSystemUser = true;
      group = "astroneer";
    };
    users.groups.astroneer = {};

    nixpkgs.config.allowUnfree = true;

    networking = {
      firewall = {
        allowedTCPPorts = [ 8777 ];
        allowedUDPPorts = [ 8777 ];
      };
    };

    systemd.services.astroneer = {
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        ${pkgs.steamcmd}/bin/steamcmd \
          +login anonymous \
          +force_install_dir /var/lib/astroneer/DedicatedServer \
          +app_update 728470 validate \
          +quit
        ${pkgs.patchelf}/bin/patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 \
          --set-rpath "${libPath}" \
          /var/lib/astroneer/DedicatedServer/ShooterGame/Binaries/Linux/ShooterGameServer
      '';
      script = ''
        /var/lib/astroneer/DedicatedServer/ShooterGame/Binaries/Linux/ShooterGameServer ${cfg.mapName}?listen?SessionName=${cfg.sessionName}?ServerPassword=${cfg.password}?ServerAdminPassword=${cfg.adminPassword}?${lib.concatMapStringsSep "?" (x: "${x}") cfg.settings} -UseBattleye -server
      '';
      serviceConfig = {
        Nice = "-5";
        Restart = "always";
        User = "astroneer";
        WorkingDirectory = "/var/lib/astroneer";
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
