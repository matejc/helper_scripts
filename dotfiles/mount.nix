{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/mysync";
  source = pkgs.writeScript "mysync.sh" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.libnotify}/bin/notify-send --expire-time=2000 Unmount "Syncing ...";
    ${pkgs.coreutils}/bin/sync
    ${pkgs.libnotify}/bin/notify-send --expire-time=3000 Unmount "Synced"
    ${pkgs.utillinux.bin}/bin/mount | ${pkgs.gnugrep}/bin/grep /run/media/${variables.user} | ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.findutils}/bin/xargs -i ${pkgs.udisks}/bin/udisksctl unmount -b '{}' | ${pkgs.findutils}/bin/xargs -i ${pkgs.libnotify}/bin/notify-send Unmount '{}'
  '';
}{
  target = "${variables.homeDir}/bin/usb-mount";
  source = pkgs.writeScript "usb-mount.sh" ''
    #!${pkgs.stdenv.shell}

    function entries()
    {

        for DISKID in `${pkgs.findutils}/bin/find /dev/disk/by-id/ -type l`
        do
            RES=`readlink -f $DISKID`;
            ${pkgs.gnugrep}/bin/grep -q "^$RES" /proc/mounts | echo "''${DISKID//*\//}" | ${pkgs.gnugrep}/bin/grep -E '^(usb-|mmc-).+-part.+' | ${pkgs.findutils}/bin/xargs -i echo "Mount $RES ({})"
        done
    }

    entry=$( (echo "Unmount All"; entries)  | ${pkgs.rofi}/bin/rofi -dmenu -p "Select mount action")

    if [ x"Unmount All" = x"$entry" ]
    then
        ${variables.homeDir}/bin/mysync
    else
        echo "$entry" | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.findutils}/bin/xargs -i ${pkgs.udisks}/bin/udisksctl mount -b '{}' | ${pkgs.findutils}/bin/xargs -i ${pkgs.libnotify}/bin/notify-send Mount "{}"
    fi
  '';
}]
