{ pkgs ? import <nixpkgs> {} }:
with pkgs;
runCommand "groovy-language-server" {
  src = builtins.fetchurl https://github.com/Moonshine-IDE/Moonshine-IDE/raw/master/ide/MoonshineSharedCore/src/elements/groovy-language-server/groovy-language-server-all.jar;
  buildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/{bin,share/groovy-language-server}/
  ln -s $src $out/share/groovy-language-server/groovy-language-server-all.jar
  makeWrapper ${jre}/bin/java $out/bin/groovy-language-server \
    --argv0 crowdin \
    --add-flags "-jar $out/share/groovy-language-server/groovy-language-server-all.jar"
''
