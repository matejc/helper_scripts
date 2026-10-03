{
  inputs,
  defaultUser,
  ...
}:
{
  imports = [
    inputs.fast-nix-gc.nixosModules.default
  ];

  config = {
    programs.nix-ld.enable = true;
    programs.dconf.enable = true;

    nix = {
      channel.enable = false;
      settings = {
        nix-path = [ "nixpkgs=${inputs.nixpkgs}" ];
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

    services.fast-nix-gc = {
      enable = true;
      automatic = true;
      dates = "weekly";
      deleteOlderThan = "30d";
      ensureFree = "50G";
      keepRecent = "1d";
    };
    services.fast-nix-optimise = {
      enable = true;
      automatic = true;
      dates = "weekly";
    };

    networking.networkmanager.enable = true;
    networking.networkmanager.dns = "systemd-resolved";
    services.resolved.enable = true;
  };
}
