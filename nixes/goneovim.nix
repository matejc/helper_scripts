{ pkgs ? import <nixpkgs> {} }:
with pkgs;
buildGoModule rec {
  pname = "goneovim";
  version = "0.6.16";

  src = fetchFromGitHub {
    owner = "akiyosi";
    repo = "goneovim";
    rev = "v${version}";
    hash = "sha256-2zA/KONffyc00dQLAvd/B7mZHvWhH2pLuYgdM0n87aQ=";
  };

  vendorHash = "sha256-6VUAZ9RWpS/+r9h+wi7D9186CZnnB8LNp/w1YwOL7/U=";
  proxyVendor = true;

  preConfigure = ''
    echo "${version}" > ./editor/version.txt
  '';
}
