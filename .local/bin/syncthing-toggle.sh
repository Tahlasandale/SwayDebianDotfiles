#!/bin/sh
# syncthing-toggle.sh — Active / Désactive Syncthing proprement avec verrou anti-rebond

LOCKFILE="/run/user/$(id -u)/syncthing-toggle.lock"

# Mutex : évite les clics hystériques ou concurrents (FD 9 compatible dash/sh)
exec 9>"$LOCKFILE"
flock -n 9 || exit 0

is_running() {
    systemctl --user is-active --quiet syncthing.service 2>/dev/null || pgrep -x syncthing >/dev/null 2>&1
}

if is_running; then
    # Arrêt propre via systemd (pas de killall intempestif)
    systemctl --user stop syncthing.service 2>/dev/null || true

    # Attendre brièvement que le processus disparaisse (max 1s)
    count=0
    while [ "$count" -lt 20 ] && pgrep -x syncthing >/dev/null 2>&1; do
        sleep 0.05
        count=$((count + 1))
    done
else
    # Démarrage propre via systemd
    systemctl --user start syncthing.service 2>/dev/null || true

    # Attendre que le processus apparaisse (max 1.5s)
    count=0
    while [ "$count" -lt 30 ] && ! pgrep -x syncthing >/dev/null 2>&1; do
        sleep 0.05
        count=$((count + 1))
    done
fi

# Rafraîchissement garanti et instantané du module Waybar
pkill -RTMIN+9 waybar 2>/dev/null || true
