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
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    programs.gpu-screen-recorder.enable = true;
  };
}
