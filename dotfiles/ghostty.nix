{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/ghostty/config";
  source = pkgs.writeScript "ghostty.config" ''
    theme = Monokai Soda
    font-family = ${variables.font.family}
    font-size = ${toString variables.font.size}
    background-opacity = 0.95
    window-decoration = false
    cursor-invert-fg-bg = true
    keybind = ctrl+shift+page_down=move_tab:+1
    keybind = ctrl+shift+page_up=move_tab:-1
    keybind = alt+k>up=new_split:up
    keybind = alt+k>down=new_split:down
    keybind = alt+k>right=new_split:right
    keybind = alt+k>left=new_split:left
    keybind = alt+up=goto_split:top
    keybind = alt+down=goto_split:bottom
    keybind = alt+right=goto_split:right
    keybind = alt+left=goto_split:left
  '';
}
