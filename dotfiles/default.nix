{ name, exposeScript ? false }:
{ config, pkgs, lib, ... }:
let
  settings = import (./. + "/settings-${name}.nix") { inherit pkgs; };

  variables = settings.variables;
  dotFilePaths = settings.dotFilePaths;
  activationScript = settings.activationScript;

  dotFileFun = nixFilePath:
    let
      nixes = lib.toList (import nixFilePath { inherit variables config pkgs lib; });
    in map (nix: {
      source = nix.source;
      target = nix.target;
    }) nixes;
  dotAttrs = lib.flatten (map dotFileFun dotFilePaths);
  dotFilesScript = pkgs.writeScript "dot-files-script-${name}.sh" ''
    #!${pkgs.stdenv.shell}

    ${lib.concatMapStringsSep "\n" (d: ''
      if [[ -L "${d.target}" ]]; then
        rm "${d.target}"
      elif [[ -f "${d.target}" ]]; then
        mv -v "${d.target}" "${d.target}.backup.`date --iso-8601=seconds`"
      fi
      mkdir -p "`dirname "${d.target}"`" && \
        ln -vs "${d.source}" "${d.target}"
    '') dotAttrs}

    ${activationScript}
  '';
in if exposeScript then dotFilesScript else {
  system.activationScripts."dotfiles-${name}" = ''
    ${dotFilesScript} || true
  '';
}
