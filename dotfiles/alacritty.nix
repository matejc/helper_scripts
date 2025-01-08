{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/alacritty/alacritty.toml";
  source = pkgs.writeText "alacritty.toml" ''
    [[keyboard.bindings]]
    action = "ResetFontSize"
    key = "Key0"
    mods = "Control"

    [[keyboard.bindings]]
    action = "IncreaseFontSize"
    key = "Equals"
    mods = "Control"

    [[keyboard.bindings]]
    action = "DecreaseFontSize"
    key = "Minus"
    mods = "Control"

    [[keyboard.bindings]]
    key = "F"
    mods = "Control|Shift"

    [keyboard.bindings.command]
    args = ["action", "switch-mode", "entersearch"]
    program = "${pkgs.zellij}/bin/zellij"

    [general]
    live_config_reload = true

    [terminal]

    [[mouse.bindings]]
    action = "PasteSelection"
    mouse = "Middle"

    [colors.bright]
    black = "0x75715e"
    blue = "0x66d9ef"
    cyan = "0xa1efe4"
    green = "0xa6e22e"
    magenta = "0xae81ff"
    red = "0xf92672"
    white = "0xf8f8f2"
    yellow = "0xf4bf75"

    [colors.normal]
    black = "0x272822"
    blue = "0x66d9ef"
    cyan = "0xa1efe4"
    green = "0xa6e22e"
    magenta = "0xae81ff"
    red = "0xf92672"
    white = "0xf8f8f2"
    yellow = "0xf4bf75"

    [colors.primary]
    background = "0x282828"
    foreground = "0xf8f8f2"

    [cursor]
    style = "Beam"

    [font]
    size = ${toString variables.font.size}

    [font.bold]
    style = "Bold"

    [font.bold_italic]
    style = "Bold Italic"

    [font.italic]
    style = "Italic"

    [font.normal]
    family = "${variables.font.family}"
    style = "Normal"

    [mouse]
    hide_when_typing = true

    [scrolling]
    history = 10000
    multiplier = 3

    [terminal.shell]
    args = ["--login", "-c", "${pkgs.zellij}/bin/zellij"]
    program = "${variables.shell}"

    [window]
    startup_mode = "Windowed"
    opacity = 0.95

    [window.padding]
    x = 1
    y = 1

    [keyboard]
  '';
}
