{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/wezterm/wezterm.lua";
  source = pkgs.writeText "wezterm.lua" ''
    local wezterm = require 'wezterm'
    local act = wezterm.action
    local mux = wezterm.mux

    wezterm.on("gui-startup", function(cmd)
      local tab, pane, window = mux.spawn_window(cmd or {})
      window:gui_window():maximize()
    end)

    return {
      font = wezterm.font '${variables.font.family}',
      font_size = ${toString variables.font.size},
      default_cursor_style = 'SteadyBar',
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
        font = wezterm.font('${variables.font.family}', {}),
        font_size = ${toString (1.0 + variables.font.size)},
      },
      colors = {
        tab_bar = {
          background = '#0b0022',
          active_tab = {
            bg_color = '#2b2042',
            fg_color = '#c0c0c0',
            intensity = 'Bold',
            underline = 'None',
            italic = false,
            strikethrough = false,
          },
          inactive_tab = {
            bg_color = '#1b1032',
            fg_color = '#808080',
          },
          inactive_tab_hover = {
            bg_color = '#3b3052',
            fg_color = '#909090',
            italic = true,
          },
          new_tab = {
            bg_color = '#1b1032',
            fg_color = '#808080',
          },
          new_tab_hover = {
            bg_color = '#3b3052',
            fg_color = '#909090',
            italic = true,
          },
        },
      },
      hide_tab_bar_if_only_one_tab = true,
      use_fancy_tab_bar = false,
      tab_max_width = 32,
    }
  '';
}
