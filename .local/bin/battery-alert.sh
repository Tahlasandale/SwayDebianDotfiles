#!/bin/sh
# battery-alert.sh [--test] — notif mako si batterie <= 20% (critique <= 10%).
# Anti-spam : un palier notifie une fois, relance max toutes les 30 min.
set -u
BAT=/sys/class/power_supply/BAT1
STATE=$HOME/.local/state/battery-alert
NOW=$(date +%s)

if [ "${1:-}" = "--test" ]; then
    cap=19; st=Discharging
else
    [ -r "$BAT/capacity" ] || exit 0
    cap=$(cat "$BAT/capacity"); st=$(cat "$BAT/status")
fi

# Branche : remise a zero
case "$st" in
  Charging|Full|Not\ charging) rm -f "$STATE"; exit 0 ;;
esac

[ "$cap" -le 20 ] || { rm -f "$STATE"; exit 0; }

if [ "$cap" -le 10 ]; then level=10; urgency=2; else level=20; urgency=0; fi

# Anti-spam : meme palier deja notifie il y a < 30 min
if [ -r "$STATE" ]; then
    read -r last_level last_ts < "$STATE" 2>/dev/null || last_level=0
    if [ "${last_level:-0}" -eq "$level" ] && [ $((NOW - last_ts)) -lt 1800 ]; then
        exit 0
    fi
fi

title="Batterie basse"
body="$cap% restant — branchez le chargeur."
if [ "$urgency" -eq 2 ]; then
    title="Batterie critique"
    body="$cap% restant — arret imminent !"
fi
gdbus call --session --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.Notify \
  "battery-alert" 0 "" "$title" "$body" "[]" "{\"urgency\": <byte $urgency>}" 10000 \
  >/dev/null 2>&1 || exit 1

printf '%s %s\n' "$level" "$NOW" > "$STATE"
