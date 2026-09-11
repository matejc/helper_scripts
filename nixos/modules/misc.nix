{
  inputs,
  defaultUser,
  ...
}:
{
  config = {
    programs.nix-ld.enable = true;
    programs.dconf.enable = true;

    nix = {
      channel.enable = false;
      settings = {
        nix-path = "nixpkgs=${inputs.nixpkgs}";
        experimental-features = [
          "configurable-impure-env"
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          defaultUser
        ];
        accept-flake-config = true;
      };
    };

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 10 --keep-since 7d";
        dates = "weekly";
      };
    };

    networking.networkmanager.enable = true;
    networking.networkmanager.dns = "systemd-resolved";
    services.resolved.enable = true;
  };
}
