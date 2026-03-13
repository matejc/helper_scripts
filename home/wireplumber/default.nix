{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.wireplumber;

  autoconnectConfFile = builtins.toFile "10-autoconnect.conf" ''
    wireplumber.components = [
      {
        name = "10-autoconnect.lua", type = script/lua
        provides = autoconnect
        arguments = {
          rules = ${builtins.toJSON autoconnectRules}
        }
      }
    ]

    wireplumber.profiles = {
      main = {
        autoconnect = required
      }
    }
  '';

  mkAutoconnectRule = value:
  let
    nodeName = if value?sink then value.sink else value.source;
    mediaClass = if value?sink then "Audio/Sink" else "Audio/Source";
  in
    {
      stream = (lib.optionalAttrs (value.binary != "") { "application.process.binary" = value.binary; })
        // (lib.optionalAttrs (value.application != "") { "application.name" = value.application; });
      node = {
        "media.class" = mediaClass;
        "node.name" = nodeName;
      };
    };

  splitByApp = rule:
    (lib.optionals (rule?sinks) (map (v: mkAutoconnectRule { application = rule.application; binary = rule.binary; sink = v; }) rule.sinks)) ++
    (lib.optionals (rule?sources) (map (v: mkAutoconnectRule { application = rule.application; binary = rule.binary; source = v; }) rule.sources));

  autoconnectRules = lib.flatten (map splitByApp cfg.rules.autoconnect);
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
            default = "";
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
    xdg.configFile."wireplumber/wireplumber.conf.d/10-autoconnect.conf" = {
      source = autoconnectConfFile;
      onChange = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };
    xdg.dataFile."wireplumber/scripts/10-autoconnect.lua" = {
      source = ./10-autoconnect.lua;
      onChange = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };
    xdg.dataFile."autoconnect-rules" = {
      target = "wireplumber/scripts/10-autoconnect-rules.lua";
      source = (pkgs.formats.lua {}).generate "10-autoconnect-rules.lua" autoconnectRules;
      onChange = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };
  };
}
