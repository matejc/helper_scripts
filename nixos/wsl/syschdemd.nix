{ lib, pkgs, config, defaultUser, ... }:

let
  inherit (pkgs) daemonize;
in
pkgs.substituteAll {
  name = "syschdemd";
  src = ./syschdemd.sh;
  dir = "bin";
  isExecutable = true;

  buildInputs = [ daemonize ];

  inherit daemonize;
  inherit defaultUser;
  inherit (config.security) wrapperDir;
  fsPackagesPath = lib.makeBinPath config.system.fsPackages;
}
