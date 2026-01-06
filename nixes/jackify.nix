{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = "Jackify";
  version = "0.2.0.10";

  src = pkgs.fetchurl {
    url = "https://github.com/Omni-guides/Jackify/releases/download/v${version}/Jackify.AppImage";
    sha256 = "sha256-9vfvZC0WcQNlAglPu3hk2hIASWE+EUJ6tlzYdmMdkd0=";
  };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;
  extraPkgs =
    pkgs: with pkgs; [
      python3
      zstd
      protontricks
    ];
}
