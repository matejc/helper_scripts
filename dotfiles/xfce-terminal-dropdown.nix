{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/dropdown-terminal";
  source = pkgs.writeScript "dropdown-terminal.sh" ''
    #!${pkgs.stdenv.shell}
    ${if variables.sway.enable then ''
      ${variables.homeDir}/bin/xfce-terminal-dropdown
    '' else ''
      ${pkgs.xfce.xfce4-terminal}/bin/xfce4-terminal --drop-down
    ''}
  '';
}
