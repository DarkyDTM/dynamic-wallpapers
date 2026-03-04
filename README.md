# dynamic-wallpaper

A minimal bash daemon that automatically changes wallpaper based on the time of day. Uses [swww](https://github.com/LGFae/swww) for smooth wallpaper transitions on Wayland.

## How it works

The day is divided into 16 equal intervals of 90 minutes each. Every interval maps to one wallpaper frame. The daemon checks the current time every minute and switches the wallpaper when a new frame begins.

```
00:00 – 01:30  →  frame-1.jpg
01:30 – 03:00  →  frame-2.jpg
...
22:30 – 24:00  →  frame-16.jpg
```

## Dependencies

- [swww](https://github.com/LGFae/swww) — installed and available in `$PATH`
- Wayland-compatible compositor (e.g. Hyprland)

## Wallpapers structure

Wallpapers must be placed at:

```
~/Pictures/wallpapers/dynamic-wallpapers/
├── frame-1.jpg
├── frame-2.jpg
├── ...
└── frame-16.jpg
```

The path can be changed by editing the `WALLPAPERS_DIR` variable at the top of the script:

```bash
WALLPAPERS_DIR="/your/custom/path"
```

## Installation

```bash
cp dynamic-wallpaper.sh ~/.local/share/bin/dynamic-wallpaper.sh
chmod +x ~/.local/share/bin/dynamic-wallpaper.sh
cp wallpapers/* ~/Pictures/wallpapers/dynamic-wallpapers
```

## Autostart

Add to `~/.config/hypr/hyprland.conf`:

```
exec-once = /home/user/.local/share/bin/dynamic-wallpaper.sh
```

## Debug

The script prints its activity to stdout:

```
[12:00:01] swww-daemon already running
[12:00:01] Starting wallpaper daemon loop
[12:00:01] Frame changed: 0 -> 9, setting frame-9.jpg
[12:00:01] Wallpaper set successfully
[12:00:01] Sleeping 59s until next check (current frame: 9)
```

To capture the output when launched via Hyprland, redirect it to a file:

```
exec-once = /home/user/.local/share/bin/dynamic-wallpaper.sh > /tmp/dynamic-wallpaper.log 2>&1
```
