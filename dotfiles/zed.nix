{ variables, pkgs, config, lib }:
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
    nix.lsp.local.path = "${pkgs.nixd}/bin/nixd";
  });
} {
  target = "${variables.homeDir}/.config/zed/keymap.json";
  source = pkgs.writeText "keymap.json" (builtins.toJSON [
    {
      bindings = {
        ctrl-o = "project_panel::ToggleFocus";
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
      };
    }
  ]);
}]
