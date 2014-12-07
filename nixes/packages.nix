# run it as: nix-instantiate packages.nix --eval --strict --show-trace

let
  # set allowBroken and allowUnfree to true, so that we minimize error output later on
  pkgs = import <nixpkgs> { config = { allowBroken = true; allowUnfree = true; }; };

  # catch exceptions on isDerivation function
  tryDrv = a: builtins.tryEval (pkgs.lib.isDerivation a);
  isDerivation = a: let t = tryDrv a; in t.success && t.value == true;

  # catch exceptions on isAttrs function
  tryAttrs = a: builtins.tryEval (pkgs.lib.isAttrs a);
  isAttrs = a: let t = tryAttrs a; in t.success && t.value == true;

  # iterate through attributeset's names (one-level deep)
  # example:
  # mapValues (name: value: name) pkgs
  # => [ "bash" "zsh" "gitFull" ... ]
  mapValues = f: set: (map (attr: f attr (builtins.getAttr attr set)) (builtins.attrNames set));

  # recurse into attributeset (search for derivations)
  # example #1:
  # mapAttrsRecursiveDrv (path: value: path) pkgs.pythonPackages ["pkgs" "pythonPackages"] []
  # => [ [ "pkgs" "pythonPackages" "searx" ] [ "pkgs" "pythonPackages" "tarman" ] ... ]
  # example #2:
  # mapAttrsRecursiveDrv (path: value: path) pkgs ["pkgs"] []
  # => [ [ "pkgs" "bash" ] [ "pkgs" "zsh" ] [ "pkgs" "pythonPackages" "searx" ] [ "pkgs" "pythonPackages" "tarman" ] ... ]
  mapAttrsRecursiveDrv = f: set: path: list:
    let
      recurse = path: set: visitList:
        let
          visitedFun = a: path:
            let
              isAtt = isAttrs a;
              isDrv = isDerivation a;
              success = if isAtt && !isDrv then pkgs.lib.any (element: element == a) visitList else false;
              not = !success;
              list = if not then (visitList ++ [a]) else visitList;
            in
              { inherit list not isAtt isDrv; };

          g = name: value:
            let
              visited = visitedFun value path;
            in
            if visited.isDrv then
              f (path ++ [name]) value
            else if (visited.not) && (checkForEnterable value) then
              recurse (path ++ [name]) value visited.list
            else
              { error = "not derivation or not enterable"; attrPath = pkgs.lib.concatStringsSep "." (path ++ [name]); };
        in mapValues g set;
    in (recurse path set list);

  # check if attributeste has attribute named "recurseForDerivations" therefore has derivations
  # examples:
  # checkForEnterable pkgs.bash => false
  # checkForEnterable pkgs.pythonPackages => true
  checkForEnterable = a:
    let
      t = builtins.tryEval ((pkgs.lib.isAttrs a) && (pkgs.lib.hasAttr "recurseForDerivations" a));
    in
      (t.success && t.value == true);

  # main function
  # example:
  # recurseInto "pkgs.pythonPackages"
  # => [
  #   { attrPath = "pkgs.pythonPackages.tarman"; name = "python2.7-tarman-0.1.3"; out = "/nix/store/<hash>-python2.7-tarman-0.1.3"; }
  #   { attrPath = "pkgs.pythonPackages.searx"; name = "python2.7-searx-dev"; out = "/nix/store/<hash>-python2.7-searx-dev"; }
  #   { attrPath = "pkgs.pythonPackages.isPy27"; error = "not derivation or not enterable"; }
  # ]
  recurseInto = attrPath:
    let
      path = pkgs.lib.splitString "." attrPath;
      attrs = pkgs.lib.getAttrFromPath path pkgs;
    in
      pkgs.lib.flatten (mapAttrsRecursiveDrv
        (path: value:
          let
            attrPath = pkgs.lib.concatStringsSep "." path;
            tOutPath = builtins.tryEval value.outPath;
            tName = builtins.tryEval value.name;
          in
            (if tOutPath.success && tName.success then
              { out = tOutPath.value; name = tName.value; inherit attrPath; }
            else
              { error = "tryEval failed"; inherit attrPath; })
        )
        attrs
        path
        []);

  # just strips away values with attribute "error"
  removeErrors = builtins.filter (x: (if pkgs.lib.hasAttr "error" x then
      (builtins.trace "error '${x.error}' at attribute ${x.attrPath}" false)
    else true));

in
  removeErrors (recurseInto "pkgs")
