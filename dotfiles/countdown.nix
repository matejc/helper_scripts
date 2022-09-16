{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/countdown";
  source = pkgs.writeScript "countdown.sh" ''
    #!${pkgs.stdenv.shell}
    if [ -z "$1" ]
    then
      echo "Please provide time in seconds!" >&2
      exit 1
    fi
    ( seq -w $1 -1 1 | ${pkgs.findutils}/bin/xargs -I{} sh -c 'printf "\033[0K\r{} seconds remaining"; sleep 1'; ) && printf '\r\033[KTime is up!\n'
  '';
}




