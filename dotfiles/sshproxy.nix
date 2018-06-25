{ variables, config, pkgs, lib }:
let
  port = "63333";
in
{
  target = "${variables.homeDir}/bin/sshproxy";
  source = pkgs.writeScript "sshproxy.sh" ''
    #!${pkgs.stdenv.shell}

    ssh -D ${port} -Nf "$1"

    function killapp {
      fuser -k ${port}/tcp
      echo "ssh killed"
    }

    trap "killapp" EXIT

    export http_proxy=http://127.0.0.1:${port}
    export https_proxy=http://127.0.0.1:${port}
    export ftp_proxy=http://127.0.0.1:${port}
    export all_proxy=http://127.0.0.1:${port}
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"

    ''${@:2} &
    apppid="$!"
    wait $apppid
  '';
}
