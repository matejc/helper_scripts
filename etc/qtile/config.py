import sys

# for pyudev
sys.path.append("/nix/var/nix/profiles/per-user/matej/py27/lib/python2.7/site-packages")

from libqtile.config import Key, Screen, Group, Drag, Click, Match
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook
from subprocess import call, check_output

import os
import urllib2
import re
import time
import json

mod = "mod4"

os.environ['PATH'] += ':/run/current-system/sw/bin:/home/matejc/workarea/helper_scripts/bin'

def feh(qtile):
    os.system("feh --bg-fill $(randimage.py /home/matejc/Pictures/wallpapers/)")


def get_fake_screens(obj):
    if not obj or obj['count'] == 1:
        return []
    else:
        return [
            Screen(
                x=0,
                y=0,
                width=obj['mon0']['width'],
                height=obj['mon0']['height'],
                # bottom=bottomBar
            ),
            Screen(
                x=obj['mon0']['width'],
                y=0,
                width=obj['mon1']['width'],
                height=obj['mon1']['height'],
                # bottom=bottomBar
            )
        ]


fake_screens = []


def set_fake_screens(obj):
    global fake_screens
    fake_screens = get_fake_screens(obj)


def xrandr_exec(qtile):
    try:
        output = check_output("/home/matejc/workarea/helper_scripts/etc/qtile/scan_screens.sh")
        obj = json.loads(output)
        # debug(json.dumps(obj))
        # set_fake_screens(obj)
        return obj
    except Exception, e:
        debug("ERROR: %s" % e)

def fromExt(qtile):
    w = qtile.groupMap['ext'].currentWindow
    groupName = qtile.currentGroup.name
    w.cmd_togroup(groupName)

def toExt(qtile):
    w = qtile.currentGroup.currentWindow
    w.cmd_togroup('ext')

keys = [
    # Switch between windows in current stack pane
    Key(
        [mod], "k",
        lazy.function(fromExt)
    ),
    Key(
        [mod], "j",
        lazy.function(toExt)
    ),

    # Switch window focus to other pane(s) of stack
    Key(["mod1"], "Tab",lazy.layout.next()),
    Key([mod], "Right",lazy.layout.next()),
    Key([mod], "Left",lazy.layout.previous()),

    # Swap panes of split stack
    Key(
        [mod, "shift"], "space",
        lazy.layout.rotate()
    ),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"], "Return",
        lazy.layout.toggle_split()
    ),
    Key([mod], "Return", lazy.spawn("xfce4-terminal")),
    Key(["control", "mod1"], "t", lazy.spawn("xfce4-terminal")),
    Key(["control", "mod1"], "h", lazy.spawn("spacefm")),
    Key(["control", "mod1"], "space", lazy.spawn("dmenu-run.py")),
    Key(["control", "mod1"], "l", lazy.spawn("lockscreen")),
    Key(["control", "mod1"], "w", lazy.function(feh)),
    Key(["control", "mod1"], "d", lazy.function(xrandr_exec)),
    Key([], "XF86MonBrightnessDown", lazy.spawn("xbacklight -dec 10")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("xbacklight -inc 10")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("volume 0 decrease")),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("volume 0 increase")),
    Key([], "XF86AudioMute", lazy.spawn("volume 0 toggle")),

    # Toggle between different layouts as defined below
    Key([mod], "space", lazy.next_layout()),
    Key([mod], "w", lazy.window.kill()),
    Key([mod], "q", lazy.window.kill()),

    Key([mod, "control"], "r", lazy.restart()),
    Key([mod, "control"], "q", lazy.shutdown()),
    Key([mod], "r", lazy.spawncmd()),
    Key(["mod1"], "F2", lazy.spawncmd())
]

groups = [Group(i) for i in "123456"]

for i in groups:
    # mod1 + letter of group = switch to group
    keys.append(
        Key([mod], i.name, lazy.group[i.name].toscreen())
    )

    # mod1 + shift + letter of group = switch to & move focused window to group
    keys.append(
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name))
    )


groups = [
    Group('ext'),
    Group('t'),
    Group('e'),
    Group('w', spawn='chromium'),
] + groups

def moveExtToOne(qtile):
    try:
        qtile.groupMap['ext'].cmd_toscreen(1)
    except Exception, e:
        debug(str(e))


def getIndex(currentGroupName):
    for i in xrange(len(groups)):
        if groups[i].name == currentGroupName:
            return i

def toPrevGroup(qtile):
    moveExtToOne(qtile)
    currentGroup = qtile.currentGroup.name
    i = (getIndex(currentGroup) - 1) % len(groups)
    if i == 0:
        return
    qtile.currentWindow.togroup(groups[i].name)
    qtile.groupMap[groups[i].name].cmd_toscreen()

def toNextGroup(qtile):
    moveExtToOne(qtile)
    currentGroup = qtile.currentGroup.name
    i = (getIndex(currentGroup) + 1) % len(groups)
    if i == 0:
        return
    qtile.currentWindow.togroup(groups[i].name)
    qtile.groupMap[groups[i].name].cmd_toscreen()

def prevGroup(qtile):
    moveExtToOne(qtile)
    currentGroup = qtile.currentGroup.name
    i = (getIndex(currentGroup) - 1) % len(groups)
    if i == 0 or qtile.currentScreen.index == 1:
        return
    qtile.groupMap[groups[i].name].cmd_toscreen()

def nextGroup(qtile):
    moveExtToOne(qtile)
    currentGroup = qtile.currentGroup.name
    i = (getIndex(currentGroup) + 1) % len(groups)
    if i == 0 or qtile.currentScreen.index == 1:
        return
    qtile.groupMap[groups[i].name].cmd_toscreen()


keys.append(Key(["control", "mod1"], "Left", lazy.function(prevGroup)))
keys.append(Key(["control", "mod1"], "Right", lazy.function(nextGroup)))
keys.append(Key(["control", "mod1", "shift"], "Left", lazy.function(toPrevGroup)))
keys.append(Key(["control", "mod1", "shift"], "Right", lazy.function(toNextGroup)))


layouts = [
    layout.Max(),
    layout.Stack(num_stacks=2)
]

widget_defaults = dict(
    font='DejaVu Sans Mono for Powerline',
    # font='Cantarell',
    fontsize=14,
    padding=1,
)


def temp():
    result = ''
    with open('/tmp/temp1_input', 'r') as f:
        result = f.read()
    return u"%s\u00b0C" % (result[0:-4])


def debug(something):
    with open('/tmp/qtile-debug', 'a') as f:
        f.write('[%s] %s\n' % (time.asctime(), str(something)))

def qotd():
    address = 'http://programmingexcuses.com/'
    try:
        website = urllib2.urlopen(address)
        website_html = website.read()
        matches = re.findall('<a .*?>(.*?)</a>', website_html)
        return u"[%s]" % matches[0]
    except Exception, e:
        return str(e)

bottomBar = bar.Bar(
    [
        widget.GroupBox(borderwidth=2),
        widget.Prompt(),
        widget.WindowName(),
        # widget.GenPollText(update_interval=500, func=qotd),
        widget.CPUGraph(width=30, graph_color='18EBBA', border_width=0),
        widget.MemoryGraph(width=30, graph_color='FAFA9B', border_width=0),
        widget.HDDBusyGraph(width=30, graph_color='EB187A', border_width=0),
        widget.Battery(padding=3, foreground='BABABA'),
        widget.GenPollText(update_interval=5, func=temp, padding=3, foreground='EB187A'),
        widget.Volume(padding=3, foreground='FAFA9B'),
        widget.Wlan(interface='wlp3s0', padding=3, interval=5, foreground='18BAEB'),
        widget.NetGraph(width=30, border_width=0),
        widget.Clock(format='%d.%m.%Y %a %H:%M', padding=3),
        widget.Systray(),
    ],
    22,
)

screens = [
    Screen(
        bottom=bottomBar
    )
]

# Drag floating layouts.
mouse = [
    Drag(["mod1"], "Button1", lazy.window.set_position_floating(),
        start=lazy.window.get_position()),
    Drag(["mod1"], "Button3", lazy.window.set_size_floating(),
        start=lazy.window.get_size()),
    Click(["mod1"], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating()
auto_fullscreen = True

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, github issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

@hook.subscribe.startup_once
def runner():
    call("/home/matejc/workarea/helper_scripts/etc/qtile/start.sh")
    # try:
    #     lazy.group['ext'].to_screen(1)
    # except Exception, e:
    #     debug(str(e))

#     subprocess.Popen(['zed'])


def detect_screens(qtile):
    """
    Detect if a new screen is plugged and reconfigure/restart qtile
    """

    def setup_monitors(action=None, device=None):
        obj = xrandr_exec(qtile)
        if action == 'change':
            os.environ["QTILEXRANDR"] = json.dumps(obj)
            qtile.cmd_restart()

    setup_monitors()
    # xrandr_exec(qtile)

    import pyudev

    context = pyudev.Context()
    monitor = pyudev.Monitor.from_netlink(context)
    monitor.filter_by('drm')
    monitor.enable_receiving()

    # observe if the monitors change and reset monitors config
    observer = pyudev.MonitorObserver(monitor, setup_monitors)
    observer.start()


def main(qtile):
    # obj = json.loads(os.environ.get("QTILEXRANDR", '{"count":1}'))
    # debug(json.dumps(obj))
    # try:
    #     time.sleep(1)
    #     # qtile.groupMap['ext'].cmd_toscreen(1)
    #     lazy.group['ext'].to_screen(1)
    # except Exception, e:
    #     debug(str(e))
    # time.sleep(2)
    detect_screens(qtile)
