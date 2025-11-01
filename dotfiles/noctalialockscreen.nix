{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/lockscreen";
  source = pkgs.writeScript "noctalialockscreen.sh" ''
    #!${pkgs.stdenv.shell}
    exec ${pkgs.noctalia-shell}/bin/noctalia-shell ipc call lockScreen lock
  '';
}]
