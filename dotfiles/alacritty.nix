{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/alacritty/alacritty.yml";
  source = pkgs.writeText "alacritty.yml" ''
# Configuration for Alacritty, the GPU enhanced terminal emulator


# Any items in the `env` entry below will be added as
# environment variables. Some entries may override variables
# set by alacritty it self.
env:
  # TERM env customization.
  #
  # If this property is not set, alacritty will set it to xterm-256color.
  #
  # Note that some xterm terminfo databases don't declare support for italics.
  # You can verify this by checking for the presence of `smso` and `sitm` in
  # `infocmp xterm-256color`.
  TERM: xterm-256color

# Window dimensions in character columns and lines
# (changes require restart)
dimensions:
  columns: 106
  lines: 24

# Adds this many blank pixels of padding around the window
# Units are physical pixels; this is not DPI aware.
# (change requires restart)
padding:
  x: 2
  y: 2

# Display tabs using this many cells (changes require restart)
tabspaces: 8

# When true, bold text is drawn using the bright variant of colors.
draw_bold_text_with_bright_colors: true

# Font configuration (changes require restart)
#
# Important font attributes like antialiasing, subpixel aa, and hinting can be
# controlled through fontconfig. Specifically, the following attributes should
# have an effect:
#
# * hintstyle
# * antialias
# * lcdfilter
# * rgba
#
# For instance, if you wish to disable subpixel antialiasing, you might set the
# rgba property to "none". If you wish to completely disable antialiasing, you
# can set antialias to false.
#
# Please see these resources for more information on how to use fontconfig
#
# * https://wiki.archlinux.org/index.php/font_configuration#Fontconfig_configuration
# * file:///usr/share/doc/fontconfig/fontconfig-user.html
font:
  # The normal (roman) font face to use.
  normal:
    family: Source Code Pro # should be "Menlo" or something on macOS.
    # Style can be specified to pick a specific face.
    style: Regular

  # The bold font face
  bold:
    family: Source Code Pro # should be "Menlo" or something on macOS.
    # Style can be specified to pick a specific face.
    style: Bold

  # The italic font face
  italic:
    family: Source Code Pro # should be "Menlo" or something on macOS.
    # Style can be specified to pick a specific face.
    style: Italic

  # Point size of the font
  size: 11.0

  # Offset is the extra space around each character. offset.y can be thought of
  # as modifying the linespacing, and offset.x as modifying the letter spacing.
  offset:
    x: 0.0
    y: 0.1

  # Glyph offset determines the locations of the glyphs within their cells with
  # the default being at the bottom. Increase the x offset to move the glyph to
  # the right, increase the y offset to move the glyph upward.
  glyph_offset:
    x: 0.0
    y: 0.1

  # OS X only: use thin stroke font rendering. Thin strokes are suitable
  # for retina displays, but for non-retina you probably want this set to
  # false.
  use_thin_strokes: false

# Should display the render timer
render_timer: false

# Use custom cursor colors. If true, display the cursor in the cursor.foreground
# and cursor.background colors, otherwise invert the colors of the cursor.
custom_cursor_colors: false

# Base16 Monokai 256 - alacritty color config
# Wimer Hazenberg (http://www.monokai.nl)
colors:
  # Default colors
  primary:
    background: '0x272822'
    foreground: '0xf8f8f2'

  # Colors the cursor will use if `custom_cursor_colors` is true
  cursor:
    text: '0x272822'
    cursor: '0xf8f8f2'

  # Normal colors
  normal:
    black:   '0x272822'
    red:     '0xf92672'
    green:   '0xa6e22e'
    yellow:  '0xf4bf75'
    blue:    '0x66d9ef'
    magenta: '0xae81ff'
    cyan:    '0xa1efe4'
    white:   '0xf8f8f2'

  # Bright colors
  bright:
    black:   '0x75715e'
    red:     '0xf92672'
    green:   '0xa6e22e'
    yellow:  '0xf4bf75'
    blue:    '0x66d9ef'
    magenta: '0xae81ff'
    cyan:    '0xa1efe4'
    white:   '0xf8f8f2'
# Visual Bell
#
# Any time the BEL code is received, Alacritty "rings" the visual bell. Once
# rung, the terminal background will be set to white and transition back to the
# default background color. You can control the rate of this transition by
# setting the `duration` property (represented in milliseconds). You can also
# configure the transition function by setting the `animation` property.
#
# Possible values for `animation`
# `Ease`
# `EaseOut`
# `EaseOutSine`
# `EaseOutQuad`
# `EaseOutCubic`
# `EaseOutQuart`
# `EaseOutQuint`
# `EaseOutExpo`
# `EaseOutCirc`
# `Linear`
#
# To completely disable the visual bell, set its duration to 0.
#
visual_bell:
  animation: EaseOutExpo
  duration: 0

# Background opacity
background_opacity: 0.9

# Mouse bindings
#
# Currently doesn't support modifiers. Both the `mouse` and `action` fields must
# be specified.
#
# Values for `mouse`:
# - Middle
# - Left
# - Right
# - Numeric identifier such as `5`
#
# Values for `action`:
# - Paste
# - PasteSelection
# - Copy (TODO)
mouse_bindings:
  - { mouse: Middle, action: PasteSelection }

mouse:
  double_click: { threshold: 300 }
  triple_click: { threshold: 300 }

selection:
  semantic_escape_chars: ",│`|:\"' ()[]{}<>"

hide_cursor_when_typing: false

# Live config reload (changes require restart)
live_config_reload: true

# Shell
#
# You can set shell.program to the path of your favorite shell, e.g. /bin/fish.
# Entries in shell.args are passed unmodified as arguments to the shell.
#shell:
  #program: tmux
  # args:
  #   - new-session -A -s main


# Key bindings
#
# Each binding is defined as an object with some properties. Most of the
# properties are optional. All of the alphabetical keys should have a letter for
# the `key` value such as `V`. Function keys are probably what you would expect
# as well (F1, F2, ..). The number keys above the main keyboard are encoded as
# `Key1`, `Key2`, etc. Keys on the number pad are encoded `Number1`, `Number2`,
# etc.  These all match the glutin::VirtualKeyCode variants.
#
# Possible values for `mods`
# `Command`, `Super` refer to the super/command/windows key
# `Control` for the control key
# `Shift` for the Shift key
# `Alt` and `Option` refer to alt/option
#
# mods may be combined with a `|`. For example, requiring control and shift
# looks like:
#
# mods: Control|Shift
#
# The parser is currently quite sensitive to whitespace and capitalization -
# capitalization must match exactly, and piped items must not have whitespace
# around them.
#
# Either an `action`, `chars`, or `command` field must be present.
#   `action` must be one of `Paste`, `PasteSelection`, `Copy`, or `Quit`.
#   `chars` writes the specified string every time that binding is activated.
#     These should generally be escape sequences, but they can be configured to
#     send arbitrary strings of bytes.
#   `command` must be a map containing a `program` string, and `args` array of
#     strings. For example:
#     - { ... , command: { program: "alacritty", args: ["-e", "vttest"] } }
#
# Want to add a binding (e.g. "PageUp") but are unsure what the X sequence
# (e.g. "\x1b[5~") is? Open another terminal (like xterm) without tmux,
# then run `showkey -a` to get the sequence associated to a key combination.
key_bindings:
  - { key: V,        mods: Control|Shift,    action: Paste               }
  - { key: C,        mods: Control|Shift,    action: Copy                }
  - { key: Q,        mods: Command, action: Quit                         }
  - { key: W,        mods: Command, action: Quit                         }
  - { key: Insert,   mods: Shift,   action: PasteSelection               }
  - { key: Key0,     mods: Control, action: ResetFontSize                }
  - { key: Equals,   mods: Control, action: IncreaseFontSize             }
  - { key: Subtract, mods: Control, action: DecreaseFontSize             }
  - { key: Home,                    chars: "\x1bOH"   }
  # - { key: Home,                    chars: "\x1b[H",   mode: ~AppCursor  }
  - { key: End,                     chars: "\x1bOF"   }
  # - { key: End,                     chars: "\x1b[F",   mode: ~AppCursor  }
  - { key: PageUp,   mods: Shift,   chars: "\x1b[5;2~"                   }
  - { key: PageUp,   mods: Control, chars: "\x1b[5;5~"                   }
  - { key: PageUp,                  chars: "\x1b[5~"                     }
  - { key: PageDown, mods: Shift,   chars: "\x1b[6;2~"                   }
  - { key: PageDown, mods: Control, chars: "\x1b[6;5~"                   }
  - { key: PageDown,                chars: "\x1b[6~"                     }
  - { key: Tab,      mods: Shift,   chars: "\x1b[Z"                      }
  - { key: Back,                    chars: "\x7f"                        }
  - { key: Back,     mods: Alt,     chars: "\x1b\x7f"                    }
  - { key: Back,     mods: Control, chars: "\x17"                        }
  - { key: Delete,   mods: Control, chars: "\x1b\x64"                    }
  - { key: Insert,                  chars: "\x1b[2~"                     }
  - { key: Delete,                  chars: "\x1b[3~"                     }
  - { key: Left,     mods: Shift,   chars: "\x1b[1;2D"                   }
  - { key: Left,     mods: Control, chars: "\x1b[1;5D"                   }
  - { key: Left,     mods: Alt,     chars: "\x1b[1;3D"                   }
  - { key: Left,                    chars: "\x1b[D",   mode: ~AppCursor  }
  - { key: Left,                    chars: "\x1bOD",   mode: AppCursor   }
  - { key: Right,    mods: Shift,   chars: "\x1b[1;2C"                   }
  - { key: Right,    mods: Control, chars: "\x1b[1;5C"                   }
  - { key: Right,    mods: Alt,     chars: "\x1b[1;3C"                   }
  - { key: Right,                   chars: "\x1b[C",   mode: ~AppCursor  }
  - { key: Right,                   chars: "\x1bOC",   mode: AppCursor   }
  - { key: Up,       mods: Shift,   chars: "\x1b[1;2A"                   }
  - { key: Up,       mods: Control, chars: "\x1b[1;5A"                   }
  - { key: Up,       mods: Alt,     chars: "\x1b[1;3A"                   }
  - { key: Up,                      chars: "\x1b[A",   mode: ~AppCursor  }
  - { key: Up,                      chars: "\x1bOA",   mode: AppCursor   }
  - { key: Down,     mods: Shift,   chars: "\x1b[1;2B"                   }
  - { key: Down,     mods: Control, chars: "\x1b[1;5B"                   }
  - { key: Down,     mods: Alt,     chars: "\x1b[1;3B"                   }
  - { key: Down,                    chars: "\x1b[B",   mode: ~AppCursor  }
  - { key: Down,                    chars: "\x1bOB",   mode: AppCursor   }
  # - { key: F1,                      chars: "\x1bOP"                      }
  - { key: PageUp,   mods: Control|Shift, chars: "\x1bOP"                      }
  # - { key: F2,                      chars: "\x1bOQ"                      }
  - { key: PageDown, mods: Control|Shift, chars: "\x1bOQ"                      }
  - { key: F3,                      chars: "\x1bOR"                      }
  - { key: F4,                      chars: "\x1bOS"                      }
  - { key: F5,                      chars: "\x1b[15~"                    }
  - { key: F6,                      chars: "\x1b[17~"                    }
  - { key: F7,                      chars: "\x1b[18~"                    }
  - { key: F8,                      chars: "\x1b[19~"                    }
  - { key: F9,                      chars: "\x1b[20~"                    }
  - { key: F10,                     chars: "\x1b[21~"                    }
  - { key: F11,                     chars: "\x1b[23~"                    }
  - { key: F12,                     chars: "\x1b[24~"                    }
  - { key: F1,       mods: Shift,   chars: "\x1b[1;2P"                   }
  - { key: F2,       mods: Shift,   chars: "\x1b[1;2Q"                   }
  - { key: F3,       mods: Shift,   chars: "\x1b[1;2R"                   }
  - { key: F4,       mods: Shift,   chars: "\x1b[1;2S"                   }
  - { key: F5,       mods: Shift,   chars: "\x1b[15;2~"                  }
  - { key: F6,       mods: Shift,   chars: "\x1b[17;2~"                  }
  - { key: F7,       mods: Shift,   chars: "\x1b[18;2~"                  }
  - { key: F8,       mods: Shift,   chars: "\x1b[19;2~"                  }
  - { key: F9,       mods: Shift,   chars: "\x1b[20;2~"                  }
  - { key: F10,      mods: Shift,   chars: "\x1b[21;2~"                  }
  - { key: F11,      mods: Shift,   chars: "\x1b[23;2~"                  }
  - { key: F12,      mods: Shift,   chars: "\x1b[24;2~"                  }
  - { key: F1,       mods: Control, chars: "\x1b[1;5P"                   }
  - { key: F2,       mods: Control, chars: "\x1b[1;5Q"                   }
  - { key: F3,       mods: Control, chars: "\x1b[1;5R"                   }
  - { key: F4,       mods: Control, chars: "\x1b[1;5S"                   }
  - { key: F5,       mods: Control, chars: "\x1b[15;5~"                  }
  - { key: F6,       mods: Control, chars: "\x1b[17;5~"                  }
  - { key: F7,       mods: Control, chars: "\x1b[18;5~"                  }
  - { key: F8,       mods: Control, chars: "\x1b[19;5~"                  }
  - { key: F9,       mods: Control, chars: "\x1b[20;5~"                  }
  - { key: F10,      mods: Control, chars: "\x1b[21;5~"                  }
  - { key: F11,      mods: Control, chars: "\x1b[23;5~"                  }
  - { key: F12,      mods: Control, chars: "\x1b[24;5~"                  }
  - { key: F1,       mods: Alt,     chars: "\x1b[1;6P"                   }
  - { key: F2,       mods: Alt,     chars: "\x1b[1;6Q"                   }
  - { key: F3,       mods: Alt,     chars: "\x1b[1;6R"                   }
  - { key: F4,       mods: Alt,     chars: "\x1b[1;6S"                   }
  - { key: F5,       mods: Alt,     chars: "\x1b[15;6~"                  }
  - { key: F6,       mods: Alt,     chars: "\x1b[17;6~"                  }
  - { key: F7,       mods: Alt,     chars: "\x1b[18;6~"                  }
  - { key: F8,       mods: Alt,     chars: "\x1b[19;6~"                  }
  - { key: F9,       mods: Alt,     chars: "\x1b[20;6~"                  }
  - { key: F10,      mods: Alt,     chars: "\x1b[21;6~"                  }
  - { key: F11,      mods: Alt,     chars: "\x1b[23;6~"                  }
  - { key: F12,      mods: Alt,     chars: "\x1b[24;6~"                  }
  - { key: F1,       mods: Super,   chars: "\x1b[1;3P"                   }
  - { key: F2,       mods: Super,   chars: "\x1b[1;3Q"                   }
  - { key: F3,       mods: Super,   chars: "\x1b[1;3R"                   }
  - { key: F4,       mods: Super,   chars: "\x1b[1;3S"                   }
  - { key: F5,       mods: Super,   chars: "\x1b[15;3~"                  }
  - { key: F6,       mods: Super,   chars: "\x1b[17;3~"                  }
  - { key: F7,       mods: Super,   chars: "\x1b[18;3~"                  }
  - { key: F8,       mods: Super,   chars: "\x1b[19;3~"                  }
  - { key: F9,       mods: Super,   chars: "\x1b[20;3~"                  }
  - { key: F10,      mods: Super,   chars: "\x1b[21;3~"                  }
  - { key: F11,      mods: Super,   chars: "\x1b[23;3~"                  }
  - { key: F12,      mods: Super,   chars: "\x1b[24;3~"                  }
  - { key: Home,        mods: Control|Shift, chars: "\x1b[1;6H"                }
  - { key: End,        mods: Control|Shift, chars: "\x1b[1;6F"                }
  - { key: Up,        mods: Control|Shift, chars: "\x1b[1;6A"                }
  - { key: Down,        mods: Control|Shift, chars: "\x1b[1;6B"                }
  - { key: Right,        mods: Control|Shift, chars: "\x1b[1;6C"                }
  - { key: Left,        mods: Control|Shift, chars: "\x1b[1;6D"                }
  '';
}
