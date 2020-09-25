{ variables, config, pkgs, lib }:
with lib;
map (exec: {
    target = "${variables.homeDir}/.config/autostart-scripts/${lib.last (lib.splitString "/" exec)}";
    source = exec;
}) variables.startup
