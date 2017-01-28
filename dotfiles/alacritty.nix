{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/alacritty/alacritty.yml";
  source = pkgs.writeText "alacritty.yml" ''
    # Configuration for Alacritty, the GPU enhanced terminal emulator

    # The FreeType rasterizer needs to know the device DPI for best results
    # (changes require restart)
    dpi:
      x: 96.0
      y: 96.0

    # Display tabs using this many cells (changes require restart)
    tabspaces: 8

    # When true, bold text is drawn using the bright variant of colors.
    draw_bold_text_with_bright_colors: true

    # Font configuration (changes require restart)
    font:
      # The normal (roman) font face to use.
      normal:
        family: Source Code Pro for Powerline # should be "Menlo" or something on macOS.
        style: Regular
        # Style can be specified to pick a specific face.

      # The bold font face
      bold:
        family: Source Code Pro for Powerline # should be "Menlo" or something on macOS.
        style: Bold
        # Style can be specified to pick a specific face.

      # The italic font face
      italic:
        family: Source Code Pro for Powerline # should be "Menlo" or something on macOS.
        style: Bold
        # Style can be specified to pick a specific face.
        # style: Italic

      # Point size of the font
      size: 12.0
      # Offset is the extra space around each character. offset.y can be thought of
      # as modifying the linespacing, and offset.x as modifying the letter spacing.
      offset:
        x: 2.0
        y: -12.0

      # OS X only: use thin stroke font rendering. Thin strokes are suitable
      # for retina displays, but for non-retina you probably want this set to
      # false.
      use_thin_strokes: false

    # Should display the render timer
    render_timer: false

    # Colors (Tomorrow Night Bright)
    colors:
      # Default colors
      primary:
        background: '0x121212'
        foreground: '0xeaeaea'

      # Normal colors
      normal:
        black:   '0x000000'
        red:     '0xd54e53'
        green:   '0xb9ca4a'
        yellow:  '0xe6c547'
        blue:    '0x7aa6da'
        magenta: '0xc397d8'
        cyan:    '0x70c0ba'
        white:   '0x424242'

      # Bright colors
      bright:
        black:   '0x666666'
        red:     '0xff3334'
        green:   '0x9ec400'
        yellow:  '0xe7c547'
        blue:    '0x7aa6da'
        magenta: '0xb77ee0'
        cyan:    '0x54ced6'
        white:   '0x2a2a2a'

    # Colors (Solarized Dark)
    # colors:
    #   # Default colors
    #   primary:
    #     background: '0x002b36'
    #     foreground: '0x839496'
    #
    #   # Normal colors
    #   normal:
    #     black:   '0x073642'
    #     red:     '0xdc322f'
    #     green:   '0x859900'
    #     yellow:  '0xb58900'
    #     blue:    '0x268bd2'
    #     magenta: '0xd33682'
    #     cyan:    '0x2aa198'
    #     white:   '0xeee8d5'
    #
    #   # Bright colors
    #   bright:
    #     black:   '0x002b36'
    #     red:     '0xcb4b16'
    #     green:   '0x586e75'
    #     yellow:  '0x657b83'
    #     blue:    '0x839496'
    #     magenta: '0x6c71c4'
    #     cyan:    '0x93a1a1'
    #     white:   '0xfdf6e3'

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
    # Either an `action` or `chars` field must be present. `chars` writes the
    # specified string every time that binding is activated. These should generally
    # be escape sequences, but they can be configured to send arbitrary strings of
    # bytes. Possible values of `action` include `Paste` and `PasteSelection`.
    key_bindings:
      - { key: V,        mods: Command, action: Paste                        }
      - { key: C,        mods: Command, action: Copy                         }
      - { key: Home,                    chars: "\x1b[H",   mode: ~AppCursor  }
      - { key: Home,                    chars: "\x1b[1~",  mode: AppCursor   }
      - { key: End,                     chars: "\x1b[F",   mode: ~AppCursor  }
      - { key: End,                     chars: "\x1b[4~",  mode: AppCursor   }
      - { key: PageUp,                  chars: "\x1b[5~"                     }
      - { key: PageDown,                chars: "\x1b[6~"                     }
      - { key: Left,     mods: Shift,   chars: "\x1b[1;2D"                   }
      - { key: Left,     mods: Control, chars: "\x1b[1;5D"                   }
      # - { key: Left,     mods: Alt,     chars: "\x1b[1;3D"                   }
      - { key: Left,                    chars: "\x1b[D",   mode: ~AppCursor  }
      - { key: Left,                    chars: "\x1bOD",   mode: AppCursor   }
      - { key: Right,    mods: Shift,   chars: "\x1b[1;2C"                   }
      - { key: Right,    mods: Control, chars: "\x1b[1;5C"                   }
      # - { key: Right,    mods: Alt,     chars: "\x1b[1;3C"                   }
      - { key: Right,                   chars: "\x1b[C",   mode: ~AppCursor  }
      - { key: Right,                   chars: "\x1bOC",   mode: AppCursor   }
      - { key: Up,       mods: Shift,   chars: "\x1b[1;2A"                   }
      - { key: Up,       mods: Control, chars: "\x1b[1;5A"                   }
      # - { key: Up,       mods: Alt,     chars: "\x1b[1;3A"                   }
      - { key: Up,                      chars: "\x1b[A",   mode: ~AppCursor  }
      - { key: Up,                      chars: "\x1bOA",   mode: AppCursor   }
      - { key: Down,     mods: Shift,   chars: "\x1b[1;2B"                   }
      - { key: Down,     mods: Control, chars: "\x1b[1;5B"                   }
      # - { key: Down,     mods: Alt,     chars: "\x1b[1;3B"                   }
      - { key: Down,                    chars: "\x1b[B",   mode: ~AppCursor  }
      - { key: Down,                    chars: "\x1bOB",   mode: AppCursor   }
      - { key: Tab,      mods: Shift,   chars: "\x1b[Z"                      }
      - { key: F1,                      chars: "\x1bOP"                      }
      - { key: F2,                      chars: "\x1bOQ"                      }
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
      - { key: Back,                    chars: "\x7f"                        }
      - { key: Delete,                  chars: "\x1b[3~",  mode: AppKeypad   }
      - { key: Delete,                  chars: "\x1b[P",   mode: ~AppKeypad  }
      - { key: PageDown, mods: Control, chars: "\x1b[6;5~"                   }
      - { key: PageUp,   mods: Control, chars: "\x1b[5;5~"                   }
      - { key: V,        mods: Control|Shift, action: Paste                  }
      - { key: C,        mods: Control|Shift, action: Copy                   }
      - { key: Slash,    mods: Alt, chars: "\x1bOR"                }
      - { key: Backslash,mods: Alt, chars: "\x1bOS"                }
      - { key: PageUp,   mods: Control|Shift, chars: "\x1bOR"                }
      - { key: PageDown, mods: Control|Shift, chars: "\x1bOS"                }
      - { key: Down,     mods: Alt|Shift, chars: "\x1bOR"                    }
      - { key: Right,    mods: Alt|Shift, chars: "\x1bOS"                    }
      - { key: Left,     mods: Alt, chars: "\x1b[15~"                        }
      - { key: Right,    mods: Alt, chars: "\x1b[17~"                        }
      - { key: Up,       mods: Alt, chars: "\x1b[18~"                        }
      - { key: Down,     mods: Alt, chars: "\x1b[19~"                        }
      - { key: T,        mods: Control|Shift, chars: "\x1b[20~"              }
      - { key: PageUp,   mods: Shift,         chars: "\x1b[21~"              }


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


    # Shell
    #
    # You can set shell.program to the path of your favorite shell, e.g. /bin/fish.
    # Entries in shell.args are passed unmodified as arguments to the shell.
    #
    shell:
      program: tmux
  '';
}
