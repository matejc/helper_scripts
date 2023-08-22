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
    dconf
  ];
  system.activationScripts.specialfs = mkForce "true";
  system.activationScripts.wslinterop = ''
    ln -s /run/WSL/8_interop /run/WSL/2_interop || true
  '';
  system.activationScripts.setupLogin = stringAfter [ ] ''
    echo "setting up /bin/login..."
    mkdir -p /bin
    ln -sf ${pkgs.shadow}/bin/login /bin/login
  '';
  system.activationScripts.runtimeDir = stringAfter [ ] ''
    userId="$(${pkgs.stdenv.cc.libc.getent}/bin/getent passwd "${defaultUser}" | ${pkgs.coreutils}/bin/cut -d: -f3)"
    runtimeDir="/run/user/$userId"
    echo "setting up $runtimeDir"
    mkdir -p /run/user
    ln -sf /mnt/wslg/runtime-dir "$runtimeDir"
  '';

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = false;
  home-manager.users.${defaultUser} = import ../configuration.nix { inherit inputs; contextFile = ../contexts/wsl.nix; };
  hardware.opengl.enable = true;

  programs.nix-ld.enable = true;
  environment.etc."binfmt.d/WSLInterop.conf".text = ''
    :WSLInterop:M::MZ::/init:PF
  '';

  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker.override { iptables = pkgs.iptables-legacy; };

  services.dbus.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

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
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    uid = 1000;
  };
  programs.zsh.enable = true;

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
  security.pam.services.runuser.startSession = true;

  # Disable systemd units that don't make sense on WSL
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  systemd.services.firewall.enable = false;
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-udevd.enable = false;
  systemd.oomd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;

  system.stateVersion = "22.11";
}
