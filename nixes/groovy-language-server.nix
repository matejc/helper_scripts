{ pkgs ? import <nixpkgs> {} }:
with pkgs;
runCommand "groovy-language-server" {
  src = builtins.fetchurl {
    url = https://github.com/Moonshine-IDE/Moonshine-IDE/raw/216aa139620d50995a14827e949825c522bd85e5/ide/MoonshineSharedCore/src/elements/groovy-language-server/groovy-language-server-all.jar;
    sha256 = "sha256:1iq8c904xsyv7gf4i703g7kb114kyq6cg9gf1hr1fzvy7fpjw0im";
  };
  buildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/{bin,share/groovy-language-server}/
  ln -s $src $out/share/groovy-language-server/groovy-language-server-all.jar
  makeWrapper ${jre}/bin/java $out/bin/groovy-language-server \
    --argv0 crowdin \
    --add-flags "-jar $out/share/groovy-language-server/groovy-language-server-all.jar"
''
