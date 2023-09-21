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
      unbind "Ctrl t" "Ctrl s" "Ctrl g" "Ctrl n" "Ctrl q" "Ctrl o" "Ctrl p" "Ctrl h" "Ctrl b"
      normal {
        bind "Ctrl PageDown" { GoToNextTab; }
        bind "Ctrl PageUp" { GoToPreviousTab; }
      }
    }
  '';
}
