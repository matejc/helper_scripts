{ name, ... }:
let
  defaultNix = import ./default.nix;
in
  defaultNix.hydraJobs.${name}
