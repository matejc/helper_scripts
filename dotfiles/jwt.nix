{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/bin/jwt-decode";
  source = pkgs.writeScript "jwt-decode.sh" ''
    #!${pkgs.stdenv.shell}

    decode_base64_url() {
      local len=$((''${#1} % 4))
      local result="$1"
      if [ $len -eq 2 ]
      then
        result="$1"'=='
      elif [ $len -eq 3 ]
      then
        result="$1"'='
      fi
      echo "$result" | tr '_-' '/+' | ${pkgs.openssl}/bin/openssl enc -d -base64
    }

    decode_jwt() {
      decode_base64_url $(echo -n $2 | cut -d "." -f $1) | ${pkgs.jq}/bin/jq .
    }

    # Decode JWT header
    header() {
      decode_jwt 1 $1
    }

    # Decode JWT Payload
    payload() {
      decode_jwt 2 $1
    }

    if [[ "$1" =~ header|payload ]]
    then
      $1 $2
    else
      echo "Usage: $0 {header|payload} {token}" >&2
      exit 1
    fi
  '';
}
