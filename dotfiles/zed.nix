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
    ui_font_size = 16;
    buffer_font_size = 16;
  });
} {
  target = "${variables.homeDir}/.config/zed/keymap.json";
  source = pkgs.writeText "keymap.json" (builtins.toJSON [
    {
      context = "Editor";
      bindings = {
        pageup = "editor::MovePageUp";
        pagedown = "editor::MovePageDown";
        ctrl-enter = "editor::NewlineBelow";
        ctrl-up = "editor::MoveLineUp";
        ctrl-down = "editor::MoveLineDown";
      };
    }
  ]);
}]
