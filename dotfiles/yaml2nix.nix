{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/bin/yaml2nix";
  source = pkgs.writeScript "yaml2nix" ''
    #!${pkgs.stdenv.shell}

    fixAttrNames() {
      cat $1 | ${pkgs.perl.out}/bin/perl -ne 's/(?!\ )([A-Za-z0-9\-\/]+[\.\/]+[A-Za-z0-9\-\/]+)(?=\ =\ )/"$1"/g; print;'
    }
    yamlDir2nix() {
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

    yamlFile2nix() {
      file="$1"
      echo "builtins.fromJSON '''$(${pkgs.remarshal}/bin/remarshal -if yaml -of json -i $file)'''" | ${pkgs.nix}/bin/nix-instantiate --eval --strict -E - | ${pkgs.perl.out}/bin/perl -ne 's/(?!\ )([A-Za-z0-9\-\/]+[\.\/]+[A-Za-z0-9\-\/]+)(?=\ =\ )/"$1"/g; print;'
    }

    set -e

    if [ -d "$1" ]
    then
      yamlDir2nix "$1"
    else
      yamlFile2nix "$1"
    fi

  '';
} {
  target = "${variables.homeDir}/bin/nix-beautify";
  source = pkgs.stdenv.mkDerivation {
    name = "nix-beautify";
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/nixcloud/nix-beautify/14f2751c22b092fd60b2442eaf207931b989a542/nix-beautify.js";
      sha256 = "019qi5fhd7h8argdz5f45w5za7ka091cca5a2l1hi1bhv8zmxh81";
    };
    unpackPhase = "true";
    installPhase = ''
      echo "#!${pkgs.nodejs}/bin/node" > $out
      cat $src >> $out
      chmod +x $out
    '';
  };
}]
