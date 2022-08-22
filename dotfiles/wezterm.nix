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
      color_scheme = 'Gruvbox dark, hard (base16)',
      check_for_updates = false,
      window_decorations = 'RESIZE',
      keys = {
        { key = 'PageUp', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
        { key = 'PageDown', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },
        {
          key = 'h',
          mods = 'ALT',
          action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
        },
        {
          key = 'v',
          mods = 'ALT',
          action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
        },
        {
          key = 'LeftArrow',
          mods = 'ALT',
          action = act.ActivatePaneDirection 'Left',
        },
        {
          key = 'RightArrow',
          mods = 'ALT',
          action = act.ActivatePaneDirection 'Right',
        },
        {
          key = 'UpArrow',
          mods = 'ALT',
          action = act.ActivatePaneDirection 'Up',
        },
        {
          key = 'DownArrow',
          mods = 'ALT',
          action = act.ActivatePaneDirection 'Down',
        },
        {
          key = 'c',
          mods = 'ALT',
          action = wezterm.action.CloseCurrentPane { confirm = true },
        },
      },
      window_frame = {
        font = wezterm.font { family = '${variables.font.family}', weight = 'Bold' },
        font_size = ${toString variables.font.size},
      },
      hide_tab_bar_if_only_one_tab = true,
    }
  '';
}
