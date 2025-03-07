{ variables, pkgs, ... }:
[{
  target = "${variables.homeDir}/.zen/profiles.ini";
  source = pkgs.writeText "zen-profiles.ini" ''
    [Profile0]
    Name=Default Profile
    IsRelative=1
    Path=default
    Default=1

    [General]
    StartWithLastProfile=1
    Version=2
  '';
} {
  target = "${variables.homeDir}/.zen/default/user.js";
  source = pkgs.writeText "zen-user.js" ''
    user_pref("browser.startup.page", 3);
    user_pref("general.smoothScroll", false);
    user_pref("ui.textScaleFactor", 90);
  '';
}]
