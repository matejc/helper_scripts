{ config, pkgs, ... }:
{
  users.users.matejc = {
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.zsh;
    group = "matejc";
  };
  users.groups.matejc.gid = 1000;
  system.stateVersion = "23.11";
}
