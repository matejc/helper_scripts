{ variables, pkgs, config, lib }:
let
  nodeVersion = "node-v18.15.0-linux-x64";
  nodePackage = pkgs.nodejs_18;
  binPaths = [ pkgs.nixd pkgs.gopls ];
in
[{
  target = "${variables.homeDir}/.config/zed/settings.json";
  source = pkgs.writeText "settings.json" (builtins.toJSON {
    features = {
      copilot = false;
    };
    base_keymap = "VSCode";
    theme = "Gruvbox Dark";
    vim_mode = false;
    telemetry = {
      metrics = false;
      diagnostics = false;
    };
    buffer_font_family = variables.font.family;
    buffer_font_size = variables.font.size + 3;
    project_panel = {
      default_width = 180;
      file_icons = false;
      folder_icons = false;
    };
    auto_update = false;
  });
} {
  target = "${variables.homeDir}/.config/zed/keymap.json";
  source = pkgs.writeText "keymap.json" (builtins.toJSON [
    {
      bindings = {
        ctrl-o = "project_panel::ToggleFocus";
        ctrl-p = "file_finder::Toggle";
        ctrl-shift-p = "command_palette::Toggle";
      };
    } {
      context = "ProjectPanel";
      bindings = {
        enter = "project_panel::Open";
      };
    } {
      context = "Editor";
      bindings = {
        pageup = "editor::MovePageUp";
        pagedown = "editor::MovePageDown";
        ctrl-enter = "editor::NewlineBelow";
        ctrl-up = "editor::MoveLineUp";
        ctrl-down = "editor::MoveLineDown";
        ctrl-o = "project_panel::ToggleFocus";
        "ctrl-\\" = "buffer_search::Deploy";
      };
    }
  ]);
} {
  target = "${variables.homeDir}/.local/share/zed/node/${nodeVersion}/bin";
  source = "${nodePackage}/bin";
} {
  target = "${variables.homeDir}/.local/share/zed/node/${nodeVersion}/include";
  source = "${nodePackage}/include";
} {
  target = "${variables.homeDir}/.local/share/zed/node/${nodeVersion}/lib";
  source = "${nodePackage}/lib";
} {
  target = "${variables.homeDir}/.local/share/zed/node/${nodeVersion}/share";
  source = "${nodePackage}/share";
} {
  target = "${variables.homeDir}/bin/zed";
  source = pkgs.writeShellScript "zed" ''
    export PATH="$PATH:${pkgs.lib.makeBinPath binPaths}"
    exec ${pkgs.zed-editor}/bin/zed "$@"
  '';
} {
  target = "${variables.homeDir}/bin/z";
  source = pkgs.writeShellScript "zed" ''
    exec ${variables.homeDir}/bin/zed . "$@"
  '';
}]
