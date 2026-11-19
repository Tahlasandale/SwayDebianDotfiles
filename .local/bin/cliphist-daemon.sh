#!/bin/sh
# cliphist-daemon.sh — Surveillance automatique du presse-papier (texte & images)
# Capture tout contenu copié pour alimenter l'historique cliphist.

# Évite les doublons d'instances
pkill -f "wl-paste.*cliphist" 2>/dev/null || true

# Surveiller les textes
nohup /home/bison/.local/bin/wl-paste --watch /home/bison/.local/bin/cliphist store >/dev/null 2>&1 &

# Surveiller les images
nohup /home/bison/.local/bin/wl-paste --type image --watch /home/bison/.local/bin/cliphist store >/dev/null 2>&1 &
