{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.local/share/vlc/lua/playlist/youtube.lua";
  source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/videolan/vlc/f7bb59d9f51cc10b25ff86d34a3eff744e60c46e/share/lua/playlist/youtube.lua";
    sha256 = "sha256-cKMGaJ8O0oThU+cG7AyeW1i7Zj4Vd2FjAK0Esq63YKo=";
  };
}
