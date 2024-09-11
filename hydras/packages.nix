{ nixpkgs ? <nixpkgs>
, supportedSystems ? [ "x86_64-linux" ]
, system ? builtins.currentSystem
, attrs ? [ ]
}:
let
  pkgs = import nixpkgs { inherit system; };
  rellib = import "${nixpkgs}/pkgs/top-level/release-lib.nix" { inherit supportedSystems; };

  # nixpkgsFor = rellib.forAllSystems (system: import nixpkgs { inherit system; });
  # jobs = rellib.forAllSystems (system: (builtins.listToAttrs (map (attr:
  #   let
  #     path = pkgs.lib.splitString "." attr;
  #     p = pkgs.lib.getAttrFromPath path nixpkgsFor.${system};
  #   in
  #     {name = p.pname; value = builtins.listToAttrs (map (o: { name = o; value = p.${o}; }) p.outputs);}
  # ) attrs)));

  jobs = rellib.mapTestOn (builtins.listToAttrs (map (a: { name = a; value = supportedSystems; }) attrs));
in jobs
