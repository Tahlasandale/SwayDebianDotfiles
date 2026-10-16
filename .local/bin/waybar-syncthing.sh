#!/bin/sh
# waybar-syncthing.sh — Module de statut JSON pour Waybar (Syncthing)
if pgrep -x syncthing >/dev/null 2>&1; then
    printf '{"text":"","alt":"running","tooltip":"Syncthing (En cours)\\n1 clic : Démarrer\\nDouble-clic : Interface Web (http://127.0.0.1:8384)\\nClic droit : Arrêter","class":"running"}\n'
else
    printf '{"text":"","alt":"stopped","tooltip":"Syncthing (Arrêté)\\n1 clic : Démarrer\\nDouble-clic : Interface Web","class":"stopped"}\n'
fi
