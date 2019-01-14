{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/sublime-text-3/Packages/User/Preferences.sublime-settings";
  source = pkgs.writeText "sublime-settings.json" ''
  {
      "always_show_minimap_viewport": true,
      "auto_complete": true,
      "bold_folder_labels": true,
      "convert_tabspaces_on_save": false,
      "create_window_at_startup": false,
      "enable_hover_diff_popup": true,
      "ensure_newline_at_eof_on_save": true,
      "folder_exclude_patterns":
      [
          ".svn",
          ".git",
          ".hg",
          "CVS",
          "node_modules",
          "bower_components",
          "result",
          "result-dev"
      ],
      "font_face": "Source Code Pro",
      "font_size": 11,
      "highlight_line": true,
      "highlight_modified_tabs": true,
      "hot_exit": false,
      "ignored_packages":
      [
          "Vintage"
      ],
      "path_search_order":
      [
          "project",
          "view",
          "window"
      ],
      "rulers":
      [
          79
      ],
      "skip_current_file": "true",
      "sort_on_load_save": false,
      "spell_check": true,
      "theme": "Default.sublime-theme",
      "translate_tabs_to_spaces": true,
      "trim_trailing_white_space_on_save": true
  }
  '';
} {
  target = "${variables.homeDir}/.config/sublime-text-3/Packages/User/Default (Linux).sublime-keymap";
  source = pkgs.writeText "sublime-keymap.json" ''
  [
      { "keys": ["ctrl+0"], "command": "focus_neighboring_group" },
      { "keys": ["ctrl+9"], "command": "extended_switcher", "args": {"list_mode": "window"} },
      { "keys": ["ctrl+alt+b"], "command": "jsbeautify" },
      { "keys": ["ctrl+pagedown"], "command": "next_view" },
      { "keys": ["ctrl+pageup"], "command": "prev_view" },
      { "keys": ["ctrl+tab"], "command": "focus_neighboring_group" },
      { "keys": ["ctrl+shift+tab"], "command": "focus_neighboring_group", "args": {"forward": false} },
      { "keys": ["ctrl+\\"], "command": "toggle_side_bar" },
      { "keys": ["ctrl+left"], "command": "move", "args": {"by": "subwords", "forward": false} },
      { "keys": ["ctrl+right"], "command": "move", "args": {"by": "subword_ends", "forward": true} },
      { "keys": ["ctrl+shift+left"], "command": "move", "args": {"by": "subwords", "forward": false, "extend": true} },
      { "keys": ["ctrl+shift+right"], "command": "move", "args": {"by": "subword_ends", "forward": true, "extend": true} },
      { "keys": ["ctrl+backspace"], "command": "run_macro_file", "args": {"file": "Packages/User/delete_subword.sublime-macro"} },
      { "keys": ["ctrl+delete"], "command": "run_macro_file", "args": {"file": "Packages/User/delete_subword_forward.sublime-macro"} },
      { "keys": ["ctrl+t"], "command": "recent_active_files" },
      { "keys": ["ctrl+n"], "command": "new_file" },
      { "keys": ["ctrl+k"], "command": "run_macro_file", "args": {"file": "res://Packages/Default/Delete Line.sublime-macro"} },
      { "keys": ["pageup"], "command": "line_jumper", "args": { "number_of_lines": 10, "cmd": "up" } },
      { "keys": ["pagedown"], "command": "line_jumper", "args": { "number_of_lines": 10, "cmd": "down" } },
      { "keys": ["shift+pageup"], "command": "line_jumper", "args": { "number_of_lines": 10, "cmd": "up_select" } },
      { "keys": ["shift+pagedown"], "command": "line_jumper", "args": { "number_of_lines": 10, "cmd": "down_select" } }
  ]
  '';
} {
  target = "${variables.homeDir}/.config/sublime-text-3/Packages/User/delete_subword.sublime-macro";
  source = pkgs.writeText "delete_subword.json" ''
  [
     {
        "command": "move",
        "args": {
           "by": "subwords",
           "extend": true,
           "forward": false
        }

     },
     {
        "args": null,
        "command": "left_delete"
     }
  ]
  '';
} {
  target = "${variables.homeDir}/.config/sublime-text-3/Packages/User/delete_subword_forward.sublime-macro";
  source = pkgs.writeText "delete_subword_forward.json" ''
  [
     {
        "command": "move",
        "args": {
           "by": "subwords",
           "extend": true,
           "forward": true
        }
     },
     {
        "args": null,
        "command": "right_delete"
     }
  ]
  '';
}]
