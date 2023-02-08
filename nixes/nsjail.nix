{ pkgs ? import <nixpkgs> {}
, newuidmap ? "/run/wrappers/bin/newuidmap"
, newgidmap ? "/run/wrappers/bin/newgidmap"
}:
pkgs.nsjail.overrideDerivation (old: {
  preBuild = ''
    makeFlagsArray+=(USER_DEFINES='-DNEWUIDMAP_PATH=${newuidmap} -DNEWGIDMAP_PATH=${newgidmap}')
  '';
})
