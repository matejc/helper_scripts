{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/bcrypt";
  source = pkgs.writeScript "bcrypt.sh" ''
    #! /usr/bin/env nix-shell
    #! nix-shell -i python3 -p python3 python3Packages.bcrypt python3Packages.six
    import sys
    import six
    import bcrypt
    print(bcrypt.hashpw(sys.argv[1].encode('utf-8'), bcrypt.gensalt(rounds=15)).decode('utf-8'))
  '';
}
