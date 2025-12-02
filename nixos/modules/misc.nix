{
  pkgs,
  lib,
  inputs,
  config,
  defaultUser,
  ...
}:
{
  config = {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${config.variables.graphicalSessionCmd}";
          user = "greeter";
        };
        terminal.vt = lib.mkForce 2;
      };
    };

    systemd.sleep.extraConfig =
      (lib.optionalString (config.variables ? "hibernate" && config.variables.hibernate) ''
        AllowHibernation=yes
      '')
      + (lib.optionalString (config.variables ? "sleepMode" && config.variables.sleepMode != "") ''
        MemorySleepMode=${config.variables.sleepMode}
      '');
    services.logind.settings.Login =
      lib.mkIf (config.variables ? "hibernate" && config.variables.hibernate)
        {
          HandleSuspendKey = "hibernate";
          HandleLidSwitch = "hibernate";
        };

    xdg.portal = {
      enable = true;
      wlr = {
        # enable = true;
      };
      config.niri = {
        default = "gnome;gtk;";
        "org.freedesktop.impl.portal.Access" = "gtk";
        "org.freedesktop.impl.portal.Notification" = "gtk";
        "org.freedesktop.impl.portal.OpenURI" = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      };
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      xdgOpenUsePortal = true;
    };
    fonts.packages = [
      pkgs.font-awesome
      pkgs.corefonts
      pkgs.nerd-fonts.sauce-code-pro
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.fira-mono
    ];

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
    programs.nix-ld.enable = true;
    programs.dconf.enable = true;
    services.dbus.packages = [ pkgs.gcr ]; # gpg-entry.pinentryFlavor = "gnome3"

    nix = {
      channel.enable = false;
      settings = {
        nix-path = "nixpkgs=${inputs.nixpkgs}";
        experimental-features = [
          "configurable-impure-env"
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          defaultUser
        ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
      };
    };

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
    '';
    users.users.${defaultUser}.extraGroups = [ "video" ];

    services.upower.enable = true;
  };
}
