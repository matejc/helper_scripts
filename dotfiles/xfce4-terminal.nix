{ variables, config, pkgs, lib }:
{
  target = "${variables.homeDir}/.config/xfce4/terminal/terminalrc";
  source = pkgs.writeText "terminalrc" ''
[Configuration]
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=TRUE
MiscDefaultGeometry=106x49
MiscInheritGeometry=FALSE
MiscMenubarDefault=FALSE
MiscMouseAutohide=FALSE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
ScrollingOnOutput=FALSE
ScrollingBar=TERMINAL_SCROLLBAR_NONE
ScrollingLines=10000
BackgroundMode=TERMINAL_BACKGROUND_TRANSPARENT
BackgroundDarkness=0.900000
FontName=Source Code Pro Semi-Bold 11
DropdownWidth=96
DropdownHeight=96
MiscCursorShape=TERMINAL_CURSOR_SHAPE_IBEAM
TitleMode=TERMINAL_TITLE_REPLACE
DropdownToggleFocus=FALSE
DropdownKeepOpenDefault=TRUE
MiscBellUrgent=FALSE
MiscMouseWheelZoom=TRUE
MiscMiddleClickOpensUri=FALSE
MiscCopyOnSelect=FALSE
MiscDefaultWorkingDir=
MiscRewrapOnResize=TRUE
MiscUseShiftArrowsToScroll=FALSE
MiscSlimTabs=TRUE
TabActivityColor=#a6a6e2e22e2e
ColorCursor=#f8f8f8f8f2f2
ColorForeground=#f8f8f8f8f2f2
ColorBackground=#272728282222
ColorPalette=#272728282222;#f9f926267272;#a6a6e2e22e2e;#f4f4bfbf7575;#6666d9d9efef;#aeae8181ffff;#a1a1efefe4e4;#f8f8f8f8f2f2;#757571715e5e;#f9f926267272;#a6a6e2e22e2e;#f4f4bfbf7575;#6666d9d9efef;#aeae8181ffff;#a1a1efefe4e4;#f9f9f8f8f5f5
BindingBackspace=TERMINAL_ERASE_BINDING_ASCII_BACKSPACE
  '';
}
