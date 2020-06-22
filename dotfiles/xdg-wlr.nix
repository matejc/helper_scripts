{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/xdg-wlr";
  source = pkgs.writeScript "xdg-wlr.sh" ''
    #!${pkgs.stdenv.shell}
    source "${variables.homeDir}/bin/xdg-wlr.env"
    ${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal -r & ${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr -p BGRx
  '';
} {
  target = "${variables.homeDir}/bin/xdg-wlr.env";
  source = pkgs.writeScript "xdg-wlr.env" ''
    #!${pkgs.stdenv.shell}
    export XDG_CURRENT_DESKTOP=sway
    export RTC_USE_PIPEWIRE=true
    export XDG_SESSION_TYPE=wayland
    export MOZ_ENABLE_WAYLAND=1


    "$@"
  '';
}]
