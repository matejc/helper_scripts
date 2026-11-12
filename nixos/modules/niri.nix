{
  config,
  defaultUser,
  ...
}:
{
  config = {
    programs.gpu-screen-recorder.enable = true;
    environment.systemPackages = [ config.home-manager.users.${defaultUser}.programs.niri.package ];
    environment.extraInit = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:${config.home-manager.users.${defaultUser}.programs.niri.package}/share"
    '';
  };
}
