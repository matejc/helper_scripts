{ inputs, defaultUser }:
{ lib, pkgs, config, ... }:

with lib;

let
  syschdemd = import ./syschdemd.nix { inherit lib pkgs config defaultUser; };
in
{
  imports = [
    (import "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix")
    (import "${inputs.home-manager}/nixos")
  ];

  nixpkgs.config.allowUnfree = true;
  environment.noXlibs = lib.mkForce false;
  environment.systemPackages = with pkgs; [
    dconf xorg.xrandr
    libsForQt5.kwallet
  ];
  system.activationScripts.specialfs = mkForce "true";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = false;
  home-manager.users.${defaultUser} = (import ../configuration.nix { inherit inputs; contextFile = ../contexts/wsl.nix; });

  services.xrdp.enable = true;

  services.dbus.enable = true;
  programs.mosh.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.timesyncd.enable = true;
  time.timeZone = "Europe/Helsinki";

  # WSL is closer to a container than anything else
  boot.isContainer = true;

  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;

  networking.dhcpcd.enable = false;

  users.users.${defaultUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    uid = 1000;
  };

  users.users.root = {
    shell = "${syschdemd}/bin/syschdemd";
    # Otherwise WSL fails to login as root with "initgroups failed 5"
    extraGroups = [ "root" ];
  };

  # Described as "it should not be overwritten" in NixOS documentation,
  # but it's on /run per default and WSL mounts /run as a tmpfs, hence
  # hiding the wrappers.
  security.wrapperDir = "/wrappers";

  security.sudo.wheelNeedsPassword = false;

  # Disable systemd units that don't make sense on WSL
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  systemd.services.firewall.enable = false;
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-udevd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;
}