{ pkgs ? import <nixpkgs> {}, destination ? "/var/lib/seafile" }:
let
  # First time and on update:
  # nix-build /home/matej/workarea/helper_scripts/nixes/seafile-server.nix
  # ./result/bin/setup_env

  # First time:
  # ./result/bin/run_env seafile-admin setup

  # To run:
  # ./result/bin/run_env seafile-admin start --fastcgi

  seahubSrc = pkgs.fetchurl {
    url = https://github.com/haiwen/seahub/archive/v3.1.5-server-testing.tar.gz;
    sha256 = "1x9y45crgj3w2pcrncx21dnp7cl3wcpscf1crhx9293bv8ws4vw2";
  };

  seafileServer = pkgs.seafile-server.override {
    seafile_topdir = "${destination}/haiwen";
  };

  deps = pkgs.buildEnv {
    name = "deps";
    paths = with pkgs.pythonPackages; [ pkgs.python.modules.sqlite3 pillow
      django_1_5 djblets seafileServer pkgs.ccnet pkgs.libsearpc gunicorn
      six flup chardet dateutil ];
  };

  setupEnv = pkgs.writeScriptBin "setup_env" ''
    mkdir -p ${destination}/haiwen/seafile-server
    cd ${destination}/haiwen/seafile-server
    test -d ./seahub || { \
      mkdir ./seahub && \
      tar xf ${seahubSrc} -C ./seahub --strip-components=1; \
    }
  '';

  runEnv = pkgs.writeScriptBin "run_env" ''
    cd ${destination}/haiwen
    export PATH="${pkgs.procps}/bin:${deps}/bin:${pkgs.python}/bin"
    export PYTHONPATH="${deps}/${pkgs.python.sitePackages}:${destination}/haiwen/seafile-server/seahub:${destination}/haiwen/seafile-server/seahub/thirdpart"

    "$@"
  '';

  env = pkgs.buildEnv {
    name = "seafile-server-env";
    paths = [ setupEnv runEnv pkgs.ccnet seafileServer ];
  };

in env
