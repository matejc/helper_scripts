let
    pkgs = import <nixpkgs> { };

    inherit (pkgs) stdenv sublime3 nodejs makeWrapper cacert;
in

stdenv.mkDerivation {
    name = "sublime3Wrapper";
    buildInputs = [ makeWrapper ];
    buildCommand = ''
        mkdir -p $out/bin
        mkdir -p $out/curlhome
        echo "cacert ${cacert}/etc/ca-bundle.crt" > $out/curlhome/.curlrc
        ln -sv ${sublime3}/bin/sublime $out/bin/run_sublime
        wrapProgram $out/bin/run_sublime \
            --prefix "PATH" ":" "${nodejs}/bin" \
            --prefix "CURL_HOME" ":" "$out/curlhome"
    '';
}
