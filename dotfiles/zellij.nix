{ variables, pkgs, config, lib }:
{
  target = "${variables.homeDir}/.config/zellij/config.kdl";
  source = pkgs.writeText "zellij.kdl" ''
    simplified_ui true
    default_layout "compact"
    copy_command "${pkgs.wl-clipboard}/bin/wl-copy"
    default_shell "${variables.profileDir}/bin/zsh"
    pane_frames false
    keybinds {
        normal {
            bind "Ctrl PageDown" { GoToNextTab; }
            bind "Ctrl PageUp" { GoToPreviousTab; }
            bind "Ctrl Shift W" { CloseTab; }
            bind "Ctrl Shift T" { NewTab; }
        }
    }
  '';
}
