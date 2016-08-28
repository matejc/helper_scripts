{ stdenv, sublime3, nodejs, makeWrapper, cacert }:
stdenv.mkDerivation {
    name = "sublime3Wrapper";
    buildInputs = [ makeWrapper ];
    buildCommand = ''
        mkdir -p $out/bin
        mkdir -p $out/curlhome
        echo "cacert ${cacert}/etc/ca-bundle.crt" > $out/curlhome/.curlrc
        makeWrapper ${sublime3}/bin/sublime $out/bin/sublime \
            --prefix "PATH" ":" "${nodejs}/bin:/home/matejc/.npm-packages/bin" \
            --prefix "CURL_HOME" ":" "$out/curlhome"
    '';
}
