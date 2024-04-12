{ config, pkgs, ... }:
{
  boot.loader.grub.devices = [ "/dev/sda" ];
  fileSystems."/" = {
    device = "/dev/sda";
    fsType = "ext4";
  };
  users.users.matejc = {
    uid = 1000;
    isNormalUser = true;
    group = "matejc";
  };
  users.groups.matejc.gid = 1000;
  system.stateVersion = "23.11";
}
