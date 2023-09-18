{ pkgs ? import <nixpkgs> {} }:
with pkgs;
buildGoModule rec {
  pname = "goneovim";
  version = "0.6.7";

  src = fetchFromGitHub {
    owner = "akiyosi";
    repo = "goneovim";
    rev = "v${version}";
    hash = "sha256-HZwZ0sCo6eHuuHUO8d+LZjwtYniiZvWPgFUXCID9DXA=";
  };

  vendorHash = "sha256-oDsVB4Cxi9mF3Ku0Nn8uSWG7W/WLHQroee2J9XUiLu8=";
  proxyVendor = true;


  preConfigure = ''
    mv version.txt ./editor/
  '';
}
