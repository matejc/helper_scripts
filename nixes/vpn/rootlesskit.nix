{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  rootlesskit = buildGoModule rec {
    pname = "rootlesskit";
    version = "0.14.5";
    src = fetchFromGitHub {
      owner = "rootless-containers";
      repo = "rootlesskit";
      rev = "v${version}";
      sha256 = "sha256-dj0SBer8sEIdzajynlTf351SprQfHewRHZjDQC1eQYU=";
    };
    runVend = true;
    vendorSha256 = "sha256-Yhgx7VsfFietl5G93GH4Kz/ZKx+pWmRRQF4tiXG9C2s=";
  };

  script = writeScript "script.sh" ''
    dig google.com

  '';

in
  mkShell {
    buildInputs = [ rootlesskit shadow slirp4netns dnsutils ];
    shellHook = ''
      rootlesskit --help --net=slirp4netns --copy-up=/etc \
        --disable-host-loopback ${script}
    '';
  }
