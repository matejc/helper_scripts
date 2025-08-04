{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/Caprine/custom.css";
  source = pkgs.writeText "custom.css" ''
    html.hide-preferences-window div[class="x9f619 x1n2onr6 x1ja2u2z"] > div:nth-of-type(3) > div > div {
        display: block !important;
    }
  '';
}]
