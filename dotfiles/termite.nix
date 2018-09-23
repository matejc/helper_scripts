{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/termite/config";
  source = pkgs.writeScript "termite.conf" ''
[options]
allow_bold = true
audible_bell = false
clickable_url = false
dynamic_title = true
font = ${variables.terminalFont}
fullscreen = true
icon_name = terminal
mouse_autohide = false
scroll_on_output = false
scroll_on_keystroke = true
# Length of the scrollback buffer, 0 disabled the scrollback buffer
# and setting it to a negative value means "infinite scrollback"
scrollback_lines = 10000
search_wrap = true
urgent_on_bell = true
hyperlinks = false

# $BROWSER is used by default if set, with xdg-open as a fallback
browser = ${variables.browser}

# "system", "on" or "off"
cursor_blink = off

# "block", "underline" or "ibeam"
cursor_shape = block

# Hide links that are no longer valid in url select overlay mode
filter_unmatched_urls = true

# Emit escape sequences for extra modified keys
#modify_other_keys = false

# set size hints for the window
#size_hints = false

# "off", "left" or "right"
scrollbar = off

[colors]
# Base16 Monokai
# Author: Wimer Hazenberg (http://www.monokai.nl)

foreground      = #f8f8f2
foreground_bold = #f5f4f1
#cursor          = #f5f4f1
background      = rgba(39,40,34,0.9)

# 16 color space

# Black, Gray, Silver, White
color0  = #272822
color8  = #75715e
color7  = #f8f8f2
color15 = #f9f8f5

# Red
color1  = #f92672
color9  = #f92672

# Green
color2  = #a6e22e
color10 = #a6e22e

# Yellow
color3  = #f4bf75
color11 = #f4bf75

# Blue
color4  = #66d9ef
color12 = #66d9ef

# Purple
color5  = #ae81ff
color13 = #ae81ff

# Teal
color6  = #a1efe4
color14 = #a1efe4

# Extra colors
color16 = #fd971f
color17 = #cc6633
color18 = #383830
color19 = #49483e
color20 = #a59f85
color21 = #f5f4f1


[hints]
#font = Monospace 12
#foreground = #dcdccc
#background = #3f3f3f
#active_foreground = #e68080
#active_background = #3f3f3f
#padding = 2
#border = #3f3f3f
#border_width = 0.5
#roundness = 2.0
  '';
}
