{
  pkgs,
  lib,
  inputs,
  defaultUser,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    inputs.lanzaboote.nixosModules.lanzaboote
    ../../nixos/modules/variables.nix
    ../../nixos/modules/misc.nix
    ../../nixos/modules/misc-gui.nix
    ../../nixos/modules/niri.nix
    ../../nixos/modules/physical.nix
    ../../nixos/modules/home-manager.nix
  ];

  config = {
    variables.graphicalSessionCmd = "/home/${defaultUser}/.nix-profile/bin/niri-session";

    environment.systemPackages = with pkgs; [
      sbctl
      python312Packages.python
    ];

    # Lanzaboote currently replaces the systemd-boot module.
    # This setting is usually set to true in configuration.nix
    # generated at installation time. So we force it to false
    # for now.
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    hardware.bluetooth.enable = true;
    hardware.graphics = {
      enable = true;
    };
    services.power-profiles-daemon.enable = lib.mkForce false;
    networking.enableIPv6 = false;
    # virtualisation.docker = {
    #   enable = true;
    # };
    hardware.enableAllFirmware = true;
    services.tlp.settings = {
      START_CHARGE_THRESH_BAT1 = 90;
      STOP_CHARGE_THRESH_BAT1 = 95;
    };
    security.pam.services.quickshell.fprintAuth = true;

    # services.envfs.enable = true;
    # services.envfs.extraFallbackPathCommands = ''
    #   ln -s ${pkgs.python312}/bin/python3 $out/python3
    # '';
    # system.activationScripts.binsh = lib.mkForce "";
    # system.activationScripts.usrbinenv = lib.mkForce "";
    system.activationScripts.python3 = ''
      ln -sf ${pkgs.python312}/bin/python3 /usr/bin/python3
    '';

    # virtualisation.libvirtd.enable = true;
    # users.groups.libvirtd.members = [ defaultUser ];
    # programs.virt-manager.enable = true;
    programs.fuse.userAllowOther = true;
    users.users.${defaultUser}.extraGroups = [
      "fuse"
      # "docker"
      # "podman"
    ];

    # services.dnsmasq = {
    #   enable = false;
    #   settings = {
    #     listen-address = "127.0.0.1";
    #     interface = "lo";
    #   };
    # };

    # networking.resolvconf.extraConfig = ''
    #   unbound_conf=/etc/unbound/resolvconf.conf
    # '';
    # services.unbound = {
    #   enable = true;
    #   settings = {
    #     server = {
    #       interface = [ "127.0.0.1" ];
    #       port = 53;
    #     };
    #     include = [ "/etc/unbound/resolvconf.conf" ];
    #   };
    # };
    # systemd.services.unbound.serviceConfig.ReadOnlyPaths = [ "/etc/unbound/resolvconf.conf" ];

    # virtualisation.podman = {
    #   enable = true;
    #   dockerSocket.enable = true;
    #   dockerCompat = true;
    # };
  };
}
