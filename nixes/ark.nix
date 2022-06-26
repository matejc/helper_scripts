{config, pkgs, lib, ...}: {
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
      allowedUDPPorts = [ 27015 ];
      allowedUDPPortRanges = [ { from = 7777; to = 7782; } ];
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
      ${pkgs.patchelf}/bin/patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 /var/lib/ark/ARKDedicatedServer/ShooterGame/Binaries/Linux/ShooterGameServer
    '';
    script = ''
      /var/lib/ark/ARKDedicatedServer/ShooterGame/Binaries/Linux/ShooterGameServer TheIsland?listen?SessionName=matejc?ServerPassword=${services.ark.password}?ServerAdminPassword=${services.ark.adminPassword}?MaxPlayers=10 -server -log
    '';
    serviceConfig = {
      Nice = "-5";
      Restart = "always";
      User = "ark";
      WorkingDirectory = "/var/lib/ark";
      LimitNOFILE = 100000;
      ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
      ExecStop= "${pkgs.coreutils}/bin/kill -s INT $MAINPID";
    };
    environment = {
      LD_LIBRARY_PATH="ARKDedicatedServer/ShooterGame/linux64:ARKDedicatedServer/ShooterGame/Engine/Binaries/Linux:ARKDedicatedServer/ShooterGame/Engine/Binaries/ThirdParty/PhysX3/Linux/x86_64-unknown-linux-gnu/";
    };
  };
}
