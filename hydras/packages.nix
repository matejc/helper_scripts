{ nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-linux" ]
, attrs ? [ "curl" ]
}:
let
  inherit (import "${nixpkgs}/pkgs/top-level/release-lib.nix" { inherit supportedSystems; }) mapTestOn packagePlatforms pkgs;
  jobs = mapTestOn (builtins.listToAttrs (map (a: { name = a; value = supportedSystems; }) attrs));
  # jobs = mapTestOn { curl = packagePlatforms pkgs.curl; };
in jobs
