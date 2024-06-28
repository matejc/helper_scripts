{
  config,
  lib,
  dream2nix,
  ...
}: let
  python = config.deps.python;
  src = config.deps.fetchFromGitHub {
    owner = "danielmiessler";
    repo = config.name;
    rev = "refs/tags/${config.version}";
    hash = "sha256-OCR+E2riiWVVzyeYH4E5IiOooKY8G8k6vxfpERcu4pM=";
  };
in {
  imports = [
    dream2nix.modules.dream2nix.pip
  ];

  deps = {nixpkgs, ...}: {
    python = nixpkgs.python310;
    inherit
      (nixpkgs)
      fetchFromGitHub
      ;
  };

  name = "fabric";
  version = "1.4.0";

  buildPythonPackage = {
    format = "pyproject";
    # pythonImportsCheck = [
    #   config.name
    # ];
  };

  mkDerivation = {
    inherit src;
  };

  pip = {
    requirementsList = [
      "${src}"
    ];
    overrides = {
      pytils = {
        env.pyproject = null;
        mkDerivation.propagatedBuildInputs = [
          python.pkgs.poetry-core
        ];
      };
    };
  };
}
