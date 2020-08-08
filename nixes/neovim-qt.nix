{ pkgs ? import <nixpkgs> {} }:
pkgs.writeScript "run-neovim-qt.sh" ''
    #!${pkgs.stdenv.shell}
    set -e
    export NVIM_LISTEN="127.0.0.1:$(${pkgs.python3Packages.python}/bin/python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')"
    { ${pkgs.python3Packages.python}/bin/python -c 'import time; time.sleep(1)'; ''${NVIM_QT_PATH} --server "$NVIM_LISTEN"; } &
    ${pkgs.neovim}/bin/nvim --listen "$NVIM_LISTEN" --headless "$@"
''
