{
  pkgs,
  lib,
  config,
  defaultUser,
  ...
}:
{
  config = {
    systemd.sleep.extraConfig =
      (lib.optionalString (config.variables ? "hibernate" && config.variables.hibernate) ''
        AllowHibernation=yes
      '')
      + (lib.optionalString (config.variables ? "sleepMode" && config.variables.sleepMode != "") ''
        MemorySleepMode=${config.variables.sleepMode}
      '');

    services.logind.settings.Login = {
      KillUserProcesses = true;
    }
    // (lib.mkIf (config.variables ? "hibernate" && config.variables.hibernate) {
      HandleSuspendKey = "hibernate";
      HandleLidSwitch = "hibernate";
    });

    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 90;
        STOP_CHARGE_THRESH_BAT0 = 95;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
      };
    };

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
    '';
    users.users.${defaultUser}.extraGroups = [ "video" ];

    services.upower.enable = true;
  };
}
