# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Todo
#   Scratchpad
#   Sticky move
#   alt-tab behaviours
#   Colors:   https://github.com/catppuccin/catppuccin


import random

from os import getenv, path

from subprocess import call, check_output, run, Popen

from libqtile import extension, hook, bar, layout
from libqtile.config import Click, Drag, Group, Key, EzKey, KeyChord, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.log_utils import logger
from libqtile import qtile

# from libqtile import widget
from qtile_extras import widget
from qtile_extras.widget.decorations import RectDecoration, PowerLineDecoration


class Commands:
    arandr = 'arandr'
    autorandr = ['autorandr', '--change']
    alsamixer = 'st -e alsamixer'
    volume_up = 'amixer -q -c 0 sset Master 5dB+'
    volume_down = 'amixer -q -c 0 sset Master 5dB-'
    volume_toggle = 'amixer -q set Master toggle'
    mic_toggle = 'amixer -q set Dmic0 toggle'
    screenshot_all = 'scrot'
    screenshot_window = 'scrot -u'
    screenshot_selection = 'scrot -s'
    brightness_up = 'light -A 5'
    brightness_down = 'light -U 5'
    calendar = "gnome-calendar"
    dropbox = "dropbox start".split()
    # picom = ["picom","-b"]
    # picom = "picom -b --corner-radius 5 -f -D 5 -c --inactive-opacity 0.9 --shadow-color #FF0000".split(" ")
    picom = ("picom --experimental-backends --config " + path.expanduser("~/Dropbox/workspaces/dotfiles/picom.conf")).split()
    
    # lock = 'i3lock-fancy -p'
    # lock = 'slock'
    lock = 'xsecurelock'
    # suspend = 'systemctl suspend && i3lock-fancy'
    # suspend = 'systemctl suspend '
    # suspend = 'slock systemctl suspend'
    suspend = 'xsecurelock -- systemctl suspend'
    restart = 'reboot'
    halt = 'systemctl poweroff'
    logout = 'qtile cmd-obj -o cmd -f shutdown'
    qtile_restart = 'qtile cmd-obj -o cmd -f restart'
    wallpaper_set_random = "feh --recursive --bg-fill --randomize ~/Pictures/variety"
    wallpaper_set = "feh --bg-fill".split()
    update = 'gnome-terminal -- bash -c "set x && set eup pipefail && sudo apt-get update && sudo apt-get upgrade"'

    def get_uptime(self):
        return check_output(['uptime', '-p']).decode("utf-8").replace("\n", "")


commands = Commands()

class Colors:
    from catppuccin import Flavour
    
    colors = [
        Flavour.mocha().rosewater.hex,
        Flavour.mocha().flamingo.hex,
        Flavour.mocha().pink.hex,
        Flavour.mocha().mauve.hex,
        Flavour.mocha().red.hex,
        Flavour.mocha().maroon.hex,
        Flavour.mocha().peach.hex,
        Flavour.mocha().yellow.hex,
        Flavour.mocha().green.hex,
        Flavour.mocha().teal.hex,
        Flavour.mocha().sky.hex,
        Flavour.mocha().sapphire.hex,
        Flavour.mocha().blue.hex,
        Flavour.mocha().lavender.hex
    ]

    colors_grayscale = [
        Flavour.mocha().subtext1.hex,  # White
        Flavour.mocha().subtext1.hex,
        Flavour.mocha().subtext0.hex,
        Flavour.mocha().overlay2.hex,
        Flavour.mocha().overlay1.hex,
        Flavour.mocha().surface2.hex,
        Flavour.mocha().surface1.hex,
        Flavour.mocha().surface0.hex,
        Flavour.mocha().base.hex,
        Flavour.mocha().mantle.hex,
        Flavour.mocha().crust.hex,      # Black
    ]


    border_active = Flavour.mocha().lavender.hex
    border_inactive = Flavour.mocha().overlay0.hex
    text_white = Flavour.mocha().text.hex
    text_black = Flavour.mocha().crust.hex



    def __init__(self):
        self.color_index_ = 0

    def get_color(self, increment = 2):
        self.color_index_ += increment
        idx = self.color_index_ % len(Colors.colors)
        return Colors.colors[idx] 

colors = Colors()





# See modkeys by running: xmodmap
mod = "mod4"
alt = "mod1"

# terminal = guess_terminal()
terminal = "gnome-terminal --hide-menubar"
# terminal = "kitty"

# Keys
# =======================

# A list of available commands that can be bound to keys can be found
# at https://docs.qtile.org/en/latest/manual/config/lazy.html       

# List of special keys:
# https://github.com/qtile/qtile/blob/master/libqtile/backend/x11/xkeysyms.py


keys = [

    # Qtile basic
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([alt, "control"], "t", lazy.spawn(terminal), desc="Launch terminal - alt command"),

    # Sound
    Key([], 'XF86AudioRaiseVolume', lazy.spawn(Commands.volume_up)),
    Key([], 'XF86AudioLowerVolume', lazy.spawn(Commands.volume_down)),
    Key([], 'XF86AudioMute', lazy.spawn(Commands.volume_toggle)),
    Key([], 'XF86AudioMicMute', lazy.spawn(Commands.mic_toggle)),

    # Other FN keys
    Key([], 'XF86MonBrightnessUp', lazy.spawn(Commands.brightness_up)),
    Key([], 'XF86MonBrightnessDown', lazy.spawn(Commands.brightness_down)),
    Key([], 'XF86Display', lazy.spawn(Commands.arandr)),

    # Screenshot
    Key([], 'Print', lazy.spawn(Commands.screenshot_selection), desc='scrot selection'),
    Key([mod], 'Print', lazy.spawn(Commands.screenshot_all), desc='scrot screen'),
    Key([alt], 'Print', lazy.spawn(Commands.screenshot_window), desc='scrot window'),
    
    # App launch
    Key([mod, "shift"], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], 'r', lazy.run_extension(extension.DmenuRun(
        dmenu_prompt="Applications: ",
        dmenu_ignorecase = True,
        dmenu_lines = 10,
    ))),
    
    #Other dmenu
    EzKey("M-A-w", lazy.run_extension(extension.WindowList(item_format="{group}: {window}")), desc='window list'),
    # EzKey("M-C-c", lazy.run_extension(extension.Dmenu(dmenu_command="clipmenu")), desc='clipmenu'),
    # EzKey("M-A-p", lazy.run_extension(extension.Dmenu(dmenu_command="passmenu")), desc='passmenu'),
    # EzKey("M-A-n", lazy.run_extension(extension.Dmenu(dmenu_command="networkmanager_dmenu")), desc='dmenu networking'),
    EzKey("M-C-q", lazy.run_extension(extension.CommandSet(
        commands={
            'lock': Commands.lock,
            'suspend': Commands.suspend,
            'restart': Commands.restart,
            'shutdown': Commands.halt,
            'logout': Commands.logout,
            'qtile_reload': Commands.qtile_restart,
            })),
        desc='dmenu session manager'),
]

# KeyChords
# =======================

@lazy.function
def ungrab_nx_chord(qtile, number_of_ungraps):
    for i in range(0, number_of_ungraps):
        qtile.ungrab_chord()


keys.extend([
    KeyChord([mod], "tab", [
        Key([], "j", lazy.layout.shuffle_left(), desc="Move window to the left"),
        Key([], "ae", lazy.layout.shuffle_right(), desc="Move window to the right"),
        Key([], "k", lazy.layout.shuffle_down(), desc="Move window down"),
        Key([], "l", lazy.layout.shuffle_up(), desc="Move window up"),
        Key([], "Return", lazy.ungrab_all_chords()),
        KeyChord([mod], "tab", [
            Key([], "j", lazy.layout.grow_left(), desc="Grow window to the left"),
            Key([], "ae", lazy.layout.grow_right(), desc="Grow window to the right"),
            Key([], "k", lazy.layout.grow_down(), desc="Grow window down"),
            Key([], "l", lazy.layout.grow_up(), desc="Grow window up"),
            Key([], "Return", lazy.ungrab_all_chords()),
            KeyChord([mod], "tab", [
                    Key([], "r", lazy.layout.normalize(), desc="Reset all window sizes"),    
                    Key([], "s", lazy.layout.toggle_split(), desc="Toggle between split and unsplit sides of stack",),
                    Key([], "space", lazy.next_layout(), desc="Toggle between layouts"),
                    Key([], "m", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on the focused window", ),
                    Key([], "f", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
                    Key([], "Return", lazy.ungrab_all_chords()),
                    Key([], "tab", ungrab_nx_chord(2)),
                ],
                mode=True,
                name="Max, Flot, Split, Rest, Layout (space)"
            ),
            ],
            mode=True,
            name="resize"
            ),
        ],
        mode=True,
        name="move"
        )
])
        

# Default qtile groups
# =======================

groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            # mod1 + letter of group = switch to group
            # mod1 + shift + letter of group = switch to & move focused window to group
            Key([mod], i.name, lazy.group[i.name].toscreen(), desc="Switch to group {}".format(i.name)),
            Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True), desc="Switch to & move focused window to group {}".format(i.name),),
        ]
    )



# Grid groups
# =======================

class Grid:
    rows = 3
    cols = 4

    def to_idx(row, col):
        return int(row * Grid.cols + col)

    def to_cell(idx):
        return int(idx / Grid.cols), int(idx % Grid.cols)


if len(groups) < Grid.rows * Grid.cols:
    for i in range(len(groups)+1, Grid.rows * Grid.cols + 1):
        groups.append(Group(str(i)))

def get_current_group(qtile):
    try:
        idx = qtile.groups.index(qtile.current_group)
        return Grid.to_cell(idx)
    except Exception:
        logger.warning("Uh oh, something went wrong here")
        logger.exception("Uh oh!")
        return 0

def switch_group(qtile, idx, pull_window):
    if pull_window:
        qtile.current_window.togroup(groups[idx].name, switch_group=True)    
    else:
        qtile.groups[idx].toscreen()


@lazy.function
def left_group(qtile, pull_window=False):
    row, col = get_current_group(qtile)
    if col >= 1:
        switch_group(qtile, Grid.to_idx(row, col-1), pull_window)

@lazy.function
def right_group(qtile, pull_window=False):
    row, col = get_current_group(qtile)
    if col < Grid.cols -1:
        switch_group(qtile, Grid.to_idx(row, col+1), pull_window)

@lazy.function
def up_group(qtile, pull_window=False):
    row, col = get_current_group(qtile)
    if row >= 1:
        switch_group(qtile, Grid.to_idx(row-1, col), pull_window)

@lazy.function
def down_group(qtile, pull_window=False):
    row, col = get_current_group(qtile)
    if row < Grid.rows -1:
        switch_group(qtile, Grid.to_idx(row+1, col), pull_window)


keys.extend([
        Key([mod, "control"], "left", lazy.screen.prev_group()),
        Key([mod, "control"], "right", lazy.screen.next_group()),
        # Gnome controls
        # Key([alt, "control"], "left", left_group()),
        # Key([alt, "control"], "right", right_group()),
        # Key([alt, "control"], "up", up_group()),
        # Key([alt, "control"], "down", down_group()),
        # Key([alt, "control", "shift"], "left", left_group(pull_window=True)),
        # Key([alt, "control", "shift"], "right", right_group(pull_window=True)),
        # Key([alt, "control", "shift"], "up", up_group(pull_window=True)),
        # Key([alt, "control", "shift"], "down", down_group(pull_window=True)),
        ]),

keys.extend([
        Key([mod], "a", left_group()),
        Key([mod], "s", down_group()),
        Key([mod], "d", up_group()),
        Key([mod], "f", right_group()),
        Key([mod, "shift"], "a", left_group(pull_window=True)),
        Key([mod, "shift"], "s", down_group(pull_window=True)),
        Key([mod, "shift"], "d", up_group(pull_window=True)),
        Key([mod, "shift"], "f", right_group(pull_window=True)),
        Key([mod], "j", lazy.layout.grow_left()),
        Key([mod], "k", lazy.layout.grow_down()),
        Key([mod], "l", lazy.layout.grow_up()),
        Key([mod], "ae", lazy.layout.grow_right()),
        Key([mod, alt], "j", lazy.layout.shuffle_left()),
        Key([mod, alt], "k", lazy.layout.shuffle_down()),
        Key([mod, alt], "l", lazy.layout.shuffle_up()),
        Key([mod, alt], "ae", lazy.layout.shuffle_right()),
        Key([mod], "space", lazy.layout.next()),
        ]),



# Default qtile
# keys.extend([
#     # Switch between windows   
#     Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
#     Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
#     Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
#     Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
#     Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
#     ])


# Scratchpads
# =======================


scratchpads = ScratchPad("scratchpad",
        dropdowns = [
            # Drop down terminal with tmux session
            DropDown("term", "kitty".split(), # Obs gnome terminal refues to open as floating window
                opacity = 0.9,
                y = 0.25,
                height = 0.5,
                on_focus_lost_hide = True,
                warp_pointer = False
                ),
        ])

groups.append(scratchpads)

keys.extend([
        Key([mod], "comma", lazy.group["scratchpad"].dropdown_toggle("term")),
		])

# Layouts
# =======================

layouts = [
    layout.Columns(
        border_focus = colors.border_active,
        border_normal = colors.border_inactive,
        border_normal_stack = colors.colors_grayscale[-3],
        # border_focus_stack=[colors.colors_grayscale[0], colors.colors_grayscale[-1]],
        border_width=3, 
        margin=0
        ),
    # layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    #layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]






# Bar and screen
# =======================

# widget_defaults = dict(
#     font='Cantarell',
#     fontsize=12,
#     padding=3,
# )

# List avaliable fonts
# fc-list \
#    | grep -ioE ": [^:]*$1[^:]+:" \
#    | sed -E 's/(^: |:)//g' \
#    | tr , \\n \
#    | sort \
#    | uniq

widget_defaults = dict(
    # font = "Monospace",
    # font = "BigBlueTermPlus Nerd Font",
    # font="Monoki Nerd Font",
    # font="LiterationSans",
    font = "sans",
    # font = "DroidSansM Nerd Font",
    # font = "M+CodeLatX Nerd Font",
    # font = "M+CodeLat Nerd Font",
    # font = "Mononoki Nerd Font",
    # font = "M+1 Nerd Font",
    fontsize=12,
    padding = 10,
    # background=colors.get_color(1),
    # foreground=Colors.text_black,
    # foreground=Colors.text_black,
    # background=
)

extension_defaults = widget_defaults.copy()

def spacer(length = 15):
    return widget.Spacer(
        length = length, 
        background = '#00000000',
        decorations = [PowerLineDecoration(path='forward_slash',),]
    )

# import functools
# decoration = functools.partial(RectDecoration, radius=13, filled=True, padding_y=0)
# This can be done smarter
# https://stackoverflow.com/questions/46739019/is-it-possible-to-pass-the-same-optional-arguments-to-multiple-functions

def get_extention_styleing(color=None, color_index_skip=1):
    if not color:
        color = colors.get_color(color_index_skip)

    optional_vars = {
        # "padding": 10,
        "background":color,
        "foreground":Colors.text_black,
        "decorations":[
            PowerLineDecoration(
                path='forward_slash',
            ),
            # RectDecoration(
            #     colour=color, # Obs collide with widget color if set
            #     radius=13, 
            #     filled=True, 
            #     padding_y=0
            # )
        ],
    }

    return optional_vars

# See https://www.nerdfonts.com/cheat-sheet for icons


widget_list = [
                widget.CurrentLayout(
                    **get_extention_styleing()
                ),
                # spacer(),
                widget.GroupBox(
                    # highlight_method='block',
                    # foreground = Colors.text_black,
                    active =  Colors.text_black,
                    # block_highlight_text_color = Colors.text_white,
                    inactive = Colors.text_white,
                    hide_unused=True,
                    highlight_method='line',
                    highlight_color = ["#00FFFF00"],
                    other_current_screen_border = colors.get_color(1),
                    other_screen_border = colors.get_color(0),
                    this_current_screen_border = colors.get_color(1),
                    this_screen_border = colors.get_color(0),
                    **get_extention_styleing(),
                ),
                # spacer(),
                widget.WindowName(
                    width=400,
                    max_chars = 55,
                    **get_extention_styleing()
                ),
                spacer(bar.STRETCH),
                widget.Prompt(
                    **get_extention_styleing(colors.border_active)
                ),
                widget.Chord(
                    chords_colors={
                        "launch": ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                    **get_extention_styleing(colors.border_active)
                ),
                spacer(bar.STRETCH),
                widget.Volume(
                    fmt="  {}",
                    volume_app=commands.alsamixer,
                    **get_extention_styleing()
                    ),
                # spacer(),
                widget.Battery(
                    fmt=u"   {}",
                    discharge_char='↓',
                    charge_char='↑',
                    format='{char} {hour:d}:{min:02d}',
                    **get_extention_styleing()
                    ),
                # spacer(),
                widget.CheckUpdates(
                    fmt="󰚰  {}",
                    distro='Ubuntu',
                    colour_have_updates = Colors.text_black,
                    colour_no_updates = Colors.text_black,
                    display_format='{updates}',
                    execute=commands.update,
                    **get_extention_styleing()
                    ),
                # spacer(),
                widget.Wlan(
                    fmt= "   {}",
                    interface='wlp9s0',
                    format='{essid} {percent:2.0%}',
                    **get_extention_styleing()
                    ),
                widget.Clock(
                    format=u"  %A  %Y-%m-%d",
                    mouse_callbacks = {"Button1":lazy.spawn(Commands.calendar)},
                    **get_extention_styleing()
                    ),
                widget.Clock(
                    format="󰥔  %H:%M",
                    mouse_callbacks = {"Button1":lazy.spawn(Commands.calendar)},
                    **get_extention_styleing()
                    ),
                spacer(),
                # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
                widget.StatusNotifier(
                    **get_extention_styleing()
                    ),
                widget.Systray(
                    # background = colors.get_color()
                    # **get_extention_styleing(),
                ),
                widget.QuickExit(
                    countdown_format='{}s',
                    default_text='  ',
                    fmt=u"{} ⏻ ",
                    # **get_extention_styleing()
                ),
                # widget.Spacer(length=20, background=colors.get_color(1)),
                # widget.Spacer(length=20, background=colors.get_color(1)),
                # widget.Spacer(length=20, background=colors.get_color(1)),
            ]

def get_path_to_random_wallpaper():
    # return path.expanduser('~/Pictures/wallpapers/0056.jpg')
    # return path.expanduser('~/Pictures/wallpapers/0043.jpg')
    import glob
    files = []
    files.extend(glob.glob(path.expanduser('~/Pictures/variety')+'/**/*.jpg', recursive = True))
    files.extend(glob.glob(path.expanduser('~/Pictures/wallpaper')+'/**/*.jpg', recursive = True))
    files.extend(glob.glob('/usr/share/backgrounds/**/*.jpg', recursive = True))
    return random.choice(files)

wallpaper = get_path_to_random_wallpaper()



screens = [
    Screen(
        top=bar.Bar(
            widgets = widget_list,
            size=24,
            background="#00000000",
            border_color="#00000000",
            border_width=[5, 0, 5, 0],  # Draw top and bottom borders
            #margin=[5,5,5,5],
        ),
        #bottom=bottom,
        # wallpaper=wallpaper,
        # wallpaper_mode='stretch',
    ),
    Screen(
        top=bar.Bar([
                widget.CurrentLayoutIcon(
                    scale=0.65,
                    **get_extention_styleing()
                ),
                widget.WindowName(
                    **get_extention_styleing()
                ),
            ],
            size=24, 
            # opacity=0.0,
            background='#00000000',
            margin=[5,5,5,5]
),
        # wallpaper=wallpaper,
        # wallpaper_mode='stretch',
    ),
]


# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False

floating_layout = layout.Floating(
    # border_focus = '#cc241d',
    # border_normal = '#98971a',
    # border_width = 4, # Boarders does not play nice with picoms rouded corners
    margin = 2,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)


auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

wallpapers = {}

@hook.subscribe.setgroup
def group_animation():
    # Todo show some animation when switching groups, or swich wallpaper
    try:
        group = str(qtile.current_group.name)
        if group not in wallpapers:
            wallpapers[group] = get_path_to_random_wallpaper()
        # Feh conflicts with qtile if wallpaper is set using the qtiles screen variable.
        # Causes qtile to crash on reloads
        Popen(Commands.wallpaper_set +[wallpapers[group]])
    except Exception as e:
        logger.warning("Uh oh, failed to set wallpaper on group change")
        logger.warning(e)


# from https://github.com/ramnes/qtile-config/blob/98e097cfd8d5dd1ab1858c70babce141746d42a7/config.py#L108
@hook.subscribe.screen_change
def set_screens(sc):
    if not path.exists(path.expanduser('~/NO-AUTORANDR')):
        run(Commands.autorandr)
        # qtile.cmd_restart()


@hook.subscribe.startup
def autostart():
    if not path.exists(path.expanduser('~/NO-AUTORANDR')):
        run(Commands.autorandr)
    # Popen starts detached process
    Popen(Commands.picom) 
    Popen(Commands.dropbox) 
    # Picom reload autoamtic on changes in picom.conf
    # Picom errors out if picom its already running, no need to 'pkill picom' first




# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
