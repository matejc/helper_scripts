{ variables, pkgs, ... }:
let
  binPaths = with pkgs; [ nixd nil ];
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
        ctrl-q = "workspace::CloseWindow";
        ctrl-shift-q = "zed::Quit";
      };
    } {
      context = "ProjectPanel";
      bindings = {
        enter = "project_panel::OpenPermanent";
        pageup = ["workspace::SendKeystrokes" "up up up up up"];
        pagedown = ["workspace::SendKeystrokes" "down down down down down"];
      };
    } {
      context = "Editor";
      bindings = {
        pageup = ["editor::MoveUpByLines" { "lines" = 10; }];
        pagedown = ["editor::MoveDownByLines" { "lines" = 10; }];
        ctrl-enter = "editor::NewlineBelow";
        ctrl-up = "editor::MoveLineUp";
        ctrl-down = "editor::MoveLineDown";
        ctrl-o = "project_panel::ToggleFocus";
        "ctrl-\\" = "buffer_search::Deploy";
        "ctrl-k" = "editor::DeleteLine";
        "ctrl-shift-up" = "editor::AddSelectionAbove";
        "ctrl-shift-down" = "editor::AddSelectionBelow";
      };
    }
  ]);
# } {
#   target = "${variables.homeDir}/.local/share/zed/node/${nodeVersion}/bin";
#   source = "${nodePackage}/bin";
# } {
#   target = "${variables.homeDir}/.local/share/zed/node/${nodeVersion}/include";
#   source = "${nodePackage}/include";
# } {
#   target = "${variables.homeDir}/.local/share/zed/node/${nodeVersion}/lib";
#   source = "${nodePackage}/lib";
# } {
#   target = "${variables.homeDir}/.local/share/zed/node/${nodeVersion}/share";
#   source = "${nodePackage}/share";
} {
  target = "${variables.homeDir}/bin/z";
  source = pkgs.writeShellScript "zeditor.sh" ''
    export PATH="$PATH:${pkgs.lib.makeBinPath binPaths}"
    exec ${pkgs.zed-editor}/bin/zeditor "$@"
  '';
}]
