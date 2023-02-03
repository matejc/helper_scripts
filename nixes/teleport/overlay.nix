self: super:

{
  teleport = import ./package.nix { pkgs = super; };
}
