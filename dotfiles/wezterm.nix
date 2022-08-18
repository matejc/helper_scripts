{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/wezterm/wezterm.lua";
  source = pkgs.writeText "wezterm.lua" ''
    local wezterm = require 'wezterm'
    local act = wezterm.action

    return {
      font = wezterm.font '${variables.font.family}',
      font_size = ${toString variables.font.size},
      window_background_opacity = 0.95,
      color_scheme = 'Gruvbox Dark',
      check_for_updates = false,
      window_decorations = 'RESIZE',
      keys = {
        { key = 'PageUp', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
        { key = 'PageDown', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },
      },
    }
  '';
}
