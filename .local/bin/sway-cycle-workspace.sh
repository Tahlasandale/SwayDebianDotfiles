#!/bin/sh
# cycle-workspace.sh next|prev — rotation circulaire des workspaces 1..5
cur=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true) | .num')
case "$cur" in ''|*[!0-9]*) exit 1 ;; esac
if [ "$1" = prev ]; then nxt=$(((cur + 3) % 5 + 1)); else nxt=$((cur % 5 + 1)); fi
swaymsg workspace number "$nxt"
