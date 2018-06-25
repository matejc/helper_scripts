{ variables, config, pkgs, lib }:
[{
  target = "${variables.homeDir}/.config/kglobalshortcutsrc";
  source = pkgs.writeText "kglobalshortcutsrc" ''
  [ActivityManager]
  _k_friendly_name=System Settings
  switch-to-activity-a02746b3-6a0e-4e77-a90d-5b907b1a3b59=Ctrl+Alt+2,Ctrl+Alt+2,
  switch-to-activity-e9e45f7f-fa31-4e00-b289-763ee51655fb=Ctrl+Alt+1,Ctrl+Alt+1,

  [KDE Keyboard Layout Switcher]
  Switch to Next Keyboard Layout=Ctrl+Alt+K,none,Switch to Next Keyboard Layout
  _k_friendly_name=KDE Daemon

  [kaccess]
  Toggle Screen Reader On and Off=Meta+Alt+S,Meta+Alt+S,Toggle Screen Reader On and Off
  _k_friendly_name=Accessibility

  [kcm_touchpad]
  Disable Touchpad=Touchpad Off,Touchpad Off,Disable Touchpad
  Enable Touchpad=Touchpad On,Touchpad On,Enable Touchpad
  Toggle Touchpad=Touchpad Toggle,Touchpad Toggle,Toggle Touchpad
  _k_friendly_name=KDE Daemon

  [kded5]
  Show System Activity=Ctrl+Esc,Ctrl+Esc,Show System Activity
  _k_friendly_name=KDE Daemon
  display=Display\tMeta+P,Display\tMeta+P,Switch Display

  [khotkeys]
  _k_friendly_name=KDE Daemon
  {28127cb9-f0b6-4c48-be31-31f0691ab508}=Ctrl+Alt+T,none,term
  {31508be2-d6fa-4fb6-8fc8-2e1fbc2ae418}=Ctrl+Alt+H,none,home
  {4c36015c-f15e-424e-93df-5118e7ef3b3c}=Ctrl+Alt+Space,none,run
  {94f124f0-65dd-4ba9-acff-487fb528e03e}=Print,none,screenshot
  {d03619b6-9b3c-48cc-9d9c-a2aadb485550}=,none,Search

  [kmix]
  _k_friendly_name=Audio Volume
  decrease_microphone_volume=Microphone Volume Down,Microphone Volume Down,Decrease Microphone Volume
  decrease_volume=Volume Down,Volume Down,Decrease Volume
  increase_microphone_volume=Microphone Volume Up,Microphone Volume Up,Increase Microphone Volume
  increase_volume=Volume Up,Volume Up,Increase Volume
  mic_mute=Microphone Mute,Microphone Mute,Mute Microphone
  mute=Volume Mute,Volume Mute,Mute

  [krunner]
  _k_friendly_name=Run Command
  run command=\tAlt+F2\tSearch,Alt+Space,Run Command
  run command on clipboard contents=Alt+Shift+F2,Alt+Shift+F2,Run Command on clipboard contents

  [ksmserver]
  Halt Without Confirmation=Ctrl+Alt+Shift+PgDown,none,Halt Without Confirmation
  Lock Session=Ctrl+Alt+L\tScreensaver,Ctrl+Alt+L\tScreensaver,Lock Session
  Log Out=Ctrl+Alt+Del,none,Log Out
  Log Out Without Confirmation=Ctrl+Alt+Shift+Del,none,Log Out Without Confirmation
  Reboot Without Confirmation=Ctrl+Alt+Shift+PgUp,none,Reboot Without Confirmation
  _k_friendly_name=ksmserver

  [kwin]
  Activate Window Demanding Attention=,Ctrl+Alt+A,Activate Window Demanding Attention
  Decrease Opacity=none,none,Decrease Opacity of Active Window by 5 %
  Expose=Ctrl+F9,Ctrl+F9,Toggle Present Windows (Current desktop)
  ExposeAll=Ctrl+F10\tLaunch (C),Ctrl+F10\tLaunch (C),Toggle Present Windows (All desktops)
  ExposeClass=Ctrl+F7,Ctrl+F7,Toggle Present Windows (Window class)
  FlipSwitchAll=none,none,Toggle Flip Switch (All desktops)
  FlipSwitchCurrent=none,none,Toggle Flip Switch (Current desktop)
  Increase Opacity=none,none,Increase Opacity of Active Window by 5 %
  Invert Screen Colors=none,none,Invert Screen Colors
  Kill Window=Ctrl+Alt+Esc,Ctrl+Alt+Esc,Kill Window
  MoveMouseToCenter=Meta+F6,Meta+F6,Move Mouse to Center
  MoveMouseToFocus=Meta+F5,Meta+F5,Move Mouse to Focus
  MoveZoomDown=,Meta+Down,Move Zoomed Area Downwards
  MoveZoomLeft=,Meta+Left,Move Zoomed Area to Left
  MoveZoomRight=,Meta+Right,Move Zoomed Area to Right
  MoveZoomUp=,Meta+Up,Move Zoomed Area Upwards
  Remove Window From Group=none,none,Remove Window From Group
  Setup Window Shortcut=none,none,Setup Window Shortcut
  Show Desktop=none,none,Show Desktop
  ShowDesktopGrid=Ctrl+F8,Ctrl+F8,Show Desktop Grid
  Suspend Compositing=Alt+Shift+F12,Alt+Shift+F12,Suspend Compositing
  Switch One Desktop Down=Ctrl+Alt+Down,none,Switch One Desktop Down
  Switch One Desktop Up=Ctrl+Alt+Up,none,Switch One Desktop Up
  Switch One Desktop to the Left=Ctrl+Alt+Left,none,Switch One Desktop to the Left
  Switch One Desktop to the Right=Ctrl+Alt+Right,none,Switch One Desktop to the Right
  Switch Window Down=Meta+Down,Meta+Alt+Down,Switch to Window Below
  Switch Window Left=Meta+Left,Meta+Alt+Left,Switch to Window to the Left
  Switch Window Right=Meta+Right,Meta+Alt+Right,Switch to Window to the Right
  Switch Window Up=Meta+Up,Meta+Alt+Up,Switch to Window Above
  Switch to Desktop 1=Ctrl+F1,Ctrl+F1,Switch to Desktop 1
  Switch to Desktop 10=none,none,Switch to Desktop 10
  Switch to Desktop 11=none,none,Switch to Desktop 11
  Switch to Desktop 12=none,none,Switch to Desktop 12
  Switch to Desktop 13=none,none,Switch to Desktop 13
  Switch to Desktop 14=none,none,Switch to Desktop 14
  Switch to Desktop 15=none,none,Switch to Desktop 15
  Switch to Desktop 16=none,none,Switch to Desktop 16
  Switch to Desktop 17=none,none,Switch to Desktop 17
  Switch to Desktop 18=none,none,Switch to Desktop 18
  Switch to Desktop 19=none,none,Switch to Desktop 19
  Switch to Desktop 2=Ctrl+F2,Ctrl+F2,Switch to Desktop 2
  Switch to Desktop 20=none,none,Switch to Desktop 20
  Switch to Desktop 3=Ctrl+F3,Ctrl+F3,Switch to Desktop 3
  Switch to Desktop 4=Ctrl+F4,Ctrl+F4,Switch to Desktop 4
  Switch to Desktop 5=Ctrl+F5,none,Switch to Desktop 5
  Switch to Desktop 6=Ctrl+F6,none,Switch to Desktop 6
  Switch to Desktop 7=none,none,Switch to Desktop 7
  Switch to Desktop 8=none,none,Switch to Desktop 8
  Switch to Desktop 9=none,none,Switch to Desktop 9
  Switch to Next Desktop=none,none,Switch to Next Desktop
  Switch to Next Screen=none,none,Switch to Next Screen
  Switch to Previous Desktop=none,none,Switch to Previous Desktop
  Switch to Previous Screen=none,none,Switch to Previous Screen
  Switch to Screen 0=none,none,Switch to Screen 0
  Switch to Screen 1=none,none,Switch to Screen 1
  Switch to Screen 2=none,none,Switch to Screen 2
  Switch to Screen 3=none,none,Switch to Screen 3
  Switch to Screen 4=none,none,Switch to Screen 4
  Switch to Screen 5=none,none,Switch to Screen 5
  Switch to Screen 6=none,none,Switch to Screen 6
  Switch to Screen 7=none,none,Switch to Screen 7
  Toggle Window Raise/Lower=none,none,Toggle Window Raise/Lower
  Walk Through Desktop List=none,none,Walk Through Desktop List
  Walk Through Desktop List (Reverse)=none,none,Walk Through Desktop List (Reverse)
  Walk Through Desktops=none,none,Walk Through Desktops
  Walk Through Desktops (Reverse)=none,none,Walk Through Desktops (Reverse)
  Walk Through Window Tabs=none,none,Walk Through Window Tabs
  Walk Through Window Tabs (Reverse)=none,none,Walk Through Window Tabs (Reverse)
  Walk Through Windows=Alt+Tab,none,Walk Through Windows
  Walk Through Windows (Reverse)=Alt+Shift+Backtab,none,Walk Through Windows (Reverse)
  Walk Through Windows Alternative=Meta+Tab,none,Walk Through Windows Alternative
  Walk Through Windows Alternative (Reverse)=none,none,Walk Through Windows Alternative (Reverse)
  Walk Through Windows of Current Application=Alt+`,none,Walk Through Windows of Current Application
  Walk Through Windows of Current Application (Reverse)=Alt+~,none,Walk Through Windows of Current Application (Reverse)
  Walk Through Windows of Current Application Alternative=none,none,Walk Through Windows of Current Application Alternative
  Walk Through Windows of Current Application Alternative (Reverse)=none,none,Walk Through Windows of Current Application Alternative (Reverse)
  Window Above Other Windows=none,none,Keep Window Above Others
  Window Below Other Windows=none,none,Keep Window Below Others
  Window Close=Alt+F4,Alt+F4,Close Window
  Window Fullscreen=none,none,Make Window Fullscreen
  Window Grow Horizontal=none,none,Pack Grow Window Horizontally
  Window Grow Vertical=none,none,Pack Grow Window Vertically
  Window Lower=none,none,Lower Window
  Window Maximize=Meta+Shift+Up,none,Maximize Window
  Window Maximize Horizontal=none,none,Maximize Window Horizontally
  Window Maximize Vertical=none,none,Maximize Window Vertically
  Window Minimize=none,none,Minimize Window
  Window Move=none,none,Move Window
  Window No Border=none,none,Hide Window Border
  Window On All Desktops=none,none,Keep Window on All Desktops
  Window One Desktop Down=Ctrl+Alt+Shift+Down,none,Window One Desktop Down
  Window One Desktop Up=Ctrl+Alt+Shift+Up,none,Window One Desktop Up
  Window One Desktop to the Left=Ctrl+Alt+Shift+Left,none,Window One Desktop to the Left
  Window One Desktop to the Right=Ctrl+Alt+Shift+Right,none,Window One Desktop to the Right
  Window Operations Menu=Alt+F3,Alt+F3,Window Operations Menu
  Window Pack Down=,none,Pack Window Down
  Window Pack Left=,none,Pack Window to the Left
  Window Pack Right=,none,Pack Window to the Right
  Window Pack Up=,none,Pack Window Up
  Window Quick Tile Bottom=,none,Quick Tile Window to the Bottom
  Window Quick Tile Bottom Left=none,none,Quick Tile Window to the Bottom Left
  Window Quick Tile Bottom Right=none,none,Quick Tile Window to the Bottom Right
  Window Quick Tile Left=Meta+Shift+Left,none,Quick Tile Window to the Left
  Window Quick Tile Right=Meta+Shift+Right,none,Quick Tile Window to the Right
  Window Quick Tile Top=,none,Quick Tile Window to the Top
  Window Quick Tile Top Left=none,none,Quick Tile Window to the Top Left
  Window Quick Tile Top Right=none,none,Quick Tile Window to the Top Right
  Window Raise=none,none,Raise Window
  Window Resize=none,none,Resize Window
  Window Shade=none,none,Shade Window
  Window Shrink Horizontal=none,none,Pack Shrink Window Horizontally
  Window Shrink Vertical=none,none,Pack Shrink Window Vertically
  Window to Desktop 1=none,none,Window to Desktop 1
  Window to Desktop 10=none,none,Window to Desktop 10
  Window to Desktop 11=none,none,Window to Desktop 11
  Window to Desktop 12=none,none,Window to Desktop 12
  Window to Desktop 13=none,none,Window to Desktop 13
  Window to Desktop 14=none,none,Window to Desktop 14
  Window to Desktop 15=none,none,Window to Desktop 15
  Window to Desktop 16=none,none,Window to Desktop 16
  Window to Desktop 17=none,none,Window to Desktop 17
  Window to Desktop 18=none,none,Window to Desktop 18
  Window to Desktop 19=none,none,Window to Desktop 19
  Window to Desktop 2=none,none,Window to Desktop 2
  Window to Desktop 20=none,none,Window to Desktop 20
  Window to Desktop 3=none,none,Window to Desktop 3
  Window to Desktop 4=none,none,Window to Desktop 4
  Window to Desktop 5=none,none,Window to Desktop 5
  Window to Desktop 6=none,none,Window to Desktop 6
  Window to Desktop 7=none,none,Window to Desktop 7
  Window to Desktop 8=none,none,Window to Desktop 8
  Window to Desktop 9=none,none,Window to Desktop 9
  Window to Next Desktop=none,none,Window to Next Desktop
  Window to Next Screen=none,none,Window to Next Screen
  Window to Previous Desktop=none,none,Window to Previous Desktop
  Window to Previous Screen=none,none,Window to Previous Screen
  Window to Screen 0=none,none,Window to Screen 0
  Window to Screen 1=none,none,Window to Screen 1
  Window to Screen 2=none,none,Window to Screen 2
  Window to Screen 3=none,none,Window to Screen 3
  Window to Screen 4=none,none,Window to Screen 4
  Window to Screen 5=none,none,Window to Screen 5
  Window to Screen 6=none,none,Window to Screen 6
  Window to Screen 7=none,none,Window to Screen 7
  _k_friendly_name=KWin
  view_actual_size=Meta+0,Meta+0,Actual Size
  view_zoom_in=Meta+=,Meta+=,Zoom In
  view_zoom_out=Meta+-,Meta+-,Zoom Out

  [mediacontrol]
  _k_friendly_name=Media Controller
  nextmedia=Media Next,Media Next,Media playback next
  playpausemedia=Media Play,Media Play,Play/Pause media playback
  previousmedia=Media Previous,Media Previous,Media playback previous
  stopmedia=Media Stop,Media Stop,Stop media playback

  [org_kde_powerdevil]
  Decrease Keyboard Brightness=Keyboard Brightness Down,Keyboard Brightness Down,Decrease Keyboard Brightness
  Decrease Screen Brightness=Monitor Brightness Down,Monitor Brightness Down,Decrease Screen Brightness
  Hibernate=Hibernate,Hibernate,Hibernate
  Increase Keyboard Brightness=Keyboard Brightness Up,Keyboard Brightness Up,Increase Keyboard Brightness
  Increase Screen Brightness=Monitor Brightness Up,Monitor Brightness Up,Increase Screen Brightness
  PowerOff=Power Off,Power Off,Power Off
  Sleep=Sleep,Sleep,Suspend
  Toggle Keyboard Backlight=Keyboard Light On/Off,Keyboard Light On/Off,Toggle Keyboard Backlight
  _k_friendly_name=Power Management

  [plasmashell]
  _k_friendly_name=Plasma
  activate task manager entry 1=Meta+1,Meta+1,Activate Task Manager Entry 1
  activate task manager entry 10=,Meta+0,Activate Task Manager Entry 10
  activate task manager entry 2=Meta+2,Meta+2,Activate Task Manager Entry 2
  activate task manager entry 3=Meta+3,Meta+3,Activate Task Manager Entry 3
  activate task manager entry 4=Meta+4,Meta+4,Activate Task Manager Entry 4
  activate task manager entry 5=Meta+5,Meta+5,Activate Task Manager Entry 5
  activate task manager entry 6=Meta+6,Meta+6,Activate Task Manager Entry 6
  activate task manager entry 7=Meta+7,Meta+7,Activate Task Manager Entry 7
  activate task manager entry 8=Meta+8,Meta+8,Activate Task Manager Entry 8
  activate task manager entry 9=Meta+9,Meta+9,Activate Task Manager Entry 9
  clear-history=none,none,Clear Clipboard History
  clipboard_action=none,Ctrl+Alt+X,Enable Clipboard Actions
  cycleNextAction=none,none,Next History Item
  cyclePrevAction=none,none,Previous History Item
  edit_clipboard=none,none,Edit Contents...
  manage activities=Meta+Q,Meta+Q,Activities...
  next activity=none,none,Walk through activities
  previous activity=none,none,Walk through activities (Reverse)
  repeat_action=none,Ctrl+Alt+R,Manually Invoke Action on Current Clipboard
  show dashboard=Ctrl+F12,Ctrl+F12,Show Desktop
  show-barcode=none,none,Show Barcode...
  show-on-mouse-pos=none,none,Open Klipper at Mouse Position
  stop current activity=Meta+S,Meta+S,Stop Current Activity

  [yakuake]
  _k_friendly_name=Yakuake
  toggle-window-state=F12\tBrowser,F12,Open/Retract Yakuake
  '';
}]
