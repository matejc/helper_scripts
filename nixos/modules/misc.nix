{
  pkgs,
  inputs,
  defaultUser,
  ...
}:
{
  config = {
    programs.nix-ld.enable = true;
    programs.dconf.enable = true;
    services.dbus.packages = [ pkgs.gcr ]; # gpg-entry.pinentryFlavor = "gnome3"

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
      };
      gc = {
        automatic = true;
        dates = "weekly";
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
  };
}
