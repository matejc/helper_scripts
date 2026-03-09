{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.wireplumber;
  mkAutoconnectRule = value:
    {
      matches = {
        "application.name" = value.application;
        "media.class" = "Audio/${if value?sink then "Sink" else "Source"}";
      } // (lib.optionalAttrs (value.binary != null) { "application.process.binary" = value.binary; });
      actions.apply_properties = {
        "node.dont-fallback" = false;
        "node.autoconnect" = true;
        "target.node" = if value?sink then value.sink else value.source;
      };
      inherit (value) priority;
    };

  splitByApp = i: attrSet: [] ++
    (lib.optionals (attrSet?sinks) (lib.imap0 (j: v: mkAutoconnectRule { application = attrSet.application; binary = attrSet.binary; sink = v; priority = i+j+100; }) attrSet.sinks)) ++
    (lib.optionals (attrSet?sources) (lib.imap0 (j: v: mkAutoconnectRule { application = attrSet.application; binary = attrSet.binary; source = v; priority = i+j+500; }) attrSet.sources));

  autoconnectRules = lib.flatten (lib.imap0 splitByApp cfg.rules.autoconnect);
in
{
  options.programs.wireplumber = {
    enable = lib.mkEnableOption "Wireplumber rules";
    rules.autoconnect = lib.mkOption {
      description = "Autoconnect Rules";
      type = lib.types.listOf (lib.types.submodule {
        options = {
          application = lib.mkOption {
            type = lib.types.str;
            description = "Application name";
          };
          binary = lib.mkOption {
            type = lib.types.str;
            description = "Application binary";
            default = null;
          };
          sinks = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "node.name of sinks by priority";
          };
          sources = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "node.name of sources by priority";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    services.pipewire.wireplumber.extraConfig."10-autoconnect".rules = autoconnectRules;
  };
}
