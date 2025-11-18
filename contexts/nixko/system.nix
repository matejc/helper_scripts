{ pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    inputs.lanzaboote.nixosModules.lanzaboote
    ../../nixos/modules/variables.nix
    ../../nixos/modules/misc.nix
    ../../nixos/modules/home-manager.nix
  ];

  config = {
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

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
        terminal.vt = lib.mkForce 2;
      };
    };
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    programs.niri.enable = true;
    hardware.bluetooth.enable = true;
    hardware.graphics = {
      enable = true;
    };
    services.power-profiles-daemon.enable = lib.mkForce false;
    networking.enableIPv6 = false;
    # virtualisation.docker.rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
    hardware.enableAllFirmware = true;
    services.tlp.settings = {
      START_CHARGE_THRESH_BAT1 = 90;
      STOP_CHARGE_THRESH_BAT1 = 95;
    };

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
    # users.groups.libvirtd.members = ["matejc"];
    # programs.virt-manager.enable = true;
    programs.fuse.userAllowOther = true;
    users.users.matejc.extraGroups = [ "fuse" ];
  };
}
