{config, pkgs, lib, ...}:
with lib;
let
  cfg = config.services.satisfactory;
in
{
  options.services.satisfactory = {
    enable = lib.mkEnableOption "Enable Satisfactory Dedicated Server";

    extraSteamCmdArgs = lib.mkOption {
      type = lib.types.str;
      description = "Extra arguments passed to steamcmd command";
    };
  };
  config = mkIf cfg.enable {
    users.users.satisfactory = {
      home = "/var/lib/satisfactory";
      createHome = true;
      isSystemUser = true;
      group = "satisfactory";
    };
    users.groups.satisfactory = {};

    nixpkgs.config.allowUnfree = true;

    networking = {
      firewall = {
        allowedUDPPorts = [ 15777 15000 7777 27015 ];
        allowedUDPPortRanges = [ { from = 27031; to = 27036; } ];
        allowedTCPPorts = [ 27015 27036 ];
      };
    };

    systemd.services.satisfactory = {
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir /var/lib/satisfactory/SatisfactoryDedicatedServer \
          +login anonymous \
          +app_update 1690800 \
          ${cfg.extraSteamCmdArgs} \
          validate \
          +quit
        ${pkgs.patchelf}/bin/patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 /var/lib/satisfactory/SatisfactoryDedicatedServer/Engine/Binaries/Linux/UE4Server-Linux-Shipping
        ln -sfv /var/lib/satisfactory/.steam/steam/linux64 /var/lib/satisfactory/.steam/sdk64
      '';
      script = ''
        /var/lib/satisfactory/SatisfactoryDedicatedServer/Engine/Binaries/Linux/UE4Server-Linux-Shipping FactoryGame
      '';
      serviceConfig = {
        Restart = "always";
        User = "satisfactory";
        WorkingDirectory = "/var/lib/satisfactory";
      };
      environment = {
        LD_LIBRARY_PATH="SatisfactoryDedicatedServer/linux64:SatisfactoryDedicatedServer/Engine/Binaries/Linux:SatisfactoryDedicatedServer/Engine/Binaries/ThirdParty/PhysX3/Linux/x86_64-unknown-linux-gnu";
      };
    };
  };
}
