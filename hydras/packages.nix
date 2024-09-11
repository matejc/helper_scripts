{ nixpkgs
, supportedSystems ? [ "x86_64-linux" "i686-linux" ]
, system ? builtins.currentSystem
, attrs ? [ ]
}:

with import <nixpkgs/pkgs/top-level/release-lib.nix> { inherit supportedSystems; };

let
  pkgs = import nixpkgs { inherit system; };

  removeFirst = (str:
    pkgs.lib.drop 1 (pkgs.lib.splitString "." str)
  );
  zipModules = (list:
    pkgs.lib.zipAttrsWith (n: v:
      if builtins.tail v != [] then zipModules v else builtins.head v
    ) list
  );

  jobs =
    (mapTestOn (

      zipModules (
        map (n:
          pkgs.lib.listToAttrs [(
            pkgs.lib.nameValuePair
            (builtins.head (pkgs.lib.splitString "." n))
            (pkgs.lib.setAttrByPath (removeFirst n) supportedSystems)
          )]
        ) attrs
      )

    ));
in jobs
