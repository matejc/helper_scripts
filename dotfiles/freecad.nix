{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.FreeCAD/Macro/FCBmpImport.FCMacro.py";
  source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mwganson/fcbmpimport/301da926f0e2fcdd55bfd85d6b187f06b5197b41/FCBmpImport.FCMacro.py";
    sha256 = "0qjkda3k0jigc1y2hbnkyxzsvx0f7lcsifx9ihk0llz51arf8a4w";
    name = "FCBmpImport.FCMacro.py";
  };
}
