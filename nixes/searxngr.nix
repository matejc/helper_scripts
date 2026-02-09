{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  bs4 = python3Packages.buildPythonPackage rec {
    pname = "bs4";
    version = "0.0.2";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-pIaFxY9Q/hJ3IkF7roP+a631ANVLVffjn/5Dt5hlOSU=";
    };

    build-system = with python3Packages; [ hatchling ];

    dependencies = with python3Packages; [
      beautifulsoup4
    ];
  };
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "searxngr";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "scross01";
    repo = finalAttrs.pname;
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-a3YdVvsXfYhM6KrnwXXKMq8Mrun3JJubrKBr8AB714o=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    babel
    bs4
    html2text
    httpx
    prompt-toolkit
    pyperclip
    python-dateutil
    rich
    xdg-base-dirs
  ];
})
