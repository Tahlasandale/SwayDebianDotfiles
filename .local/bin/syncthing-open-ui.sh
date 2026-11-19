#!/bin/sh
# syncthing-open-ui.sh — Ouvre l'interface Web Syncthing de façon sécurisée
# Démarre automatiquement Syncthing si éteint et attend que le port 8384 réponde.

is_listening() {
    curl -s -m 0.5 http://127.0.0.1:8384 >/dev/null 2>&1
}

if ! is_listening; then
    # Démarre le service s'il ne tourne pas déjà
    systemctl --user start syncthing.service 2>/dev/null || true

    # Attendre que le serveur Web soit prêt (max 4 secondes)
    count=0
    while [ "$count" -lt 40 ] && ! is_listening; do
        sleep 0.1
        count=$((count + 1))
    done

    # Signale à Waybar que Syncthing est désormais actif
    pkill -RTMIN+9 waybar 2>/dev/null || true
fi

# Ouvre le navigateur par défaut sur l'interface
xdg-open "http://127.0.0.1:8384" >/dev/null 2>&1 &
