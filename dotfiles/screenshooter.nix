{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/screenshooter";
  source = pkgs.writeScript "screenshooter.sh" ''
    #!${pkgs.stdenv.shell}
    ${if variables.sway.enable then ''
      ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "${variables.homeDir}/Pictures/Screenshoot-$(date -u -Iseconds).png"
    '' else ''
      ${pkgs.xfce.xfce4-screenshooter}/bin/xfce4-screenshooter --region --save ${variables.homeDir}/Pictures
    ''}
  '';
}
