{ variables, config, pkgs, lib }:
let
  src = pkgs.fetchurl {
    url = http://aggregate.org/MAKE/TRACE2SCAD/trace2scad;
    sha256 = "1a4qr6h72ah8nczdj9djwnf45212551bwasimkarxdl58kgp33x8";
  };
in
{
  target = "${variables.homeDir}/bin/trace2scad";
  source = pkgs.writeScript "trace2scad.sh" ''
    #!${pkgs.stdenv.shell}
    export PATH="${lib.makeBinPath (with pkgs; [ gnugrep gnused gawk coreutils imagemagick potrace bash ])}"
    bash ${src} $@
  '';
}
