{ pkgs, lib, config, ... }:
let
  dotFileFun =
    nixFilePath:
    let
      dotNixFiles = lib.toList (
        import nixFilePath {
          inherit config pkgs lib;
          inherit (config) variables;
        }
      );
      dotFiles = map (nix: {
        source = nix.source;
        target = lib.replaceStrings [ "${config.variables.homeDir}/" ] [ "" ] nix.target;
      }) dotNixFiles;
    in
    dotFiles;

  binFiles =
    let
      dotFiles = lib.flatten (map dotFileFun config.dotfiles.paths);
      binDotFiles = builtins.filter (d: (builtins.substring 0 4 d.target) == "bin/") dotFiles;
    in
    pkgs.runCommand "dot-bins" { } ''
      mkdir -p $out/bin
      ${lib.concatMapStringsSep "\n" (b: ''ln -vs "${b.source}" "$out/${b.target}"'') binDotFiles}
    '';

  dotFiles =
    let
      dots = (lib.flatten (map dotFileFun config.dotfiles.paths));
    in
    builtins.listToAttrs (
      map (n: {
        name = n.target;
        value.target = n.target;
        value.source = n.source;
        value.force = true;
      }) (builtins.filter (d: (builtins.substring 0 4 d.target) != "bin/") dots)
    );
in
{
  options.dotfiles = {
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Dotfile paths";
    };
  };
  config = {
    home.packages = [ binFiles ];
    home.file = dotFiles;
  };
}
