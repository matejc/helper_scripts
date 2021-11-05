{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.local/share/fonts/NerdFonts";
  source = "${pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; }}/share/fonts/truetype/NerdFonts";
}]
