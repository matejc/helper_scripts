{ pkgs ? import <nixpkgs> {} }:
with pkgs;
buildGoModule rec {
  pname = "prometheus-steam-web-api-exporter";
  version = "dev";

  src = fetchFromGitHub {
    owner = "matejc";
    repo = "prometheus-steam-web-api-exporter";
    rev = "ea8ae49e25eb349b3f144d299e87aa16155ea7a5";
    hash = "sha256-vq2rY2Pkmm1ei9hJF9Q4NoMYlJq5od+XtWy8fV+KbUk=";
  };

  vendorHash = "sha256-yGv3zPAO844DHpV7iGe4KGhLAbyfMqaC3gGJCVZm4U4=";
}
