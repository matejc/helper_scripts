{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/i3lock-wrapper";
  source = pkgs.writeScript "i3lock-wrapper" ''
    #!${pkgs.stdenv.shell}

    # I3LOCKIMAGE=/home/matejc/tmp/.screen_locked.png
    # /run/current-system/sw/bin/scrot $I3LOCKIMAGE
    # /run/current-system/sw/bin/convert $I3LOCKIMAGE -scale 10% -scale 1000% $I3LOCKIMAGE
    # /run/current-system/sw/bin/i3lock -i $I3LOCKIMAGE --nofork

    # i3lock-fancy --greyscale --pixelate
    i3lock-color -i ${variables.lockImage} --nofork --insidecolor=00000000 --ringcolor=007BA755 --keyhlcolor=007BA7CC --line-uses-ring --separatorcolor=007BA7CC --bshlcolor=FF0000CC
  '';
}
