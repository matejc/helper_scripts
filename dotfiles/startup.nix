{ variables, config, pkgs, lib }:
with lib;
map (exec:
    let
        name = "${lib.last (lib.splitString "/" exec)}";
        item = pkgs.makeDesktopItem {
            inherit exec name;
            desktopName = name;
        };
    in
    {
        target = "${variables.homeDir}/.config/autostart/${name}.desktop";
        source = "${item}/share/applications/${name}.desktop";
    }
) variables.startup
