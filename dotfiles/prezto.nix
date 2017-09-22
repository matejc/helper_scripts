{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/temp-init";
  source = pkgs.writeScript "temp-init.sh" ''
    #!${pkgs.stdenv.shell}
    TEMPFILE="${variables.homeDir}/.temp1_input"
    rm $TEMPFILE
    if [ -f "/sys/devices/virtual/hwmon/hwmon0/temp1_input" ]; then
      ln -s /sys/devices/virtual/hwmon/hwmon0/temp1_input $TEMPFILE
    else
      ln -s /sys/devices/virtual/hwmon/hwmon1/temp1_input $TEMPFILE
    fi
  '';
}
