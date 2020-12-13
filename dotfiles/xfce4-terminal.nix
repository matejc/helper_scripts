{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/xfce4/terminal/terminalrc";
  source = pkgs.writeText "terminalrc" ''
    [Configuration]
    MiscAlwaysShowTabs=FALSE
    MiscBell=FALSE
    MiscBellUrgent=FALSE
    MiscBordersDefault=TRUE
    MiscCursorBlinks=TRUE
    MiscCursorShape=TERMINAL_CURSOR_SHAPE_IBEAM
    MiscDefaultGeometry=80x24
    MiscInheritGeometry=FALSE
    MiscMenubarDefault=FALSE
    MiscMouseAutohide=FALSE
    MiscMouseWheelZoom=TRUE
    MiscToolbarDefault=FALSE
    MiscConfirmClose=TRUE
    MiscCycleTabs=TRUE
    MiscTabCloseButtons=TRUE
    MiscTabCloseMiddleClick=TRUE
    MiscTabPosition=GTK_POS_TOP
    MiscHighlightUrls=TRUE
    MiscMiddleClickOpensUri=FALSE
    MiscCopyOnSelect=FALSE
    MiscShowRelaunchDialog=TRUE
    MiscRewrapOnResize=TRUE
    MiscUseShiftArrowsToScroll=FALSE
    MiscSlimTabs=TRUE
    MiscNewTabAdjacent=TRUE
    MiscSearchDialogOpacity=100
    MiscShowUnsafePasteDialog=TRUE
    TitleMode=TERMINAL_TITLE_REPLACE
    ScrollingLines=10000
    FontName=${variables.font.family} ${variables.font.style} ${variables.font.size}
    ColorForeground=#dcdcdc
    ColorBackground=#2c2c2c
    ColorCursor=#dcdcdc
    ColorPalette=#3f3f3f;#705050;#60b48a;#dfaf8f;#9ab8d7;#dc8cc3;#8cd0d3;#dcdcdc;#709080;#dca3a3;#72d5a3;#f0dfaf;#94bff3;#ec93d3;#93e0e3;#ffffff
    DefaultWorkingDir=~
    Encoding=UTF-8
    CommandLoginShell=TRUE
  '';
}
