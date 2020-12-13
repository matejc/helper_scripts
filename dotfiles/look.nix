{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.local/share/icons/breeze";
  source = "${pkgs.breeze-icons}/share/icons/breeze";
} {
  target = "${variables.homeDir}/.local/share/themes/Breeze";
  source = "${pkgs.breeze-gtk}/share/themes/Breeze";
} {
  target = "${variables.homeDir}/.gtkrc-2.0";
  source = pkgs.writeText "gtkrc" ''
  include "${variables.homeDir}/.gtkrc-2.0.mine"
  gtk-theme-name="Breeze"
  gtk-icon-theme-name="breeze"
  gtk-font-name="Sans 10"
  gtk-cursor-theme-size=0
  gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
  gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
  gtk-button-images=0
  gtk-menu-images=0
  gtk-enable-event-sounds=1
  gtk-enable-input-feedback-sounds=1
  gtk-xft-antialias=1
  gtk-xft-hinting=1
  gtk-xft-hintstyle="hintmedium"
  '';
}]
