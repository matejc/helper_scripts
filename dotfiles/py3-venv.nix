{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/py3-venv";
  source = pkgs.writeScript "py3-venv.sh" ''
    #!${pkgs.stdenv.shell}

    action="$1"
    directory="${variables.homeDir}/.py3-venv/$(echo -n "$(${pkgs.which}/bin/which python)_$PWD" | ${pkgs.coreutils}/bin/sha1sum | ${pkgs.gawk}/bin/awk '{printf $1}')"

    case $action in
      install)
        mkdir -p "$directory"
        python -m venv "$directory"
        $directory/bin/pip install ''${@:2}
        ;;
      shell)
        pythonpath="$(set -- $directory/lib/python*/site-packages; echo "$1")"
        export PYTHONPATH="$pythonpath"
        export PATH="$directory/bin:$PATH"
        $SHELL
        ;;
      run)
        pythonpath="$(set -- $directory/lib/python*/site-packages; echo "$1")"
        export PYTHONPATH="$pythonpath"
        export PATH="$directory/bin:$PATH"
        "''${@:2}"
        ;;
      *)
        echo "Usage: $0 {install|shell|run}" >&2
        exit 1
        ;;
    esac
  '';
}]
