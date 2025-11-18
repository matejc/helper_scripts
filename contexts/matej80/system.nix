{ pkgs, lib, config, inputs, ... }:
{
  imports = [
    ../../nixos/modules/variables.nix
    ../../nixos/modules/misc.nix
    ../../nixos/modules/home-manager.nix
  ];

  config = {
    variables = {
      hibernate = false;
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [ intel-vaapi-driver intel-media-driver ];
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
    programs.niri.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    networking.firewall = {
      allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
      allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
    };
    services.fprintd.enable = true;
    # services.fprintd.tod.enable = true;
    # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
    security.pam.services.swaylock.fprintAuth = true;
    services.tailscale.enable = true;
    hardware.bluetooth.enable = true;
  };
}
