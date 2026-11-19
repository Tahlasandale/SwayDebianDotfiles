#!/bin/sh
# waybar-battery-toggle.sh — Bascule instantanée entre mode Pourcentage et Durée

MODE_FILE="/run/user/$(id -u)/waybar-battery-mode"

if [ -f "$MODE_FILE" ] && [ "$(cat "$MODE_FILE")" = "time" ]; then
    printf 'percent' > "$MODE_FILE"
else
    printf 'time' > "$MODE_FILE"
fi

# Rafraîchissement immédiat de Waybar (signal 8)
pkill -RTMIN+8 waybar 2>/dev/null || true
