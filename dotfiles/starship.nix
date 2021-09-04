{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/starship.toml";
  source = pkgs.writeText "starship" ''
    command_timeout = 1000

    [aws]
    disabled = true

    [character]
    success_symbol = "[❯](bold green) "
    error_symbol = "[✗](bold red) "
  '';
}]
