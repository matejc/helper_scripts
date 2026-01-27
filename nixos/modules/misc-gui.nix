{
  pkgs,
  lib,
  config,
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
    environment.extraInit = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    '';

    fonts.packages = [
      pkgs.font-awesome
      pkgs.corefonts
      pkgs.nerd-fonts.sauce-code-pro
    ];
  };
}
