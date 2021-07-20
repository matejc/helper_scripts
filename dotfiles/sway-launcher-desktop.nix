{ variables, pkgs, ... }:
let
  launcher = pkgs.runCommand "sway-launcher-desktop" {
    src = pkgs.fetchurl {
      url = https://raw.githubusercontent.com/Biont/sway-launcher-desktop/6fd48c02160e65b9f64fe0adf778be83a4a603ce/sway-launcher-desktop.sh;
      sha256 = "sha256-7MEN0zxA4ETDOWQlIfBeMqNoR6Zu/UvXPjU8VUECjMs=";
    };
    buildInputs = [ pkgs.fzf pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    cp $src $out/bin/sway-launcher-desktop
    chmod +x $out/bin/sway-launcher-desktop
    wrapProgram $out/bin/sway-launcher-desktop \
      --prefix PATH : "${pkgs.fzf}/bin" \
      --set TERMINAL_COMMAND "exec "
  '';
in
[{
  target = "${variables.homeDir}/bin/sway-launcher-desktop";
  source = "${launcher}/bin/sway-launcher-desktop";
} /*{
  target = "${variables.homeDir}/.config/sway-launcher-desktop/providers.conf";
  source = pkgs.writeText "providers.conf" ''
    [my-provider]
    list_cmd=echo -e 'my-custom-entry\034my-provider\034  My custom provider'
    preview_cmd=echo -e 'This is the preview of {1}'
    launch_cmd=notify-send 'I am now launching {1}'
  '';
}*/]
