{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.wireplumber;
  mkAutoconnectRule = value:
  let
    nodeName = if value?sink then value.sink else value.source;
    mediaClass = if value?sink then "Stream/Output/Audio" else "Stream/Input/Audio";
  in
    {
      matches = {
        "node.name" = nodeName;
        "application.name" = value.application;
        "media.class" = mediaClass;
      } // (lib.optionalAttrs (value.binary != "") { "application.process.binary" = value.binary; });
      apply_properties = {
        "node.dont-fallback" = true;
        "node.autoconnect" = true;
        "priority.session" = value.priority;
        "target.node" = nodeName;
      };
    };

  splitByApp = i: attrSet: [] ++
    (lib.optionals (attrSet?sinks) (lib.imap1 (j: v: mkAutoconnectRule { application = attrSet.application; binary = attrSet.binary; sink = v; priority = (i*10)+j; }) (lib.reverseList attrSet.sinks))) ++
    (lib.optionals (attrSet?sources) (lib.imap1 (j: v: mkAutoconnectRule { application = attrSet.application; binary = attrSet.binary; source = v; priority = (i*10)+j; }) (lib.reverseList attrSet.sources)));

  autoconnectRules = lib.reverseList (lib.flatten (lib.imap1 splitByApp cfg.rules.autoconnect));
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
            default = "";
          };
          sinks = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "node.name of sinks by priority";
            default = [];
          };
          sources = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "node.name of sources by priority";
            default = [];
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."wireplumber/wireplumber.conf.d/10-autoconnect.lua" = {
      source = (pkgs.formats.lua {}).generate "10-autoconnect.lua" { "rules" = autoconnectRules; };
      onChange = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };
  };
}
