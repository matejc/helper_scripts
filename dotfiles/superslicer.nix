{ variables, config, pkgs, lib }:
let
  profile = pkgs.fetchFromGitHub {
    owner = "sn4k3";
    repo = "Ender3";
    rev = "e679ff4c80a74285d42f33d3315f9b855542ff96";
    sha256 = "1966sw82mkpxsks5xyzsq99f3v6jy4cdmrgxnvmwi0clxlzfkfz9";
  };
  insert = name: directory:
    {
      target = "${variables.homeDir}/.config/SuperSlicer/${directory}/${name}";
      source = "${profile}/PrusaSlicer/${directory}/${name}";
    };
in
  [
    (insert "FILAFLEX 95A.ini" "filament")
    (insert "FILAFLEX 82A Original.ini" "filament")
  ]
