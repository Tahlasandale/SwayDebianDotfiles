#!/bin/sh
# Tirage aleatoire d'un wallpaper dans ~/Images.
# Via awww (fondu) si le daemon tourne, sinon swaymsg (instantane).
# Silencieux hors Sway (garde SWAYSOCK) pour usage via timer systemd.
DIR="$HOME/Images"
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/sway-last-wallpaper"

[ -n "$SWAYSOCK" ] || exit 0

list() {
    find "$DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) 2>/dev/null
}

PIC=$(list | shuf -n 1)
[ -n "$PIC" ] || exit 1

if [ -f "$STATE" ]; then
    LAST=$(cat "$STATE" 2>/dev/null)
    if [ "$PIC" = "$LAST" ]; then
        ALT=$(list | grep -v -F -x "$LAST" | shuf -n 1)
        [ -n "$ALT" ] && PIC="$ALT"
    fi
fi

command -v swaymsg >/dev/null 2>&1 || exit 0
swaymsg output '*' bg "$PIC" fill >/dev/null 2>&1

mkdir -p "$(dirname "$STATE")"
printf '%s' "$PIC" > "$STATE"
