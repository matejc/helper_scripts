{ pkgs ? import <nixpkgs> {} }:
let
  mach-nix = import (builtins.fetchGit {
    url = "https://github.com/DavHau/mach-nix";
    ref = "refs/heads/master";
  }) { inherit pkgs; };
  src = builtins.fetchGit{
    url = "https://github.com/rachmadaniHaryono/we-get";
    ref = "refs/tags/1.1.5";
  };
  env = mach-nix.mkPython {
    requirements = ''
      beautifulsoup4~=4.10.0
      colorama~=0.4.4
      docopt~=0.6.2
      prompt-toolkit>=3.0.5
      pygments>=2.6.1
      requests>=2.27.1
    '';
  };
in
  pkgs.writeScriptBin "we-get" ''
    #!${pkgs.stdenv.shell}
    ENV_PY_PATH="$(realpath ${env}/lib/python*/site-packages)"
    export PYTHONPATH="${src}:$ENV_PY_PATH:$PYTHONPATH"
    ${env.python}/bin/python -m we_get $@
  ''
