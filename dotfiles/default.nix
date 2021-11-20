{ name, exposeScript ? false, context ? null }:
{ config, pkgs, lib, ... }:
let
  context' = if context == null then
    import (./. + "/settings-${name}.nix") { inherit pkgs; }
  else
    context;

  variables = context'.variables;
  dotFilePaths = context'.dotFilePaths;
  activationScript = context'.activationScript;

  dotFileFun = nixFilePath:
    let
      nixes = lib.toList (import nixFilePath { inherit variables config pkgs lib; });
    in map (nix: {
      source = nix.source;
      target = nix.target;
    }) nixes;
  dotAttrs = lib.flatten (map dotFileFun dotFilePaths);
  dotFilesScript = pkgs.writeScriptBin "dot-files-apply-${name}" ''
    #!${pkgs.stdenv.shell}

    ${lib.concatMapStringsSep "\n" (d: ''
      if [[ -L "${d.target}" ]]; then
        rm -v "${d.target}"
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
    ${dotFilesScript}/bin/dot-files-apply-${name} || true
  '';
}
