{ inputs, defaultUser }:
{ lib, pkgs, config, ... }:

with lib;

{
  imports = [
    ./../modules/wayvnc.nix
  ];

  services.wayvnc.enable = true;
  services.wayvnc.user = defaultUser;

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    dconf
  ];

  # hardware.opengl.enable = true;

  programs.nix-ld.enable = true;

  # virtualisation.docker.enable = true;
  # virtualisation.docker.package = pkgs.docker.override { iptables = pkgs.iptables-legacy; };

  services.dbus.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  programs.mosh.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.timesyncd.enable = true;
  time.timeZone = "Europe/Helsinki";

  wsl.enable = true;
  wsl.defaultUser = defaultUser;
  wsl.docker-desktop.enable = true;
  wsl.interop.register = true;
  wsl.usbip.enable = true;
  wsl.useWindowsDriver = true;
  programs.bash.loginShellInit = "nixos-wsl-welcome";
  system.stateVersion = config.system.nixos.release;

  users.users.${defaultUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    uid = 1000;
    group = defaultUser;
  };
  users.groups.${defaultUser}.gid = 1000;
  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = false;
  security.pam.services.runuser.startSession = true;
}
