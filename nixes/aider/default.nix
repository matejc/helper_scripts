{ pkgs ? import <nixpkgs> {} }:
let
  version = "0.54.12";
  src = pkgs.fetchFromGitHub {
    owner = "paul-gauthier";
    repo = "aider";
    rev = "refs/tags/v${version}";
    hash = "sha256-zlwZD7Q8z9lYhX3vzIw23j1AipjIyIjl3cbWl0kebNU=";
  };

  dependencies = builtins.filter (v: v != null) (map (v: builtins.match "([[:alnum:]_-]+)==([[:alnum:]\._-]+)" v) (pkgs.lib.splitString "\n" ((builtins.readFile (src + "/requirements.txt")) + "\n" + (builtins.readFile (src + "/requirements/requirements-playwright.txt")))));
  aider_deps = builtins.listToAttrs ([
    { name = "pypager"; value = pypager; }
    { name = "grep-ast"; value = grep-ast; }
    { name = "tree-sitter-languages"; value = tree-sitter-languages; }
    { name = "tree-sitter"; value = pkgs.python312Packages.tree-sitter_0_21; }
    { name = "playwright"; value = pkgs.playwright; }
  ] ++ (map (d: { name = builtins.elemAt d 0; value = pkgs.python312Packages.${builtins.elemAt d 0}; }) (builtins.filter (d: (builtins.any (e: (builtins.elemAt d 0 != e)) ["pypager" "grep-ast" "tree-sitter-languages"])) dependencies)));

  requirements = pkgs.writeText "requirements.txt" ''
    ${pkgs.lib.concatMapStringsSep "\n" (d: d) (builtins.attrNames aider_deps)}
  '';

  pypager = pkgs.python312Packages.buildPythonPackage {
    pname = "pypager";
    version = "3.0.1";
    propagatedBuildInputs = [ pkgs.python312Packages.prompt_toolkit pkgs.python312Packages.pygments ];
    src = pkgs.fetchFromGitHub {
      owner = "prompt-toolkit";
      repo = "pypager";
      rev = "8ce7ffa52943ebd08a56d74d45bc6714c53dc2eb";
      hash = "sha256-deuZ/bDu8F9aeMXjA9Vu4L6e/DU9F0SzatxwVgNdLqA=";
    };
  };

  grep-ast = pkgs.python312Packages.grep-ast.override { inherit tree-sitter-languages; };

  tree-sitter-languages = pkgs.python312Packages.buildPythonPackage {
    pname = "tree-sitter-languages";
    version = "1.10.2";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "grantjenks";
      repo = "py-tree-sitter-languages";
      rev = "v${version}";
      hash = "sha256-wKU2c8QRBKFVFqg+DAeH5+cwm5jpDLmPZG3YBUsh/lM=";
      # Use git, to also fetch tree-sitter repositories that upstream puts their
      # hases in the repository as well, in repos.txt.
      forceFetchGit = true;
      postFetch = ''
        cd $out
        substitute build.py get-repos.py \
          --replace-fail "from tree_sitter import Language" "" \
          --replace-fail 'print(f"{sys.argv[0]}: Building", languages_filename)' "exit(0)"
        ${pkgs.python312Packages.python.pythonOnBuildForHost.interpreter} get-repos.py
        rm -rf vendor/*/.git
      '';
    };

    build-system = with pkgs.python312Packages; [
      setuptools
      cython
    ];
    dependencies =  with pkgs.python312Packages; [ tree-sitter_0_21 ];
    # Generate languages.so file (build won't fail without this, but tests will).
    preBuild = ''
      ${pkgs.python312Packages.python.pythonOnBuildForHost.interpreter} build.py
    '';
    nativeCheckInputs = with pkgs.python312Packages; [ pytestCheckHook ];
    # Without cd $out, tests fail to import the compiled cython extensions.
    # Without copying the ./tests/ directory to $out, pytest won't detect the
    # tests and run them. See also:
    # https://github.com/NixOS/nixpkgs/issues/255262
    preCheck = ''
      cp -r tests $out/${pkgs.python312Packages.python.sitePackages}/tree_sitter_languages
      cd $out
    '';

    pythonImportsCheck = [ "tree_sitter_languages" ];
  };

  package = pkgs.python312Packages.buildPythonApplication {
    pname = "aider-chat";
    inherit version src;
    pyproject = true;
    postUnpack = ''
      ln -svf ${requirements} $sourceRoot/requirements.txt
    '';
    buildInputs = [ pkgs.python312Packages.setuptools ];
    propagatedBuildInputs = builtins.attrValues aider_deps;
    postInstall = ''
      wrapProgram $out/bin/aider --set PLAYWRIGHT_BROWSERS_PATH "${pkgs.playwright-driver.browsers}"
    '';
  };
in
  package
