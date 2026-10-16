#!/bin/sh
# waybar-megasync.sh — Module de statut JSON pour Waybar (MEGAsync)
if pgrep -x megasync >/dev/null 2>&1; then
    printf '{"text":"","alt":"running","tooltip":"MEGAsync (En cours)\\n1 clic : Démarrer\\nDouble-clic : Ouvrir l'\''interface\\nClic droit : Quitter","class":"running"}\n'
else
    printf '{"text":"","alt":"stopped","tooltip":"MEGAsync (Arrêté)\\n1 clic : Démarrer\\nDouble-clic : Ouvrir l'\''interface","class":"stopped"}\n'
fi
