#!/bin/sh
# syncthing-toggle.sh — Active / Désactive Syncthing proprement et notifie Waybar

if pgrep -x syncthing >/dev/null 2>&1; then
    systemctl --user stop syncthing.service 2>/dev/null || true
    killall syncthing 2>/dev/null || true
else
    # Nettoie d'éventuels processus résiduels avant lancement propre
    killall syncthing 2>/dev/null || true
    systemctl --user start syncthing.service
fi

# Rafraîchissement instantané du module Waybar
pkill -RTMIN+9 waybar 2>/dev/null || true
