{ variables, pkgs, config, lib }:
{
  target = "${variables.homeDir}/.config/zellij/config.kdl";
  source = pkgs.writeText "zellij.kdl" ''
    simplified_ui true
    default_layout "compact"
    copy_command "${pkgs.wl-clipboard}/bin/wl-copy"
    default_shell "${variables.shell}"
    pane_frames false
    keybinds {
      unbind { "Ctrl t"; "Ctrl s"; "Ctrl g"; "Ctrl n"; "Ctrl q"; "Ctrl o"; "Ctrl p"; "Ctrl h"; "Ctrl b"; }
      normal {
        bind "Ctrl PageDown" { GoToNextTab; }
        bind "Ctrl PageUp" { GoToPreviousTab; }
        bind "Ctrl Shift T" { NewTab; }
        bind "Ctrl Shift W" { CloseTab; }
        bind "Ctrl Shift Q" { Quit; }
        bind "Ctrl Shift F" { SwitchToMode "entersearch"; }
        bind "Shift PageDown" { HalfPageScrollDown; }
        bind "Shift PageUp" { HalfPageScrollUp; }
        bind "Shift Up" { ScrollUp; }
        bind "Shift Down" { ScrollDown; }
        bind "Shift End" { ScrollToBottom; }
        bind "Shift Home" { ScrollToTop; }
      }
      search {
        bind "Ctrl Shift N" { Search "up"; }
        bind "Ctrl n" { Search "down"; }
      }
    }
  '';
}
