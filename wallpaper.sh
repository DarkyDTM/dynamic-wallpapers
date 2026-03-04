#!/bin/bash

WALLPAPER_NAME="Big macOS Sur"
WALLPAPER_DIR="$HOME/Pictures/wallpapers/dynamic-wallpapers/$WALLPAPER_NAME"

# Scan directory and find the total number of frames
# Supports both .jpg and .png extensions
get_total_frames() {
    local max=0
    for f in "$WALLPAPER_DIR"/frame-*; do
        [[ -f "$f" ]] || continue
        local num
        num=$(basename "$f" | grep -oP '(?<=frame-)\d+')
        [[ -n "$num" && "$num" -gt "$max" ]] && max=$num
    done
    echo "$max"
}

# Detect extension used by frame files (.jpg or .png)
get_frame_ext() {
    for ext in jpg png jpeg webp; do
        [[ -f "$WALLPAPER_DIR/frame-1.$ext" ]] && echo "$ext" && return
    done
    echo "jpg"
}

get_frame() {
    local total_frames="$1"
    local total_minutes=$(( $(date +%-H) * 60 + $(date +%-M) ))
    local minutes_per_frame=$(( 1440 / total_frames ))
    local frame=$(( total_minutes / minutes_per_frame + 1 ))
    [ "$frame" -gt "$total_frames" ] && frame=$total_frames
    echo "$frame"
}

set_wallpaper() {
    local frame_num="$1"
    local ext="$2"
    local wallpaper="$WALLPAPER_DIR/frame-${frame_num}.${ext}"

    if [ ! -f "$wallpaper" ]; then
        echo "[$(date '+%H:%M:%S')] ERROR: file not found: $wallpaper"
        return 1
    fi

    swww img "$wallpaper" \
        --transition-type fade \
        --transition-duration 2 \
        --transition-fps 60
}

# Start swww-daemon if not running
if ! swww query &>/dev/null; then
    echo "[$(date '+%H:%M:%S')] swww-daemon not running, starting..."
    swww-daemon &
    sleep 2
    echo "[$(date '+%H:%M:%S')] swww-daemon started"
else
    echo "[$(date '+%H:%M:%S')] swww-daemon already running"
fi

# Validate wallpaper directory
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "[$(date '+%H:%M:%S')] ERROR: directory not found: $WALLPAPER_DIR"
    exit 1
fi

TOTAL_FRAMES=$(get_total_frames)

if [ "$TOTAL_FRAMES" -eq 0 ]; then
    echo "[$(date '+%H:%M:%S')] ERROR: no frame files found in $WALLPAPER_DIR"
    exit 1
fi

EXT=$(get_frame_ext)
MINUTES_PER_FRAME=$(( 1440 / TOTAL_FRAMES ))

echo "[$(date '+%H:%M:%S')] Wallpaper set  : $WALLPAPER_NAME"
echo "[$(date '+%H:%M:%S')] Total frames   : $TOTAL_FRAMES"
echo "[$(date '+%H:%M:%S')] File extension : .$EXT"
echo "[$(date '+%H:%M:%S')] Interval       : ${MINUTES_PER_FRAME} min per frame (${TOTAL_FRAMES} changes/day)"

LAST_FRAME=0

while true; do
    FRAME=$(get_frame "$TOTAL_FRAMES")

    if [ "$FRAME" != "$LAST_FRAME" ]; then
        echo "[$(date '+%H:%M:%S')] Frame changed: $LAST_FRAME -> $FRAME, setting frame-${FRAME}.${EXT}"
        if set_wallpaper "$FRAME" "$EXT"; then
            echo "[$(date '+%H:%M:%S')] Wallpaper set successfully"
        fi
        LAST_FRAME=$FRAME
    fi

    SLEEP=$(( 60 - $(date +%S) ))
    echo "[$(date '+%H:%M:%S')] Sleeping ${SLEEP}s until next check (current frame: $FRAME / $TOTAL_FRAMES)"
    sleep "$SLEEP"
done
