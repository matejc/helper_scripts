{ config, pkgs, lib, ... }:
let
  pullRegistryImage = pkgs.dockerTools.pullImage {
    imageName = "registry";
    imageTag = "2.4.0";
    imageId = null;
    sha256 = "1lzji0van7g5xfnliqrrkaim66qbivj6i16agrggcjqv9h76iri3";
    indexUrl = "https://index.docker.io";
    registryVersion = "v1";
  };
in
{
  services.dockerctl = {
    enable = false;
    containers = {
      registry = {
        enable = true;
        image = pullRegistryImage;
        extraRunOptions = [
          "-p 5000:5000"
          "-v /tmp/reg.htpasswd:/auth/htpasswd"
          "-e REGISTRY_AUTH=htpasswd"
          "-e REGISTRY_AUTH_HTPASSWD_REALM=\"Registry Realm\""
          "-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd"
        ];
      };
    };
  };
  environment.systemPackages = [
    pkgs.push
  ];
}
