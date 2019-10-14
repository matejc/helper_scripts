{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/rofi/themes/material.rasi";
  source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/davatorium/rofi-themes/4033ccd2999a2a6bd9f599331e274e95a6756018/User%20Themes/material.rasi";
    sha256 = "0dr148lg020wnz6s6xfk9lz2yn46w3w9zc5fjg54imf4rljb875j";
  };
}{
  target = "${variables.homeDir}/.config/rofi/themes/sidetab-adapta.rasi";
  source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/davatorium/rofi-themes/2088c73e4006f4b17d6ce75758c6f021e612d1c2/User%20Themes/sidetab-adapta.rasi";
    sha256 = "0d2lpqc8nm4k33xvd35s4gdi5a3azv1hdi0v6w3wzkh76gz7gxg3";
  };
}]
