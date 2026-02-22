{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];
  config = {
    nixpkgs.overlays = [
      inputs.niri.overlays.niri
    ];
    xdg.portal = {
      enable = true;
      config = {
        common.default = "*";
      };
    };
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
