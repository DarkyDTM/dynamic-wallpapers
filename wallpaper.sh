#!/bin/bash

WALLPAPER_DIR="~/Pictures/wallpapers/dynamic-wallpapers"

get_frame() {
    local total_minutes=$(( $(date +%-H) * 60 + $(date +%-M) ))
    local frame=$(( total_minutes / 90 + 1 ))
    [ "$frame" -gt 16 ] && frame=16
    echo "$frame"
}

set_wallpaper() {
    local wallpaper="$WALLPAPER_DIR/frame-${1}.jpg"
    [ -f "$wallpaper" ] || return 1

    swww img "$wallpaper" \
        --transition-type fade \
        --transition-duration 2 \
        --transition-fps 60
}

if ! swww query &>/dev/null; then
    echo "[$(date '+%H:%M:%S')] swww-daemon not running, starting..."
    swww-daemon &
    sleep 2
    echo "[$(date '+%H:%M:%S')] swww-daemon started"
else
    echo "[$(date '+%H:%M:%S')] swww-daemon already running"
fi

LAST_FRAME=0

echo "[$(date '+%H:%M:%S')] Starting wallpaper daemon loop"

while true; do
    FRAME=$(get_frame)

    if [ "$FRAME" != "$LAST_FRAME" ]; then
        echo "[$(date '+%H:%M:%S')] Frame changed: $LAST_FRAME -> $FRAME, setting frame-${FRAME}.jpg"
        set_wallpaper "$FRAME"
        echo "[$(date '+%H:%M:%S')] Wallpaper set successfully"
        LAST_FRAME=$FRAME
    fi

    SLEEP=$(( 60 - $(date +%S) ))
    echo "[$(date '+%H:%M:%S')] Sleeping ${SLEEP}s until next check (current frame: $FRAME)"
    sleep "$SLEEP"
done
