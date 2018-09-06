{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/mysync";
  source = pkgs.writeScript "mysync.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.libnotify}/bin/notify-send sync "Syncing ...";
    ${pkgs.coreutils}/bin/sync
    ${pkgs.libnotify}/bin/notify-send sync "Synced"
    ${pkgs.utillinux.bin}/bin/mount | ${pkgs.gnugrep}/bin/grep /run/media/${variables.user} | ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.findutils}/bin/xargs -i ${pkgs.udisks}/bin/udisksctl unmount -b '{}' | ${pkgs.findutils}/bin/xargs -i ${pkgs.libnotify}/bin/notify-send sync '{}'
  '';
}
