{ nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-linux" ]
, attrs ? [ "curl" ]
}:
with import "${nixpkgs}/pkgs/top-level/release-lib.nix" { inherit supportedSystems; };
let
  jobs = mapTestOn (listToAttrs (map (a: { name = a; value = supportedSystems; }) attrs));
in jobs
