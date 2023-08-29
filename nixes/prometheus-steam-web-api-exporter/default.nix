{ pkgs ? import <nixpkgs> {} }:
with pkgs;
buildGoModule rec {
  pname = "prometheus-steam-web-api-exporter";
  version = "dev";

  src = fetchFromGitHub {
    owner = "matejc";
    repo = "prometheus-steam-web-api-exporter";
    rev = "3b716a97407da83bf96f164c3ead0e49874bbc8c";
    hash = "sha256-cgsMHta7ZQ31fwxueckUiFBT6lci/pvlr3g4bWkWf/U=";
  };

  vendorHash = "sha256-wYq4cuKc7w8UoWG9OCuX2SotIcYJ/JHNQXnzl3cTyxM=";
}
