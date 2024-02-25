{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.local/share/vlc/lua/playlist/youtube.lua";
  source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/videolan/vlc/f7bb59d9f51cc10b25ff86d34a3eff744e60c46e/share/lua/playlist/youtube.lua";
    sha256 = "sha256-cKMGaJ8O0oThU+cG7AyeW1i7Zj4Vd2FjAK0Esq63YKo=";
  };
} {
  target = "${variables.binDir}/yt-playlist";
  source = pkgs.writeShellScript "yt-playlist.sh" ''
    playlist_json="$(${pkgs.yt-dlp}/bin/yt-dlp --flat-playlist -J "$1")"
    name="$(echo "$playlist_json" | ${pkgs.jq}/bin/jq -r '.title')"
    echo "$playlist_json" | ${pkgs.jq}/bin/jq -r '.entries[]|"#EXTINF:0,\(.title)\n\(.url)"' > "''${name}.m3u"
  '';
} {
  target = "${variables.binDir}/shuf-m3u";
  source = pkgs.writeShellScript "shuf-m3u.sh" ''
    ${pkgs.gnused}/bin/sed -e 'N; s/\n/\r/g' "$1" | ${pkgs.coreutils}/bin/shuf | ${pkgs.gnused}/bin/sed 's/\r/\n/g'
  '';
}]
