{ variables, config, pkgs, lib }:
let
  kanban4taskwarrior = pkgs.stdenv.mkDerivation rec {
    name = "kanban4taskwarrior";
    src = pkgs.fetchFromGitHub {
      owner = "bmejias";
      repo = "kanban4taskwarrior";
      rev = "f6701fce0432446c630872f4345042cf27e0a132";
      sha256 = "1gnjzzgbw7shwm491lhghvjmm6kycy3gmwqijqm58pp2q3slp4dv";
    };
    buildInputs = [ pkgs.makeWrapper ];
    installPhase = ''
      mkdir -p $out/share/${name}
      mkdir $out/bin
      cp -r . $out/share/${name}/

      substituteInPlace $out/share/${name}/kanban \
        --replace "/usr/bin/task" "${pkgs.taskwarrior}/bin/task"

      makeWrapper ${pkgs.python2}/bin/python $out/bin/kanban \
        --add-flags $out/share/${name}/kanban
    '';
  };
in
[{
  target = "${variables.homeDir}/bin/kanban";
  source = "${kanban4taskwarrior}/bin/kanban";
}]
