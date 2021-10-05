{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/mysync";
  source = pkgs.writeScript "sync.sh" ''
    #!${pkgs.stdenv.shell}
    set -e
    export PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin
    sync &
    syncpid=$!
    while kill -0 $syncpid 2>/dev/null
    do
      grep -e Dirty: -e Writeback: /proc/meminfo
      sleep 2
    done
  '';
}
