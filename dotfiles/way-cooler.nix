{ variables, config, pkgs, lib }:
let
  wc-bar-bare = pkgs.runCommand "bar.py" {
    name = "wc-bar-bare-2017-12-05";

    src = ./way-cooler/bar.py;

    pythonPath = with pkgs.python3Packages; [ pydbus ];
    nativeBuildInputs = with pkgs.python3Packages; [ python wrapPython ];

  } ''
    install -Dm755 $src $out/bin/bar.py
    patchShebangs $out/bin/bar.py
    wrapPythonPrograms
  '';

  wc-bar = pkgs.writeScript "lemonbar" ''
    #!${pkgs.stdenv.shell}
    SELECTED="#A6E22E"
    SELECTED_OTHER_WORKSPACE="#E6DB74"
    BACKGROUND="#AA272822"
    # https://github.com/way-cooler/way-cooler/issues/446#issuecomment-349471439
    sleep 5
    ${wc-bar-bare}/bin/bar.py $SELECTED $BACKGROUND $SELECTED_OTHER_WORKSPACE 2> /tmp/bar_debug.txt | ${pkgs.lemonbar-xft}/bin/lemonbar -f "${variables.font}" -B $BACKGROUND -F "#EEEEEE" -n "lemonbar" -p -d
  '';

in {
  target = "${variables.homeDir}/.config/way-cooler/init.lua";
  source = pkgs.writeScript "way-cooler.lua" ''
    -- Lua configration file for way-cooler. Ran at startup and when restarted.

    -- Programs that Way Cooler can run
    way_cooler.programs = {
      -- Name of the window that will be the bar window.
      -- This is a hack to get X11 bars and non-Way Cooler supported bars working.
      --
      -- Make sure you set your bar program to spawn at startup!
      -- x11_bar = "lemonbar",
    }

    -- Registering programs to run at startup
    -- These programs are only ran once util.program.spawn_programs is called.
    util.program.spawn_at_startup("wc-bg -f ${variables.wallpaper}")

    -- These options are applied to all windows.
    way_cooler.windows = {
      gaps = { -- Options for gaps
        size = 10, -- The width of gaps between windows in pixels
      },
      borders = { -- Options for borders
        root_borders = false, -- Display borders in root containers by default
        size = 2, -- The width of the borders between windows in pixels
        inactive_color = "1E1F1C", -- Color of the borders for inactive containers
        active_color = "A6E22E" -- Color of active container borders
      },
      title_bar = { -- Options for title bar above windows
        size = 0, -- Size of the title bar
        background_color = "1E1F1C", -- Color of inactive title bar
        active_background_color = "272822", -- Color of active title bar
        font_color = "939393", -- Color of the font for an inactive title bar
        active_font_color = "A6E22E" -- Color of font for active title bar
      }
    }

    -- Options that change how the mouse behaves.
    way_cooler.mouse = {
      -- Locks the mouse to the corner of the window the user is resizing.
      lock_to_corner_on_resize = false
    }

    --
    -- Keybindings
    --
    -- Create an array of keybindings and call way_cooler.register_keys()
    -- to register them.
    -- Declaring a keybinding:
    -- key(<modifiers list>, <key>, <function or name>, [repeat])

    -- <modifiers list>: Modifiers (mod4, shift, control) to be used

    -- <key>: Name of the key to be pressed. See xkbcommon keysym names.

    -- <function or name> If a string, the way-cooler command to be run.
    -- If a function, a Lua function to run on the keypress. The function takes
    -- a list of key names as input (i.e. { "mod4", "shift", "a" }) if needed.

    -- [repeat]: Optional boolean defaults to true - if false, the command will
    -- will not follow "hold down key to repeat" rules, and will only run once,
    -- waiting until the keys are released to run again.

    -- Modifier key used in keybindings. Mod3 = Alt, Mod4 = Super/Logo key
    mod = "Super"

    -- Aliases to save on typing
    local key = way_cooler.key

    local keys = {
      -- Open dmenu
      key({ "control", "alt" }, "space", util.program.spawn_once("${variables.programs.launcher}")),

      -- Open terminal
      key({ "control", "alt" }, "t", util.program.spawn_once("${variables.terminal}")),

      -- lock screen
      key({ "control", "alt" }, "l", util.program.spawn_once("wc-lock --fancy-blur")),

      -- Lua methods can be bound as well
      key({ mod, "Shift" }, "h", function () print("Hello world!") end),

      -- Move focus
      key({ mod }, "left", "focus_left"),
      key({ mod }, "right", "focus_right"),
      key({ mod }, "up", "focus_up"),
      key({ mod }, "down", "focus_down"),

      -- Move active container
      key({ mod, "Shift" }, "left", "move_active_left"),
      key({ mod, "Shift" }, "right", "move_active_right"),
      key({ mod, "Shift" }, "up", "move_active_up"),
      key({ mod, "Shift" }, "down", "move_active_down"),

      -- Split containers
      key({ mod }, "h", "split_horizontal"),
      key({ mod }, "v", "split_vertical"),
      key({ mod }, "e", "horizontal_vertical_switch"),
      key({ mod }, "s", "tile_stacked"),
      key({ mod }, "w", "tile_tabbed"),
      key({ mod }, "f", "fullscreen_toggle"),
      key({ mod, "Shift" }, "q", "close_window"),
      key({ mod, "Shift" }, "space", "toggle_float_active"),
      key({ mod }, "space", "toggle_float_focus"),
      key({ mod, "Shift" }, "r", "way_cooler_restart"),

      -- Quitting way-cooler is hardcoded to Alt+Shift+Esc.
      -- If rebound, then this keybinding is cleared.
      key({ mod, "Shift" }, "e", "way_cooler_quit"),
    }

    -- Add Mod + X bindings to switch to workspace X, Mod+Shift+X send active to X
    for i = 1, 9 do
      table.insert(keys,
                   key({ mod }, tostring(i), "switch_workspace_" .. i))
      table.insert(keys,
                   key({ mod, "Shift" }, tostring(i), "move_to_workspace_" .. i))
    end

    -- Register the keybindings.
    for _, key in pairs(keys) do
        way_cooler.register_key(key)
    end

    -- Converts a list of modifiers to a string
    local function keys_to_string(keys)
        keys = {table.unpack(keys)}
        return table.concat(keys, ',')
    end
    -- Save the action at the __key_map and tell Rust to register the Lua key
    local function register_lua_key(index, action, loop, passthrough)
        local map_ix = __rust.register_lua_key(index, loop, passthrough)
        __key_map[map_ix] = action
    end

    -- Register a keybinding
    my_register_key = function(keys, action, loop, passthrough)
        if (type(action) == 'string') then
            __rust.register_command_key(keys_to_string(keys),
                                      action, loop, passthrough)
        elseif (type(action) == 'function') then
            register_lua_key(keys_to_string(keys),
                                  action, loop, passthrough)
        else
            error("keybinding action: expected string or a function")
        end
    end

    -- my_register_key({"XF86Search"}, beje, true, false)
    my_register_key({"XF86Explorer"}, util.program.spawn_once("${variables.dropDownTerminal}"), true, false)
    my_register_key({"F12"}, util.program.spawn_once("${variables.dropDownTerminal}"), true, false)

    -- Register the mod key to also be the mod key for mouse commands
    way_cooler.register_mouse_modifier(mod)

    -- Execute some code after Way Cooler is finished initializing
    way_cooler.on_init = function()
      util.program.spawn_startup_programs()
    end

    --- Execute some code when Way Cooler restarts
    way_cooler.on_restart = function()
      util.program.restart_startup_programs()
    end

    --- Execute some code when Way Cooler terminates
    way_cooler.on_terminate = function()
      util.program.terminate_startup_programs()
    end

    util.program.spawn_at_startup("${wc-bar}")
  '';
}
