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

  defaultConfFile = builtins.toFile "9-default.conf" ''
    wireplumber.components = [
      {
        name = "9-default.lua", type = script/lua
        provides = default
        arguments = {
          sinks = ${builtins.toJSON cfg.default.sinks}
          sources = ${builtins.toJSON cfg.default.sources}
        }
      }
    ]

    wireplumber.profiles = {
      main = {
        default = required
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
    (lib.optionals (rule?sinks) (map (sink: map (match: mkAutoconnectRule { application = match.application; binary = match.binary; sink = sink; }) rule.match) rule.sinks)) ++
    (lib.optionals (rule?sources) (map (source: map (match: mkAutoconnectRule { application = match.application; binary = match.binary; source = source; }) rule.match) rule.sources));

  autoconnectRules = lib.flatten (map splitByApp cfg.autoconnect.rules);

  autoconnectEnable = cfg.autoconnect.rules != [];
  defaultEnable = cfg.default.sinks != [] || cfg.default.sources != [];
in
{
  options.programs.wireplumber = {
    enable = lib.mkEnableOption "Enable Wireplumber rules";
    autoconnect = {
      rules = lib.mkOption {
        description = "Autoconnect Rules";
        default = [];
        type = lib.types.listOf (lib.types.submodule {
          options = {
            match = lib.mkOption {
              description = "Autoconnect Match Rules";
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
                };
              });
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
    default = {
      sinks = lib.mkOption {
        description = "Default sink rules";
        type = lib.types.listOf lib.types.str;
        default = [];
      };
      sources = lib.mkOption {
        description = "Default source rules";
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."wireplumber/wireplumber.conf.d/10-autoconnect.conf" = lib.mkIf autoconnectEnable {
      source = autoconnectConfFile;
      onChange = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };
    xdg.dataFile."wireplumber/scripts/10-autoconnect.lua" = lib.mkIf autoconnectEnable {
      source = ./10-autoconnect.lua;
      onChange = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };

    xdg.configFile."wireplumber/wireplumber.conf.d/9-default.conf" = lib.mkIf defaultEnable {
      source = defaultConfFile;
      onChange = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };
    xdg.dataFile."wireplumber/scripts/9-default.lua" = lib.mkIf defaultEnable {
      source = ./9-default.lua;
      onChange = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };
  };
}
