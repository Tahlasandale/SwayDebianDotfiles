#!/bin/sh
# waybar-syncthing.sh — Module de statut JSON pour Waybar (Syncthing)

state=$(systemctl --user is-active syncthing.service 2>/dev/null || true)

if pgrep -x syncthing >/dev/null 2>&1; then
    printf '{"text":"","alt":"running","tooltip":"Syncthing (En cours)\\n• Clic gauche : Éteindre\\n• Clic droit : Ouvrir l'\''interface Web (8384)","class":"running"}\n'
elif [ "$state" = "activating" ]; then
    printf '{"text":"","alt":"starting","tooltip":"Syncthing (Démarrage en cours...)","class":"starting"}\n'
else
    printf '{"text":"","alt":"stopped","tooltip":"Syncthing (Arrêté)\\n• Clic gauche : Allumer\\n• Clic droit : Allumer & Ouvrir l'\''interface Web","class":"stopped"}\n'
fi
