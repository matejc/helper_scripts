{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/kitty/kitty.conf";
  source = pkgs.writeText "kitty.conf" ''
#: Fonts {{{

#: kitty has very powerful font management. You can configure
#: individual font faces and even specify special fonts for particular
#: characters.

  font_family      ${variables.font.family}
  bold_font        auto
  italic_font      auto
  bold_italic_font auto

#: You can specify different fonts for the bold/italic/bold-italic
#: variants. To get a full list of supported fonts use the `kitty
#: list-fonts` command. By default they are derived automatically, by
#: the OSes font system. Setting them manually is useful for font
#: families that have many weight variants like Book, Medium, Thick,
#: etc. For example::

#:     font_family      Operator Mono Book
#:     bold_font        Operator Mono Medium
#:     italic_font      Operator Mono Book Italic
#:     bold_italic_font Operator Mono Medium Italic

  font_size ${toString variables.font.size}

#: Font size (in pts)

  force_ltr no

#: kitty does not support BIDI (bidirectional text), however, for RTL
#: scripts, words are automatically displayed in RTL. That is to say,
#: in an RTL script, the words "HELLO WORLD" display in kitty as
#: "WORLD HELLO", and if you try to select a substring of an RTL-
#: shaped string, you will get the character that would be there had
#: the the string been LTR. For example, assuming the Hebrew word
#: ירושלים, selecting the character that on the screen appears to be ם
#: actually writes into the selection buffer the character י.

#: kitty's default behavior is useful in conjunction with a filter to
#: reverse the word order, however, if you wish to manipulate RTL
#: glyphs, it can be very challenging to work with, so this option is
#: provided to turn it off. Furthermore, this option can be used with
#: the command line program GNU FriBidi
#: <https://github.com/fribidi/fribidi#executable> to get BIDI
#: support, because it will force kitty to always treat the text as
#: LTR, which FriBidi expects for terminals.

  adjust_line_height  0
  adjust_column_width 0

#: Change the size of each character cell kitty renders. You can use
#: either numbers, which are interpreted as pixels or percentages
#: (number followed by %), which are interpreted as percentages of the
#: unmodified values. You can use negative pixels or percentages less
#: than 100% to reduce sizes (but this might cause rendering
#: artifacts).

# symbol_map U+E0A0-U+E0A2,U+E0B0-U+E0B3 PowerlineSymbols

#: Map the specified unicode codepoints to a particular font. Useful
#: if you need special rendering for some symbols, such as for
#: Powerline. Avoids the need for patched fonts. Each unicode code
#: point is specified in the form U+<code point in hexadecimal>. You
#: can specify multiple code points, separated by commas and ranges
#: separated by hyphens. symbol_map itself can be specified multiple
#: times. Syntax is::

#:     symbol_map codepoints Font Family Name

  disable_ligatures never

#: Choose how you want to handle multi-character ligatures. The
#: default is to always render them.  You can tell kitty to not render
#: them when the cursor is over them by using cursor to make editing
#: easier, or have kitty never render them at all by using always, if
#: you don't like them. The ligature strategy can be set per-window
#: either using the kitty remote control facility or by defining
#: shortcuts for it in kitty.conf, for example::

#:     map alt+1 disable_ligatures_in active always
#:     map alt+2 disable_ligatures_in all never
#:     map alt+3 disable_ligatures_in tab cursor

  font_features none

#: Choose exactly which OpenType features to enable or disable. This
#: is useful as some fonts might have features worthwhile in a
#: terminal. For example, Fira Code Retina includes a discretionary
#: feature, zero, which in that font changes the appearance of the
#: zero (0), to make it more easily distinguishable from Ø. Fira Code
#: Retina also includes other discretionary features known as
#: Stylistic Sets which have the tags ss01 through ss20.

#: Note that this code is indexed by PostScript name, and not the font
#: family. This allows you to define very precise feature settings;
#: e.g. you can disable a feature in the italic font but not in the
#: regular font.

#: To get the PostScript name for a font, use kitty + list-fonts
#: --psnames::

#:     $ kitty + list-fonts --psnames | grep Fira
#:     Fira Code
#:     Fira Code Bold (FiraCode-Bold)
#:     Fira Code Light (FiraCode-Light)
#:     Fira Code Medium (FiraCode-Medium)
#:     Fira Code Regular (FiraCode-Regular)
#:     Fira Code Retina (FiraCode-Retina)

#: The part in brackets is the PostScript name.

#: Enable alternate zero and oldstyle numerals::

#:     font_features FiraCode-Retina +zero +onum

#: Enable only alternate zero::

#:     font_features FiraCode-Retina +zero

#: Disable the normal ligatures, but keep the calt feature which (in
#: this font) breaks up monotony::

#:     font_features TT2020StyleB-Regular -liga +calt

#: In conjunction with force_ltr, you may want to disable Arabic
#: shaping entirely, and only look at their isolated forms if they
#: show up in a document. You can do this with e.g.::

#:     font_features UnifontMedium +isol -medi -fina -init

  box_drawing_scale 0.001, 1, 1.5, 2

#: Change the sizes of the lines used for the box drawing unicode
#: characters These values are in pts. They will be scaled by the
#: monitor DPI to arrive at a pixel value. There must be four values
#: corresponding to thin, normal, thick, and very thick lines.

#: }}}

#: Cursor customization {{{

  cursor #cccccc

#: Default cursor color

  cursor_text_color #111111

#: Choose the color of text under the cursor. If you want it rendered
#: with the background color of the cell underneath instead, use the
#: special keyword: background

  cursor_shape beam

#: The cursor shape can be one of (block, beam, underline)

  cursor_blink_interval 1

#: The interval (in seconds) at which to blink the cursor. Set to zero
#: to disable blinking. Negative values mean use system default. Note
#: that numbers smaller than repaint_delay will be limited to
#: repaint_delay.

  cursor_stop_blinking_after 15.0

#: Stop blinking cursor after the specified number of seconds of
#: keyboard inactivity.  Set to zero to never stop blinking.

#: }}}

#: Scrollback {{{

  scrollback_lines 20000

#: Number of lines of history to keep in memory for scrolling back.
#: Memory is allocated on demand. Negative numbers are (effectively)
#: infinite scrollback. Note that using very large scrollback is not
#: recommended as it can slow down resizing of the terminal and also
#: use large amounts of RAM.

  scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER

#: Program with which to view scrollback in a new window. The
#: scrollback buffer is passed as STDIN to this program. If you change
#: it, make sure the program you use can handle ANSI escape sequences
#: for colors and text formatting. INPUT_LINE_NUMBER in the command
#: line above will be replaced by an integer representing which line
#: should be at the top of the screen.

  scrollback_pager_history_size 0

#: Separate scrollback history size, used only for browsing the
#: scrollback buffer (in MB). This separate buffer is not available
#: for interactive scrolling but will be piped to the pager program
#: when viewing scrollback buffer in a separate window. The current
#: implementation stores one character in 4 bytes, so approximatively
#: 2500 lines per megabyte at 100 chars per line. A value of zero or
#: less disables this feature. The maximum allowed size is 4GB.

  wheel_scroll_multiplier 5.0

#: Modify the amount scrolled by the mouse wheel. Note this is only
#: used for low precision scrolling devices, not for high precision
#: scrolling on platforms such as macOS and Wayland. Use negative
#: numbers to change scroll direction.

  touch_scroll_multiplier 1.0

#: Modify the amount scrolled by a touchpad. Note this is only used
#: for high precision scrolling devices on platforms such as macOS and
#: Wayland. Use negative numbers to change scroll direction.

#: }}}

#: Mouse {{{

  mouse_hide_wait 3.0

#: Hide mouse cursor after the specified number of seconds of the
#: mouse not being used. Set to zero to disable mouse cursor hiding.
#: Set to a negative value to hide the mouse cursor immediately when
#: typing text. Disabled by default on macOS as getting it to work
#: robustly with the ever-changing sea of bugs that is Cocoa is too
#: much effort.

  url_color #0087bd
  url_style curly

#: The color and style for highlighting URLs on mouse-over. url_style
#: can be one of: none, single, double, curly

#  open_url_modifiers kitty_mod

#: The modifier keys to press when clicking with the mouse on URLs to
#: open the URL

  open_url_with default

#: The program with which to open URLs that are clicked on. The
#: special value default means to use the operating system's default
#: URL handler.

  copy_on_select no

#: Copy to clipboard or a private buffer on select. With this set to
#: clipboard, simply selecting text with the mouse will cause the text
#: to be copied to clipboard. Useful on platforms such as macOS that
#: do not have the concept of primary selections. You can instead
#: specify a name such as a1 to copy to a private kitty buffer
#: instead. Map a shortcut with the paste_from_buffer action to paste
#: from this private buffer. For example::

#:     map cmd+shift+v paste_from_buffer a1

#: Note that copying to the clipboard is a security risk, as all
#: programs, including websites open in your browser can read the
#: contents of the system clipboard.

  strip_trailing_spaces never

#: Remove spaces at the end of lines when copying to clipboard. A
#: value of smart will do it when using normal selections, but not
#: rectangle selections. always will always do it.

#  rectangle_select_modifiers ctrl+alt

#: The modifiers to use rectangular selection (i.e. to select text in
#: a rectangular block with the mouse)

#  terminal_select_modifiers shift

#: The modifiers to override mouse selection even when a terminal
#: application has grabbed the mouse

  select_by_word_characters :@-./_~?&=%+#

#: Characters considered part of a word when double clicking. In
#: addition to these characters any character that is marked as an
#: alphanumeric character in the unicode database will be matched.

  click_interval -1.0

#: The interval between successive clicks to detect double/triple
#: clicks (in seconds). Negative numbers will use the system default
#: instead, if available, or fallback to 0.5.

  focus_follows_mouse no

#: Set the active window to the window under the mouse when moving the
#: mouse around

  pointer_shape_when_grabbed arrow

#: The shape of the mouse pointer when the program running in the
#: terminal grabs the mouse. Valid values are: arrow, beam and hand

#: }}}

#: Performance tuning {{{

  repaint_delay 10

#: Delay (in milliseconds) between screen updates. Decreasing it,
#: increases frames-per-second (FPS) at the cost of more CPU usage.
#: The default value yields ~100 FPS which is more than sufficient for
#: most uses. Note that to actually achieve 100 FPS you have to either
#: set sync_to_monitor to no or use a monitor with a high refresh
#: rate. Also, to minimize latency when there is pending input to be
#: processed, repaint_delay is ignored.

  input_delay 3

#: Delay (in milliseconds) before input from the program running in
#: the terminal is processed. Note that decreasing it will increase
#: responsiveness, but also increase CPU usage and might cause flicker
#: in full screen programs that redraw the entire screen on each loop,
#: because kitty is so fast that partial screen updates will be drawn.

  sync_to_monitor yes

#: Sync screen updates to the refresh rate of the monitor. This
#: prevents tearing (https://en.wikipedia.org/wiki/Screen_tearing)
#: when scrolling. However, it limits the rendering speed to the
#: refresh rate of your monitor. With a very high speed mouse/high
#: keyboard repeat rate, you may notice some slight input latency. If
#: so, set this to no.

#: }}}

#: Terminal bell {{{

  enable_audio_bell no

#: Enable/disable the audio bell. Useful in environments that require
#: silence.

  visual_bell_duration 0.0

#: Visual bell duration. Flash the screen when a bell occurs for the
#: specified number of seconds. Set to zero to disable.

  window_alert_on_bell yes

#: Request window attention on bell. Makes the dock icon bounce on
#: macOS or the taskbar flash on linux.

  bell_on_tab yes

#: Show a bell symbol on the tab if a bell occurs in one of the
#: windows in the tab and the window is not the currently focused
#: window

  command_on_bell none

#: Program to run when a bell occurs.

#: }}}

#: Window layout {{{

  remember_window_size  yes
  initial_window_width  640
  initial_window_height 400

#: If enabled, the window size will be remembered so that new
#: instances of kitty will have the same size as the previous
#: instance. If disabled, the window will initially have size
#: configured by initial_window_width/height, in pixels. You can use a
#: suffix of "c" on the width/height values to have them interpreted
#: as number of cells instead of pixels.

  enabled_layouts *

#: The enabled window layouts. A comma separated list of layout names.
#: The special value all means all layouts. The first listed layout
#: will be used as the startup layout. Default configuration is all
#: layouts in alphabetical order. For a list of available layouts, see
#: the https://sw.kovidgoyal.net/kitty/index.html#layouts.

  window_resize_step_cells 2
  window_resize_step_lines 2

#: The step size (in units of cell width/cell height) to use when
#: resizing windows. The cells value is used for horizontal resizing
#: and the lines value for vertical resizing.

  window_border_width 1.0

#: The width (in pts) of window borders. Will be rounded to the
#: nearest number of pixels based on screen resolution. Note that
#: borders are displayed only when more than one window is visible.
#: They are meant to separate multiple windows.

  draw_minimal_borders yes

#: Draw only the minimum borders needed. This means that only the
#: minimum needed borders for inactive windows are drawn. That is only
#: the borders that separate the inactive window from a neighbor. Note
#: that setting a non-zero window margin overrides this and causes all
#: borders to be drawn.

  window_margin_width 0.0

#: The window margin (in pts) (blank area outside the border)

  single_window_margin_width -1000.0

#: The window margin (in pts) to use when only a single window is
#: visible. Negative values will cause the value of
#: window_margin_width to be used instead.

  window_padding_width 0.0

#: The window padding (in pts) (blank area between the text and the
#: window border)

  placement_strategy center

#: When the window size is not an exact multiple of the cell size, the
#: cell area of the terminal window will have some extra padding on
#: the sides. You can control how that padding is distributed with
#: this option. Using a value of center means the cell area will be
#: placed centrally. A value of top-left means the padding will be on
#: only the bottom and right edges.

  active_border_color #00ff00

#: The color for the border of the active window. Set this to none to
#: not draw borders around the active window.

  inactive_border_color #cccccc

#: The color for the border of inactive windows

  bell_border_color #ff5a00

#: The color for the border of inactive windows in which a bell has
#: occurred

  inactive_text_alpha 1.0

#: Fade the text in inactive windows by the specified amount (a number
#: between zero and one, with zero being fully faded).

  hide_window_decorations yes

#: Hide the window decorations (title-bar and window borders) with
#: yes. On macOS, titlebar-only can be used to only hide the titlebar.
#: Whether this works and exactly what effect it has depends on the
#: window manager/operating system.

  resize_debounce_time 0.1

#: The time (in seconds) to wait before redrawing the screen when a
#: resize event is received. On platforms such as macOS, where the
#: operating system sends events corresponding to the start and end of
#: a resize, this number is ignored.

  resize_draw_strategy static

#: Choose how kitty draws a window while a resize is in progress. A
#: value of static means draw the current window contents, mostly
#: unchanged. A value of scale means draw the current window contents
#: scaled. A value of blank means draw a blank window. A value of size
#: means show the window size in cells.

  resize_in_steps no

#: Resize the OS window in steps as large as the cells, instead of
#: with the usual pixel accuracy. Combined with an
#: initial_window_width and initial_window_height in number of cells,
#: this option can be used to keep the margins as small as possible
#: when resizing the OS window. Note that this does not currently work
#: on Wayland.

#: }}}

#: Tab bar {{{

  tab_bar_edge top

#: Which edge to show the tab bar on, top or bottom

  tab_bar_margin_width 0.0

#: The margin to the left and right of the tab bar (in pts)

  tab_bar_style separator

#: The tab bar style, can be one of: fade, separator, powerline, or
#: hidden. In the fade style, each tab's edges fade into the
#: background color, in the separator style, tabs are separated by a
#: configurable separator, and the powerline shows the tabs as a
#: continuous line.

  tab_bar_min_tabs 2

#: The minimum number of tabs that must exist before the tab bar is
#: shown

  tab_switch_strategy previous

#: The algorithm to use when switching to a tab when the current tab
#: is closed. The default of previous will switch to the last used
#: tab. A value of left will switch to the tab to the left of the
#: closed tab. A value of last will switch to the right-most tab.

  tab_fade 0.25 0.5 0.75 1

#: Control how each tab fades into the background when using fade for
#: the tab_bar_style. Each number is an alpha (between zero and one)
#: that controls how much the corresponding cell fades into the
#: background, with zero being no fade and one being full fade. You
#: can change the number of cells used by adding/removing entries to
#: this list.

  tab_separator " ┇ "

#: The separator between tabs in the tab bar when using separator as
#: the tab_bar_style.

  tab_title_template " {title} "

#: A template to render the tab title. The default just renders the
#: title. If you wish to include the tab-index as well, use something
#: like: {index}: {title}. Useful if you have shortcuts mapped for
#: goto_tab N.

  active_tab_title_template none

#: Template to use for active tabs, if not specified falls back to
#: tab_title_template.

  active_tab_foreground   #000
  active_tab_background   #eee
  active_tab_font_style   bold-italic
  inactive_tab_foreground #444
  inactive_tab_background #999
  inactive_tab_font_style normal

#: Tab bar colors and styles

  tab_bar_background none

#: Background color for the tab bar. Defaults to using the terminal
#: background color.

#: }}}

#: Color scheme {{{

  foreground #dddddd
  background #111111

#: The foreground and background colors

  background_opacity 0.95

#: The opacity of the background. A number between 0 and 1, where 1 is
#: opaque and 0 is fully transparent.  This will only work if
#: supported by the OS (for instance, when using a compositor under
#: X11). Note that it only sets the default background color's
#: opacity. This is so that things like the status bar in vim,
#: powerline prompts, etc. still look good.  But it means that if you
#: use a color theme with a background color in your editor, it will
#: not be rendered as transparent.  Instead you should change the
#: default background color in your kitty config and not use a
#: background color in the editor color scheme. Or use the escape
#: codes to set the terminals default colors in a shell script to
#: launch your editor.  Be aware that using a value less than 1.0 is a
#: (possibly significant) performance hit.  If you want to dynamically
#: change transparency of windows set dynamic_background_opacity to
#: yes (this is off by default as it has a performance cost)

  dynamic_background_opacity no

#: Allow changing of the background_opacity dynamically, using either
#: keyboard shortcuts (increase_background_opacity and
#: decrease_background_opacity) or the remote control facility.

  dim_opacity 0.75

#: How much to dim text that has the DIM/FAINT attribute set. One
#: means no dimming and zero means fully dimmed (i.e. invisible).

  selection_foreground #000000

#: The foreground for text selected with the mouse. A value of none
#: means to leave the color unchanged.

  selection_background #fffacd

#: The background for text selected with the mouse.


#: The 16 terminal colors. There are 8 basic colors, each color has a
#: dull and bright version. You can also set the remaining colors from
#: the 256 color table as color16 to color255.

  color0 #000000
  color8 #767676

#: black

  color1 #cc0403
  color9 #f2201f

#: red

  color2  #19cb00
  color10 #23fd00

#: green

  color3  #cecb00
  color11 #fffd00

#: yellow

  color4  #0d73cc
  color12 #1a8fff

#: blue

  color5  #cb1ed1
  color13 #fd28ff

#: magenta

  color6  #0dcdcd
  color14 #14ffff

#: cyan

  color7  #dddddd
  color15 #ffffff

#: white

  mark1_foreground black

#: Color for marks of type 1

  mark1_background #98d3cb

#: Color for marks of type 1 (light steel blue)

  mark2_foreground black

#: Color for marks of type 2

  mark2_background #f2dcd3

#: Color for marks of type 1 (beige)

  mark3_foreground black

#: Color for marks of type 3

  mark3_background #f274bc

#: Color for marks of type 1 (violet)

#: }}}

#: Advanced {{{

  shell .

#: The shell program to execute. The default value of . means to use
#: whatever shell is set as the default shell for the current user.
#: Note that on macOS if you change this, you might need to add
#: --login to ensure that the shell starts in interactive mode and
#: reads its startup rc files.

  editor .

#: The console editor to use when editing the kitty config file or
#: similar tasks. A value of . means to use the environment variables
#: VISUAL and EDITOR in that order. Note that this environment
#: variable has to be set not just in your shell startup scripts but
#: system-wide, otherwise kitty will not see it.

  close_on_child_death no

#: Close the window when the child process (shell) exits. If no (the
#: default), the terminal will remain open when the child exits as
#: long as there are still processes outputting to the terminal (for
#: example disowned or backgrounded processes). If yes, the window
#: will close as soon as the child process exits. Note that setting it
#: to yes means that any background processes still using the terminal
#: can fail silently because their stdout/stderr/stdin no longer work.

  allow_remote_control no

#: Allow other programs to control kitty. If you turn this on other
#: programs can control all aspects of kitty, including sending text
#: to kitty windows, opening new windows, closing windows, reading the
#: content of windows, etc.  Note that this even works over ssh
#: connections. You can chose to either allow any program running
#: within kitty to control it, with yes or only programs that connect
#: to the socket specified with the kitty --listen-on command line
#: option, if you use the value socket-only. The latter is useful if
#: you want to prevent programs running on a remote computer over ssh
#: from controlling kitty.

# env

#: Specify environment variables to set in all child processes. Note
#: that environment variables are expanded recursively, so if you
#: use::

#:     env MYVAR1=a
#:     env MYVAR2=''${MYVAR1}/''${HOME}/b

#: The value of MYVAR2 will be a/<path to home directory>/b.

  update_check_interval 24

#: Periodically check if an update to kitty is available. If an update
#: is found a system notification is displayed informing you of the
#: available update. The default is to check every 24 hrs, set to zero
#: to disable.

  startup_session none

#: Path to a session file to use for all kitty instances. Can be
#: overridden by using the kitty --session command line option for
#: individual instances. See
#: https://sw.kovidgoyal.net/kitty/index.html#sessions in the kitty
#: documentation for details. Note that relative paths are interpreted
#: with respect to the kitty config directory. Environment variables
#: in the path are expanded.

  clipboard_control write-clipboard write-primary

#: Allow programs running in kitty to read and write from the
#: clipboard. You can control exactly which actions are allowed. The
#: set of possible actions is: write-clipboard read-clipboard write-
#: primary read-primary. You can additionally specify no-append to
#: disable kitty's protocol extension for clipboard concatenation. The
#: default is to allow writing to the clipboard and primary selection
#: with concatenation enabled. Note that enabling the read
#: functionality is a security risk as it means that any program, even
#: one running on a remote server via SSH can read your clipboard.

  term xterm-256color

#: The value of the TERM environment variable to set. Changing this
#: can break many terminal programs, only change it if you know what
#: you are doing, not because you read some advice on Stack Overflow
#: to change it. The TERM variable is used by various programs to get
#: information about the capabilities and behavior of the terminal. If
#: you change it, depending on what programs you run, and how
#: different the terminal you are changing it to is, various things
#: from key-presses, to colors, to various advanced features may not
#: work.

#: }}}

#: OS specific tweaks {{{

  macos_titlebar_color system

#: Change the color of the kitty window's titlebar on macOS. A value
#: of system means to use the default system color, a value of
#: background means to use the background color of the currently
#: active window and finally you can use an arbitrary color, such as
#: #12af59 or red. WARNING: This option works by using a hack, as
#: there is no proper Cocoa API for it. It sets the background color
#: of the entire window and makes the titlebar transparent. As such it
#: is incompatible with background_opacity. If you want to use both,
#: you are probably better off just hiding the titlebar with
#: hide_window_decorations.

  macos_option_as_alt no

#: Use the option key as an alt key. With this set to no, kitty will
#: use the macOS native Option+Key = unicode character behavior. This
#: will break any Alt+key keyboard shortcuts in your terminal
#: programs, but you can use the macOS unicode input technique. You
#: can use the values: left, right, or both to use only the left,
#: right or both Option keys as Alt, instead.

  macos_hide_from_tasks no

#: Hide the kitty window from running tasks (Option+Tab) on macOS.

  macos_quit_when_last_window_closed no

#: Have kitty quit when all the top-level windows are closed. By
#: default, kitty will stay running, even with no open windows, as is
#: the expected behavior on macOS.

  macos_window_resizable yes

#: Disable this if you want kitty top-level (OS) windows to not be
#: resizable on macOS.

  macos_thicken_font 0

#: Draw an extra border around the font with the given width, to
#: increase legibility at small font sizes. For example, a value of
#: 0.75 will result in rendering that looks similar to sub-pixel
#: antialiasing at common font sizes.

  macos_traditional_fullscreen no

#: Use the traditional full-screen transition, that is faster, but
#: less pretty.

  macos_show_window_title_in all

#: Show or hide the window title in the macOS window or menu-bar. A
#: value of window will show the title of the currently active window
#: at the top of the macOS window. A value of menubar will show the
#: title of the currently active window in the macOS menu-bar, making
#: use of otherwise wasted space. all will show the title everywhere
#: and none hides the title in the window and the menu-bar.

  macos_custom_beam_cursor no

#: Enable/disable custom mouse cursor for macOS that is easier to see
#: on both light and dark backgrounds. WARNING: this might make your
#: mouse cursor invisible on dual GPU machines.

  linux_display_server auto

#: Choose between Wayland and X11 backends. By default, an appropriate
#: backend based on the system state is chosen automatically. Set it
#: to x11 or wayland to force the choice.

#: }}}

#: Keyboard shortcuts {{{

#: For a list of key names, see: GLFW keys
#: <https://www.glfw.org/docs/latest/group__keys.html>. The name to
#: use is the part after the GLFW_KEY_ prefix. For a list of modifier
#: names, see: GLFW mods
#: <https://www.glfw.org/docs/latest/group__mods.html>

#: On Linux you can also use XKB key names to bind keys that are not
#: supported by GLFW. See XKB keys
#: <https://github.com/xkbcommon/libxkbcommon/blob/master/xkbcommon/xkbcommon-
#: keysyms.h> for a list of key names. The name to use is the part
#: after the XKB_KEY_ prefix. Note that you should only use an XKB key
#: name for keys that are not present in the list of GLFW keys.

#: Finally, you can use raw system key codes to map keys. To see the
#: system key code for a key, start kitty with the kitty --debug-
#: keyboard option. Then kitty will output some debug text for every
#: key event. In that text look for ``native_code`` the value of that
#: becomes the key name in the shortcut. For example:

#: .. code-block:: none

#:     on_key_input: glfw key: 65 native_code: 0x61 action: PRESS mods: 0x0 text: 'a'

#: Here, the key name for the A key is 0x61 and you can use it with::

#:     map ctrl+0x61 something

#: to map ctrl+a to something.

#: You can use the special action no_op to unmap a keyboard shortcut
#: that is assigned in the default configuration::

#:     map kitty_mod+space no_op

#: You can combine multiple actions to be triggered by a single
#: shortcut, using the syntax below::

#:     map key combine <separator> action1 <separator> action2 <separator> action3 ...

#: For example::

#:     map kitty_mod+e combine : new_window : next_layout

#: this will create a new window and switch to the next available
#: layout

#: You can use multi-key shortcuts using the syntax shown below::

#:     map key1>key2>key3 action

#: For example::

#:     map ctrl+f>2 set_font_size 20

  kitty_mod ctrl+shift

#: The value of kitty_mod is used as the modifier for all default
#: shortcuts, you can change it in your kitty.conf to change the
#: modifiers for all the default shortcuts.

  clear_all_shortcuts no

#: You can have kitty remove all shortcut definition seen up to this
#: point. Useful, for instance, to remove the default shortcuts.

# kitten_alias hints hints --hints-offset=0

#: You can create aliases for kitten names, this allows overriding the
#: defaults for kitten options and can also be used to shorten
#: repeated mappings of the same kitten with a specific group of
#: options. For example, the above alias changes the default value of
#: kitty +kitten hints --hints-offset to zero for all mappings,
#: including the builtin ones.

#: Clipboard {{{

  map kitty_mod+c copy_to_clipboard

#: There is also a copy_or_interrupt action that can be optionally
#: mapped to Ctrl+c. It will copy only if there is a selection and
#: send an interrupt otherwise.

  map kitty_mod+v  paste_from_clipboard
  map kitty_mod+s  paste_from_selection
  map shift+insert paste_from_selection
  map kitty_mod+o  pass_selection_to_program

#: You can also pass the contents of the current selection to any
#: program using pass_selection_to_program. By default, the system's
#: open program is used, but you can specify your own, the selection
#: will be passed as a command line argument to the program, for
#: example::

#:     map kitty_mod+o pass_selection_to_program firefox

#: You can pass the current selection to a terminal program running in
#: a new kitty window, by using the @selection placeholder::

#:     map kitty_mod+y new_window less @selection

#: }}}

#: Scrolling {{{

  map kitty_mod+up        scroll_line_up
  map kitty_mod+k         scroll_line_up
  map kitty_mod+down      scroll_line_down
  map kitty_mod+j         scroll_line_down
  map kitty_mod+page_up   scroll_page_up
  map kitty_mod+page_down scroll_page_down
  map kitty_mod+home      scroll_home
  map kitty_mod+end       scroll_end
  map kitty_mod+h         show_scrollback

#: You can pipe the contents of the current screen + history buffer as
#: STDIN to an arbitrary program using the ``launch`` function. For
#: example, the following opens the scrollback buffer in less in an
#: overlay window::

  map kitty_mod+f launch --stdin-source=@screen_scrollback --stdin-add-formatting --type=overlay ${pkgs.less}/bin/less +G -r

#: For more details on piping screen and buffer contents to external
#: programs, see launch.

#: }}}

#: Window management {{{

  map kitty_mod+enter new_window

#: You can open a new window running an arbitrary program, for
#: example::

#:     map kitty_mod+y      launch mutt

#: You can open a new window with the current working directory set to
#: the working directory of the current window using::

#:     map ctrl+alt+enter    launch --cwd=current

#: You can open a new window that is allowed to control kitty via the
#: kitty remote control facility by prefixing the command line with @.
#: Any programs running in that window will be allowed to control
#: kitty. For example::

#:     map ctrl+enter launch --allow-remote-control some_program

#: You can open a new window next to the currently active window or as
#: the first window, with::

#:     map ctrl+n launch --location=neighbor some_program
#:     map ctrl+f launch --location=first some_program

#: For more details, see launch.

  map kitty_mod+n new_os_window

#: Works like new_window above, except that it opens a top level OS
#: kitty window. In particular you can use new_os_window_with_cwd to
#: open a window with the current working directory.

  map kitty_mod+w close_window
  map kitty_mod+] next_window
  map kitty_mod+[ previous_window
  #map kitty_mod+f move_window_forward
  #map kitty_mod+b move_window_backward
  map kitty_mod+` move_window_to_top
  map kitty_mod+r start_resizing_window
  map kitty_mod+1 first_window
  map kitty_mod+2 second_window
  map kitty_mod+3 third_window
  map kitty_mod+4 fourth_window
  map kitty_mod+5 fifth_window
  map kitty_mod+6 sixth_window
  map kitty_mod+7 seventh_window
  map kitty_mod+8 eighth_window
  map kitty_mod+9 ninth_window
  map kitty_mod+0 tenth_window
#: }}}

#: Tab management {{{

  map ctrl+page_down      next_tab
  map ctrl+page_up        previous_tab
  map ctrl+shift+t        new_tab_with_cwd
  map kitty_mod+q         close_tab
  map ctrl+shift+page_down     move_tab_forward
  map ctrl+shift+page_up     move_tab_backward
  map kitty_mod+alt+t set_tab_title

#: You can also create shortcuts to go to specific tabs, with 1 being
#: the first tab, 2 the second tab and -1 being the previously active
#: tab, and any number larger than the last tab being the last tab::

#:     map ctrl+alt+1 goto_tab 1
#:     map ctrl+alt+2 goto_tab 2

#: Just as with new_window above, you can also pass the name of
#: arbitrary commands to run when using new_tab and use
#: new_tab_with_cwd. Finally, if you want the new tab to open next to
#: the current tab rather than at the end of the tabs list, use::

#:     map ctrl+t new_tab !neighbor [optional cmd to run]
#: }}}

#: Layout management {{{

  map kitty_mod+l next_layout

#: You can also create shortcuts to switch to specific layouts::

#:     map ctrl+alt+t goto_layout tall
#:     map ctrl+alt+s goto_layout stack

#: Similarly, to switch back to the previous layout::

#:    map ctrl+alt+p last_used_layout
#: }}}

#: Font sizes {{{

#: You can change the font size for all top-level kitty OS windows at
#: a time or only the current one.

  map kitty_mod+equal     change_font_size all +2.0
  map kitty_mod+minus     change_font_size all -2.0
  map kitty_mod+backspace change_font_size all 0

#: To setup shortcuts for specific font sizes::

#:     map kitty_mod+f6 change_font_size all 10.0

#: To setup shortcuts to change only the current OS window's font
#: size::

#:     map kitty_mod+f6 change_font_size current 10.0
#: }}}

#: Select and act on visible text {{{

#: Use the hints kitten to select text and either pass it to an
#: external program or insert it into the terminal or copy it to the
#: clipboard.

  map kitty_mod+e kitten hints

#: Open a currently visible URL using the keyboard. The program used
#: to open the URL is specified in open_url_with.

  map kitty_mod+p>f kitten hints --type path --program -

#: Select a path/filename and insert it into the terminal. Useful, for
#: instance to run git commands on a filename output from a previous
#: git command.

  map kitty_mod+p>shift+f kitten hints --type path

#: Select a path/filename and open it with the default open program.

  map kitty_mod+p>l kitten hints --type line --program -

#: Select a line of text and insert it into the terminal. Use for the
#: output of things like: ls -1

  map kitty_mod+p>w kitten hints --type word --program -

#: Select words and insert into terminal.

  map kitty_mod+p>h kitten hints --type hash --program -

#: Select something that looks like a hash and insert it into the
#: terminal. Useful with git, which uses sha1 hashes to identify
#: commits

  map kitty_mod+p>n kitten hints --type linenum

#: Select something that looks like filename:linenum and open it in
#: vim at the specified line number.


#: The hints kitten has many more modes of operation that you can map
#: to different shortcuts. For a full description see kittens/hints.
#: }}}

#: Miscellaneous {{{

  map kitty_mod+f11    toggle_fullscreen
  map kitty_mod+f10    toggle_maximized
  map kitty_mod+u      kitten unicode_input
  map kitty_mod+f2     edit_config_file
  map kitty_mod+escape kitty_shell window

#: Open the kitty shell in a new window/tab/overlay/os_window to
#: control kitty using commands.

  map kitty_mod+a>m    set_background_opacity +0.1
  map kitty_mod+a>l    set_background_opacity -0.1
  map kitty_mod+a>1    set_background_opacity 1
  map kitty_mod+a>d    set_background_opacity default
  map kitty_mod+delete clear_terminal reset active

#: You can create shortcuts to clear/reset the terminal. For example::

#:     # Reset the terminal
#:     map kitty_mod+f9 clear_terminal reset active
#:     # Clear the terminal screen by erasing all contents
#:     map kitty_mod+f10 clear_terminal clear active
#:     # Clear the terminal scrollback by erasing it
#:     map kitty_mod+f11 clear_terminal scrollback active
#:     # Scroll the contents of the screen into the scrollback
#:     map kitty_mod+f12 clear_terminal scroll active

#: If you want to operate on all windows instead of just the current
#: one, use all instead of active.

#: It is also possible to remap Ctrl+L to both scroll the current
#: screen contents into the scrollback buffer and clear the screen,
#: instead of just clearing the screen::

#:     map ctrl+l combine : clear_terminal scroll active : send_text normal,application \x0c


#: You can tell kitty to send arbitrary (UTF-8) encoded text to the
#: client program when pressing specified shortcut keys. For example::

#:     map ctrl+alt+a send_text all Special text

#: This will send "Special text" when you press the ctrl+alt+a key
#: combination.  The text to be sent is a python string literal so you
#: can use escapes like \x1b to send control codes or \u21fb to send
#: unicode characters (or you can just input the unicode characters
#: directly as UTF-8 text). The first argument to send_text is the
#: keyboard modes in which to activate the shortcut. The possible
#: values are normal or application or kitty or a comma separated
#: combination of them.  The special keyword all means all modes. The
#: modes normal and application refer to the DECCKM cursor key mode
#: for terminals, and kitty refers to the special kitty extended
#: keyboard protocol.

#: Another example, that outputs a word and then moves the cursor to
#: the start of the line (same as pressing the Home key)::

#:     map ctrl+alt+a send_text normal Word\x1b[H
#:     map ctrl+alt+a send_text application Word\x1bOH

#: }}}

# }}}
include ./theme.conf
  '';
} {
  target = "${variables.homeDir}/.config/kitty/theme.conf";
  source = pkgs.writeText "theme.conf" ''
background #20211d
foreground #e3e5d8

cursor #fdfff1
cursor_text_color #000000
selection_foreground none
selection_background #636559

active_tab_foreground   #20211d
active_tab_background   #afb1a7
active_tab_font_style   bold-italic
inactive_tab_foreground #3b3c35
inactive_tab_background #636559
inactive_tab_font_style normal

# dull black
color0 #3b3c35
# light black
color8 #6e7066

# dull red
color1 #f82570
# light red
color9 #f82570

# dull green
color2 #a6e12d
# light green
color10 #a6e12d

# yellow
color3 #e4db73
# light yellow
color11 #e4db73

# blue
color4 #fc961f
# light blue
color12 #fc961f

# magenta
color5 #ae81ff
# light magenta
color13 #ae81ff

# cyan
color6 #66d9ee
# light cyan
color14 #66d9ee

# dull white
color7 #fdfff1
# bright white
color15 #fdfff1
  '';
}]
