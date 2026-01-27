{ name, ... }@inputs:
let
  defaultNix = import ./default.nix;
in
{
  ${name} = defaultNix.hydraJobs.${name} inputs;
}
