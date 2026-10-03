{
  pkgs,
  lib,
  config,
  defaultUser,
  ...
}:
# let
#   graphicalSessionScript = pkgs.writeScript "graphical-session.sh" ''
#     ${config.variables.graphicalSessionCmd}
#     graphicalSessionPID=$!
#     wait $graphicalSessionPID
#     loginctl terminate-user $USER
#   '';
# in
{
  config = {
    # services.greetd = {
    #   enable = true;
    #   settings = {
    #     default_session = {
    #       command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${graphicalSessionScript}";
    #       user = "greeter";
    #     };
    #     terminal.vt = lib.mkForce 2;
    #   };
    # };
    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        session.default = config.home-manager.users.${defaultUser}.variables.graphical.sessionName;
        appearance = {
          scheme = "Gruvbox";
          hide_logo = true;
          scheme_selector_position = "hidden";
          theme_mode = "dark";
          wallpaper = lib.listToAttrs (map (v: {
            name = v.output;
            value = {
              path = v.wallpaper;
            };
          }) config.home-manager.users.${defaultUser}.variables.outputs);
        };
        idle.timeout = 60;
        keyboard.layout = "us";
        auth.request_timeout = 0;
      };
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
    };

    environment.extraInit = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    '';

    fonts.packages = [
      pkgs.font-awesome
      pkgs.corefonts
    ];
  };
}
