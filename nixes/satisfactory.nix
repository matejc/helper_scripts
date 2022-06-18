{config, pkgs, lib, ...}: {
  users.users.satisfactory = {
    home = "/var/lib/satisfactory";
    createHome = true;
  };

  nixpkgs.config.allowUnfree = true;

  networking = {
    firewall = {
      allowedUDPPorts = [ 15777 15000 7777 ];
    };
  };


  systemd.services.satisfactory = {
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      ${pkgs.steamcmd}/bin/steamcmd \
        +login anonymous \
        +force_install_dir /var/lib/satisfactory/SatisfactoryDedicatedServer \
        +app_update 1690800 -beta experimental validate \
        +quit
    '';
    script = ''
      ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 /var/lib/satisfactory/SatisfactoryDedicatedServer/Engine/Binaries/Linux/UE4Server-Linux-Shipping FactoryGame
    '';
    serviceConfig = {
      Nice = "-5";
      Restart = "always";
      User = "satisfactory";
      WorkingDirectory = "/var/lib/satisfactory";
    };
    environment = {
      LD_LIBRARY_PATH="SatisfactoryDedicatedServer/linux64:SatisfactoryDedicatedServer/Engine/Binaries/Linux:SatisfactoryDedicatedServer/Engine/Binaries/ThirdParty/PhysX3/Linux/x86_64-unknown-linux-gnu/";
    };
  };
}
