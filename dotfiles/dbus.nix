{ variables, config, pkgs, lib }:
with lib;
flatten (map (pkg:
    let
        servicesDirectory = if isString pkg then pkg else "${pkg}/share/dbus-1/services";
        mkName = service: "${last (splitString "/" "${service}")}";
        services = filesystem.listFilesRecursive servicesDirectory;
    in
    (map (service: {
        target = "${variables.homeDir}/.local/share/dbus-1/services/${mkName service}";
        source = "${service}";
    }) services)
) variables.dbus)
