#!/bin/sh
# tm-restore.sh — Restaure l'état de TrackMania depuis le dépôt dotfiles
set -eu

SRC="$HOME/.config/trackmania-sources"
DEST_DOC="$HOME/Documents/TmForever"
DEST_WINE="$HOME/snap/tmnationsforever/common/.wine/drive_c/ProgramData/TmForever"

if [ ! -d "$SRC" ] || [ ! -d "$SRC/Documents" ]; then
    echo "Erreur : aucune sauvegarde TrackMania trouvée dans $SRC" >&2
    exit 1
fi

echo "=== Restauration de TrackMania Nations Forever depuis dotfiles ==="

# 1. Restauration des documents du jeu
mkdir -p "$DEST_DOC"
rsync -a "$SRC/Documents/" "$DEST_DOC/"

# 2. Restauration des scores de campagne Wine
if [ -d "$SRC/WineData" ]; then
    mkdir -p "$DEST_WINE"
    rsync -a "$SRC/WineData/" "$DEST_WINE/"
fi

echo "TrackMania restauré avec succès !"
echo "Profils, médailles, temps officiels et circuits disponibles."
