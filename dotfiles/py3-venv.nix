{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/py3-venv";
  source = pkgs.writeScript "py3-venv.sh" ''
    #!${pkgs.stdenv.shell}

    set -e

    die() {
      echo $@ >&2
      exit 1
    }

    ${pkgs.which}/bin/which python | &>/dev/null
    if [ "$?" != "0" ]
    then
      die "Python is not in PATH"
    fi

    action="$1"

    pyversion="$(python --version | ${pkgs.gawk}/bin/awk '{printf $2}')"
    hash="$(echo -n "''${pyversion}_$PWD" | ${pkgs.coreutils}/bin/sha1sum | ${pkgs.gawk}/bin/awk '{printf $1}')"
    directory="${variables.homeDir}/.py3-venv/$hash"

    case $action in
      install)
        mkdir -p "$directory"
        python -m venv "$directory"
        $directory/bin/pip install ''${@:2}
        ;;
      shell)
        if [ ! -d "$directory" ]; then die "venv for Python $pyversion and directory $PWD does not exist"; fi
        pythonpath="$(set -- $directory/lib/python*/site-packages; echo "$1")"
        export PYTHONPATH="$pythonpath"
        export PATH="$directory/bin:$PATH"
        export VIRTUAL_ENV="$directory"
        ''${2:-$SHELL}
        ;;
      run)
        if [ ! -d "$directory" ]; then die "venv for Python $pyversion and directory $PWD does not exist"; fi
        pythonpath="$(set -- $directory/lib/python*/site-packages; echo "$1")"
        export PYTHONPATH="$pythonpath"
        export PATH="$directory/bin:$PATH"
        "''${@:2}"
        ;;
      rm)
        if [ ! -d "$directory" ]; then die "venv for Python $pyversion and directory $PWD does not exist"; fi
        rm -rf "$directory"
        ;;
      *)
        echo "Usage: $0 {install|shell|run|rm}" >&2
        exit 1
        ;;
    esac
  '';
}]
