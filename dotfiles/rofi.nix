{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/bluetooth-connect";
  source = pkgs.writeScript "bluetooth-connect.sh" ''
    #!${pkgs.stdenv.shell}

    function entries()
    {
        ${pkgs.bluez}/bin/bluetoothctl -- devices | ${pkgs.gawk}/bin/awk '{$1=""; print "Connect "$0}'
    }

    entry=$( (echo Disconnect; entries)  | ${pkgs.rofi}/bin/rofi -dmenu -p "Select bluetooth action")

    if [ x"Disconnect" = x"$entry" ]
    then
        ${pkgs.bluez}/bin/bluetoothctl -- disconnect
    else
        echo "$entry" | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.findutils}/bin/xargs -i ${pkgs.bluez}/bin/bluetoothctl -- connect '{}'
    fi
  '';
}]
