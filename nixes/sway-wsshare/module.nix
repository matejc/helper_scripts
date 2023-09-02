{ pkgs, config, ... }:
let
  chooserCmd = pkgs.writeShellScript "chooser.sh" ''
    export PATH="${pkgs.sway}/bin:${pkgs.jq}/bin:${pkgs.wofi}/bin:${pkgs.coreutils}/bin:$PATH"
    export SWAYSOCK="$(ls /run/user/"$(id -u)"/sway-ipc.* | head -n 1)"
    swaymsg -t get_outputs | jq -r '.[]|.name' | wofi -d
  '';

  package = import ./default.nix { inherit pkgs; };
in {
  config = {
    xdg.portal.wlr = {
      enable = pkgs.lib.mkDefault true;
      settings.screencast = {
        chooser_type = pkgs.lib.mkDefault "dmenu";
        chooser_cmd = pkgs.lib.mkDefault "${chooserCmd}";
      };
    };

    environment.systemPackages = [ package ];
  };
}
