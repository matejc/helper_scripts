{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/yaml2nix";
  source = pkgs.writeScript "yaml2nix" ''
    #!${pkgs.stdenv.shell}

    fixAttrNames() {
      cat $1 | ${pkgs.perl.out}/bin/perl -ne 's/(?!\ )([A-Za-z0-9\-\/\.]+)(?=\ =\ )/"$1"/g; print;'
    }
    yaml2nix() {
      dir="$1"
      tmpfile1=$(mktemp /tmp/yaml2nix.XXXXXX)
      echo "[" > $tmpfile1
      for file in $(find $dir -iname '*.yaml')
      do
        filename=$(basename $file)
        name=''${filename%.*}
        echo "{ name = \"$name\"; value = builtins.fromJSON '''$(${pkgs.remarshal}/bin/remarshal -if yaml -of json -i $file)'''; }" | ${pkgs.nix}/bin/nix-instantiate --eval --strict -E - >> $tmpfile1
      done
      echo "]" >> $tmpfile1
      tmpfile2=$(mktemp /tmp/yaml2nix.XXXXXX)
      fixAttrNames "$tmpfile1" > "$tmpfile2"
      rm $tmpfile1

      tmpfile3=$(mktemp /tmp/yaml2nix.XXXXXX)
      echo "{ cfg }:" > $tmpfile3
      ${pkgs.nix}/bin/nix-instantiate --eval --strict -E "let i = import $tmpfile2; in builtins.listToAttrs i" >> $tmpfile3
      rm $tmpfile2
      fixAttrNames "$tmpfile3"
      rm $tmpfile3
    }

    set -e

    yaml2nix "$1"
  '';
}
