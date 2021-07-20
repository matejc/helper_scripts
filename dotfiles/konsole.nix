{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/konsolerc";
  source = pkgs.writeText "konsolerc" ''
  [Desktop Entry]
  DefaultProfile=TheProfile.profile

  [Favorite Profiles]
  Favorites=

  [KonsoleWindow]
  ShowMenuBarByDefault=false
  ShowWindowTitleOnTitleBar=true

  [MainWindow]
  MenuBar=Disabled
  ToolBarsMovable=Disabled

  [TabBar]
  TabBarPosition=Top
  '';
} {
  target = "${variables.homeDir}/.config/yakuakerc";
  source = pkgs.writeText "yakuakerc" ''
  [Animation]
  Frames=0

  [Appearance]
  BackgroundColorOpacity=80

  [Desktop Entry]
  DefaultProfile=TheProfile.profile

  [Dialogs]
  FirstRun=false

  [Favorite Profiles]
  Favorites=

  [Shortcuts]
  close-active-terminal=Ctrl+Shift+R
  close-session=Ctrl+Shift+W
  decrease-window-height=Alt+Shift+Up
  decrease-window-width=Alt+Shift+Left
  file_quit=Ctrl+Shift+Q
  grow-terminal-bottom=Ctrl+Alt+Down
  grow-terminal-left=Ctrl+Alt+Left
  grow-terminal-right=Ctrl+Alt+Right
  grow-terminal-top=Ctrl+Alt+Up
  increase-window-height=Alt+Shift+Down
  increase-window-width=Alt+Shift+Right
  move-session-left=Ctrl+Shift+PgUp
  move-session-right=Ctrl+Shift+PgDown
  new-session=Ctrl+Shift+T
  next-session=Ctrl+PgDown
  next-terminal=Ctrl+Shift+Down
  previous-session=Ctrl+PgUp
  previous-terminal=Ctrl+Shift+Up
  rename-session=Ctrl+Alt+S
  split-left-right=Ctrl+(
  split-top-bottom=Ctrl+)
  toggle-session-monitor-activity=Ctrl+Shift+A
  toggle-session-monitor-silence=Ctrl+Shift+I
  toggle-window-state=Browser
  view-full-screen=Ctrl+Shift+F11

  [Window]
  Height=95
  Width=95
  '';
} {
  target = "${variables.homeDir}/.local/share/konsole/TheProfile.profile";
  source = pkgs.writeText "TheProfile.profile" ''
  [Appearance]
  ColorScheme=Monokai
  Font=${variables.font.family},${toString variables.font.size},-1,5,63,0,0,0,0,0,${variables.font.style}

  [Cursor Options]
  CursorShape=1

  [General]
  Name=TheProfile
  Parent=FALLBACK/

  [Interaction Options]
  CopyTextAsHTML=false

  [Scrolling]
  HistorySize=20000

  [Terminal Features]
  BlinkingCursorEnabled=true
  '';
} {
  target = "${variables.homeDir}/.local/share/konsole/Monokai.colorscheme";
  source = pkgs.writeText "Monokai.colorscheme" ''
  [Background]
  Color=40,40,40

  [BackgroundIntense]
  Color=40,40,40

  [Color0]
  Color=73,72,62

  [Color0Intense]
  Color=73,72,62

  [Color1]
  Color=249,38,114

  [Color1Intense]
  Color=249,38,114

  [Color2]
  Color=166,226,46

  [Color2Intense]
  Color=166,226,46

  [Color3]
  Color=230,219,116

  [Color3Intense]
  Color=230,219,116

  [Color4]
  Color=102,217,239

  [Color4Intense]
  Color=102,217,239

  [Color5]
  Color=249,38,114

  [Color5Intense]
  Color=249,38,114

  [Color6]
  Color=174,129,255

  [Color6Intense]
  Color=174,129,255

  [Color7]
  Color=253,151,31

  [Color7Intense]
  Color=253,151,31

  [Foreground]
  Color=248,248,242

  [ForegroundIntense]
  Color=248,248,242

  [General]
  Description=Monokai
  Opacity=0.9
  Wallpaper=
  '';
}]
