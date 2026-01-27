{
  pkgs,
  lib,
  defaultUser,
  ...
}:
{
  imports = [
    ../../nixos/modules/variables.nix
    ../../nixos/modules/misc.nix
    ../../nixos/modules/misc-gui.nix
    ../../nixos/modules/physical.nix
    ../../nixos/modules/home-manager.nix
  ];

  config = {
    variables = {
      hibernate = false;
      graphicalSessionCmd = "/home/${defaultUser}/.nix-profile/bin/niri-session";
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver
        intel-media-driver
      ];
    };
    networking.networkmanager.enable = true;
    services.dbus.packages = [ pkgs.dconf ];
    services.gnome.at-spi2-core.enable = true;
    services.gnome.gnome-keyring.enable = true;
    services.accounts-daemon.enable = true;
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      vulkan-tools
    ];
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    networking.firewall = {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
    services.fprintd.enable = true;
    # services.fprintd.tod.enable = true;
    # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
    security.pam.services.swaylock.fprintAuth = true;
    services.tailscale.enable = true;
    hardware.bluetooth.enable = true;
  };
}
