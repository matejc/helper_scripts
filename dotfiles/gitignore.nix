{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.gitignore";
  source = pkgs.writeText "gitignore" ''
  # Compiled source #
  ###################
  *.com
  *.class
  *.dll
  *.exe
  *.o
  *.so
  *.lo
  *.la
  *.rej
  *.pyc
  *.pyo

  # Packages #
  ############
  # it's better to unpack these files and commit the raw source
  # git has its own built in compression methods
  *.7z
  *.dmg
  *.gz
  *.iso
  *.jar
  *.rar
  *.tar
  *.zip

  # Logs and databases #
  ######################
  *.log
  *.sql
  *.sqlite

  # OS generated files #
  ######################
  .DS_Store
  .DS_Store?
  ehthumbs.db
  Icon?
  Thumbs.db

  # Python projects related #
  ###########################
  *.egg-info
  docs/Makefile
  .egg-info.installed.cfg
  *.pt.py
  *.cpt.py
  *.zpt.py
  *.html.py
  *.egg

  lib64
  my.py
  *.swp
  .idea

  .envrc
  .tern-port

  /.gtm/
  '';
}
