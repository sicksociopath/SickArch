#axkirian qtile config

#Libraries and modules
from typing import List  # noqa: F401
from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
import os

#Key used for special actions
#mod = "mod4"    #SuperKey
mod = "mod4"     #Alt-Rigth

#Used terminal
terminal = "alacritty"

#Key Shortcuts Config
keys = [
    #Move between windows
    Key([mod], "h", lazy.layout.left()),
    Key([mod], "l", lazy.layout.right()),
    Key([mod], "k", lazy.layout.up()),
    Key([mod], "j", lazy.layout.down()),
    Key(["mod1"], "Tab", lazy.layout.next()),
    #Move windows
    Key([mod, "shift"], "h", lazy.layout.shuffle_left()),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right()),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    #Grow current Window
    Key([mod,"control"], "h", lazy.layout.grow_left()),
    Key([mod,"control"], "l", lazy.layout.grow_right()),
    Key([mod,"control"], "k", lazy.layout.grow_up()),
    Key([mod,"control"], "j", lazy.layout.grow_down()),
    #Floating to Tiling
    Key([mod], "f", lazy.window.toggle_floating()),
    #Toggle between layouts
    Key([mod], "Tab", lazy.next_layout()),
    #Close Window
    Key([mod], "w", lazy.window.kill()),
    #Reload config
    Key([mod, "control"], "r", lazy.reload_config()),
    #Quit Qtile
    Key([mod, "control"], "q", lazy.shutdown()),
    #Volumen keys
    Key([], "XF86AudioMute", lazy.spawn("amixer -q set Master toggle")),
    Key([], "XF86AudioLowerVolume",
        lazy.spawn("amixer -c 0 sset Master 2- unmute")),
    Key([], "XF86AudioRaiseVolume",
        lazy.spawn("amixer -c 0 sset Master 2+ unmute")),
    #Launch Rofi
    Key(["mod1"], "space", lazy.spawn("rofi -show run")),
    #Launch Termianal
    Key([mod], "Return", lazy.spawn(terminal)),
    #Firefox Profiles
    Key(["mod1", "shift"], "1", lazy.spawn("firefox -P Privacy_2")),
    Key(["mod1", "shift"], "2", lazy.spawn("firefox -P GoogleServices")),
    Key(["mod1", "shift"], "3", lazy.spawn("firefox -P Clean")),
    Key(["mod1", "shift"], "4", lazy.spawn("firefox -P WhatsApp")),
    Key(["mod1", "shift"], "5", lazy.spawn("firefox -P WinkWink"))
]

#Define Groups
groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend([
    # mod + number of the group = switch to group
    Key(["mod5"], i.name, lazy.group[i.name].toscreen()),
    # mod + shift + number of the group = switch to group
    # and move window to group
    Key(["mod5", "shift"], i.name,
    lazy.window.togroup(i.name, switch_group=True))
    ])

#Define Layouts

#Floating rules
darules = [
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),
    Match(wm_class='makebranch'),
    Match(wm_class='maketag'),
    Match(wm_class='ssh-askpass'),
    Match(title='branchdialog'),
    Match(title='pinentry')
]

#Colors
focus = '#01effc'
normal = '#000000'

layouts = [
    #Max Layout
    layout.Max(),
    #Column Layout
    layout.Columns(
        border_focus=focus,
        border_normal=normal,
        border_on_single=True,
        border_width=1,
        margin=2,
        margin_on_single=2
        ),
    #Floating Layout
    layout.Floating(float_rules = darules,
        border_focus=focus,
        border_normal=normal)
]

#Define Widget
widget_defaults = dict(
    font = 'Ubuntu',
    fontsize = '12',
    padding = 2
)

extension_defaults = widget_defaults.copy()

Widgets_1 = [
    widget.CurrentLayoutIcon(),
    widget.CurrentLayout(),
    widget.PulseVolume(),
    widget.Spacer(icon_size = 15),
    widget.Systray(),
    widget.Clock(format='%I:%M %p %Y-%m-%d', font = 'Fira Code')
    ]

Widgets_2 = [
    widget.WindowTabs(fontsize = '10'),
    ]

#Define Screen
screens = [Screen(top=bar.Bar(Widgets_1,17),
                    bottom=bar.Bar(Widgets_2,17))]

#Drag floating layouts
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size())
]

#Other
dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "LG3D"

#StartUp
os.system("feh --bg-fill /home/axkirian/Pictures/Wallpapers/Wallpaper_2.jpg")
os.system("nm-applet &")
os.system("powerkit &")
