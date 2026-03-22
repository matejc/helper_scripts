{ variables, config, pkgs, lib }:
let
  opencodeConf = {
    "$schema" = "https://opencode.ai/config.json";
    permission = {
      "*" = "ask";
      read = {
        "*" = "allow";
        "*.env" = "deny";
        "*.env.*" = "deny";
        "*.env.example" = "allow";
      };
      edit = "ask";
      bash = "deny";
      list = "allow";
      grep = "allow";
      glob = "allow";
      websearch = "allow";
      codesearch = "allow";
    };
  };
in
[{
  target = "${variables.homeDir}/.config/opencode/opencode.json";
  source = pkgs.writeText "opencode.json" (builtins.toJSON opencodeConf);
}]
